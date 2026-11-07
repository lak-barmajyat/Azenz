import os
import uuid
from dataclasses import replace

import pytest
from sqlalchemy import create_engine, inspect, select, text
from sqlalchemy.orm import configure_mappers

from database import engine as engine_module
from database import setup
from database.engine import database
from database.migrations.runner import SchemaError, check_schema, run_migrations
from database.models import Base, PUtilisateurs
from database.session import setup_session
from modules.login.repository import authenticate_user
from services import bootstrap
from services.config import AppConfig, DatabaseConfig


def test_split_sql_handles_quotes_comments_and_semicolons():
    assert setup._split_sql(
        "-- header; don't open a quote\nINSERT INTO users VALUES ('Ada; Lovelace', 'it''s');"
        "/* comment ; */ # trailing ;\n"
    ) == ["INSERT INTO users VALUES ('Ada; Lovelace', 'it''s')"]


def test_split_sql_rejects_unterminated_string():
    with pytest.raises(ValueError, match="Unterminated"):
        setup._split_sql("INSERT INTO users VALUES ('oops);")


def test_all_models_registered():
    configure_mappers()
    assert len(Base.metadata.tables) == 14
    assert len(Base.metadata.sorted_tables) == 14


@pytest.fixture
def isolated_db(monkeypatch):
    # Explicit opt-in only: NEVER use the application's .env database for tests.
    url = os.getenv("AZENZ_TEST_MYSQL_URL")
    if not url:
        pytest.skip("Set AZENZ_TEST_MYSQL_URL to a disposable MySQL/MariaDB server")
    admin = create_engine(url, hide_parameters=True)
    name = "azenz_test_" + uuid.uuid4().hex[:12]
    user = "test_" + uuid.uuid4().hex[:12]
    config = DatabaseConfig("localhost", 3306, name, user, "12345678", "utf8mb4")

    def test_engine(settings, *, include_database=True, socket=""):
        # Preserve socket/host from the explicit isolated test URL.
        return create_engine(
            admin.url.set(
                database=settings.name if include_database else None,
                username=settings.user,
                password=settings.password,
            ),
            hide_parameters=True,
        )

    monkeypatch.setattr(engine_module, "make_engine", test_engine)
    yield config, admin
    database.close()
    with admin.begin() as connection:
        connection.execute(text(f"DROP DATABASE IF EXISTS `{name}`"))
        connection.execute(text("DROP USER IF EXISTS :user@'localhost'"), {"user": user})
    admin.dispose()


def answers(monkeypatch, *, demo="n", username="admin", password="test-secret"):
    def prompt(message):
        if "administrator [" in message:
            return "root"
        if "socket path" in message:
            return "/unused-test-socket"
        if "account host" in message:
            return "localhost"
        if "demo data" in message:
            return demo
        if "username" in message:
            return username
        if "email" in message:
            return "manager@example.com"
        pytest.fail(f"Unexpected prompt: {message}")

    monkeypatch.setattr("builtins.input", prompt)
    monkeypatch.setattr(
        setup.getpass, "getpass", lambda prompt: "" if "administrator" in prompt else password
    )


def test_fresh_install_without_demo_and_repeat_startup(isolated_db, monkeypatch):
    config, _ = isolated_db
    answers(monkeypatch)
    app_config = AppConfig("development", "test-key", config)
    monkeypatch.setattr(bootstrap, "load_config", lambda **kwargs: app_config)
    bootstrap.bootstrap_application()
    check_schema()
    with database.engine.connect() as c:
        assert len(inspect(c).get_table_names()) == 15
        assert c.scalar(text("SELECT COUNT(*) FROM p_utilisateurs")) == 1
        assert c.scalar(text("SELECT COUNT(*) FROM p_types_documents")) == 0
    user = authenticate_user("admin", "test-secret")
    assert user.nom_utilisateur == "admin"  # still readable after commit/close
    assert authenticate_user("admin", "wrong") is None
    monkeypatch.setattr("builtins.input", lambda _: pytest.fail("Repeated startup must not prompt"))
    bootstrap.bootstrap_application()
    assert authenticate_user("admin", "test-secret").nom_utilisateur == "admin"


def test_fresh_demo_and_manager(isolated_db, monkeypatch):
    config, _ = isolated_db
    answers(monkeypatch, demo="yes")
    setup.initialize_database(config)
    setup_session()
    assert authenticate_user("admin", "test-secret").nom_utilisateur == "admin"
    assert authenticate_user("demo.admin", "12345678") is None
    with database.engine.connect() as c:
        before = {
            name: c.scalar(text(f"SELECT COUNT(*) FROM `{name}`")) for name in Base.metadata.tables
        }
        assert before["p_utilisateurs"] == 6
        assert before["d_documents"] > 0
    with pytest.raises(RuntimeError, match="empty"):
        setup.load_demo_data()
    setup.initialize_database(config)
    with database.engine.connect() as c:
        after = {
            name: c.scalar(text(f"SELECT COUNT(*) FROM `{name}`")) for name in Base.metadata.tables
        }
    assert before == after


def test_existing_empty_database_no_demo_offer(isolated_db, monkeypatch):
    config, admin = isolated_db
    with admin.begin() as c:
        c.execute(text(f"CREATE DATABASE `{config.name}`"))
    answers(monkeypatch)
    setup.initialize_database(config)
    assert setup.manager_exists()


def test_existing_user_password_never_reset(isolated_db):
    config, admin = isolated_db
    with admin.begin() as c:
        c.execute(
            text("CREATE USER :user@'localhost' IDENTIFIED BY 'original'"), {"user": config.user}
        )
    assert engine_module.provision_database(config, "root", "", account_host="localhost")
    with pytest.raises(Exception):
        engine_module.make_engine(config).connect()
    existing = engine_module.make_engine(replace(config, password="original"))
    with existing.connect() as c:
        grants = c.execute(text("SHOW GRANTS")).scalars().all()
        assert any(
            "ALL PRIVILEGES" in grant and config.name.replace("_", r"\_") in grant
            for grant in grants
        )
        assert not any("ALL PRIVILEGES ON *.*" in grant for grant in grants)
    existing.dispose()


def test_production_guards_before_any_setup(isolated_db, monkeypatch):
    config, _ = isolated_db
    engine_module.provision_database(config, "root", "", account_host="localhost")
    app_config = AppConfig("production", "test-key", config)
    monkeypatch.setattr(bootstrap, "load_config", lambda **kwargs: app_config)
    monkeypatch.setattr(
        bootstrap, "initialize_database", lambda _: pytest.fail("Production must not provision")
    )
    with pytest.raises(SchemaError, match="database.setup init"):
        bootstrap.bootstrap_application()
    with database.engine.connect() as c:
        assert inspect(c).get_table_names() == []
    run_migrations()
    with pytest.raises(RuntimeError, match="Manager"):
        bootstrap.bootstrap_application()
    answers(monkeypatch)
    setup.ensure_manager()
    monkeypatch.setattr("builtins.input", lambda _: pytest.fail("No production prompts"))
    bootstrap.bootstrap_application()
    with database.engine.connect() as c:
        assert c.scalar(select(PUtilisateurs.nom_utilisateur)) == "admin"


def test_partial_initial_migration_resumes_without_losing_rows(isolated_db):
    config, _ = isolated_db
    engine_module.provision_database(config, "root", "", account_host="localhost")
    database.setup(config)
    Base.metadata.tables["p_tvas"].create(database.engine)
    with database.engine.begin() as c:
        c.execute(
            text("INSERT INTO p_tvas (code_tva, nom_tva, taux) VALUES ('KEEP', 'Keep me', 20)")
        )
    run_migrations()
    run_migrations()
    with database.engine.connect() as c:
        assert c.scalar(text("SELECT nom_tva FROM p_tvas")) == "Keep me"


def test_incompatible_existing_schema_is_not_overwritten(isolated_db):
    config, _ = isolated_db
    engine_module.provision_database(config, "root", "", account_host="localhost")
    database.setup(config)
    with database.engine.begin() as c:
        c.execute(text("CREATE TABLE p_utilisateurs (id INT PRIMARY KEY, important_data TEXT)"))
        c.execute(text("INSERT INTO p_utilisateurs VALUES (1, 'preserve')"))
    with pytest.raises(SchemaError, match="unversioned"):
        run_migrations()
    with database.engine.connect() as c:
        assert c.scalar(text("SELECT important_data FROM p_utilisateurs")) == "preserve"
        assert inspect(c).get_table_names() == ["p_utilisateurs"]


def test_demo_failure_rolls_back(isolated_db, monkeypatch, tmp_path):
    config, _ = isolated_db
    engine_module.provision_database(config, "root", "", account_host="localhost")
    database.setup(config)
    run_migrations()
    fixture = tmp_path / "demo.sql"
    fixture.write_text(
        "INSERT INTO `p_tvas` (`id`, `code_tva`, `nom_tva`, `taux`) VALUES (1, 'A', 'A', 0);\n" * 2
    )
    monkeypatch.setattr(setup, "DEMO_DATA_FILE", fixture)
    with pytest.raises(Exception):
        setup.load_demo_data()
    with database.engine.connect() as c:
        assert c.scalar(text("SELECT COUNT(*) FROM p_tvas")) == 0


def test_no_admin_prompt_for_unreachable_server(monkeypatch):
    from unittest.mock import MagicMock

    from sqlalchemy.exc import OperationalError

    mock = MagicMock()
    mock.connect.side_effect = OperationalError(None, None, Exception(2003, "Connection refused"))
    monkeypatch.setattr(engine_module, "make_engine", lambda *args, **kwargs: mock)
    monkeypatch.setattr(
        "builtins.input", lambda _: pytest.fail("Server down must not ask for admin")
    )
    with pytest.raises(OperationalError):
        setup.initialize_database(DatabaseConfig("localhost", 1, "azenz", "azenz", "pw", "utf8mb4"))
    mock.dispose.assert_called_once()


def test_insufficient_database_grants_are_repaired(isolated_db):
    config, admin = isolated_db
    with admin.begin() as c:
        c.execute(text(f"CREATE DATABASE `{config.name}`"))
        c.execute(
            text("CREATE USER :user@'localhost' IDENTIFIED BY :password"),
            {"user": config.user, "password": config.password},
        )
        c.execute(
            text(f"GRANT SELECT ON `{config.name}`.* TO :user@'localhost'"), {"user": config.user}
        )
    assert engine_module.provisioning_required(config)
    assert not engine_module.provision_database(config, "root", "", account_host="localhost")
    assert not engine_module.provisioning_required(config)
