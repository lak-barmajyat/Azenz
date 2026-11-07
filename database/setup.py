"""Shared first-time setup, invoked automatically in development or via `init`."""

import getpass
import re
import sys
from pathlib import Path

import bcrypt
from sqlalchemy import select
from sqlalchemy.orm import Session

from database.engine import (
    check_database_connection,
    database,
    provision_database,
    provisioning_required,
)
from database.migrations.runner import run_migrations
from database.models import Base, PUtilisateurs
from database.models.p_utilisateurs import PUtilisateursRole
from services.config import DatabaseConfig, load_config
from services.logger import get_logger, setup_logging

DEMO_DATA_FILE = Path(__file__).parent / "schema" / "azenz_commercial_demo.sql"


def _split_sql(sql: str) -> list[str]:
    """Read our INSERT fixture, respecting quotes and SQL comments."""
    statements: list[str] = []
    buffer: list[str] = []
    quote: str | None = None
    index = 0
    while index < len(sql):
        char = sql[index]
        following = sql[index + 1 : index + 2]
        if quote:
            buffer.append(char)
            if char == "\\" and following:
                index += 1
                buffer.append(following)
            elif char == quote:
                if following == quote:
                    index += 1
                    buffer.append(following)
                else:
                    quote = None
        elif char in {"'", '"', "`"}:
            quote = char
            buffer.append(char)
        elif char == "#" or (
            sql[index : index + 2] == "--" and (index + 2 == len(sql) or sql[index + 2].isspace())
        ):
            end = sql.find("\n", index)
            index = len(sql) if end == -1 else end
            buffer.append(" ")
        elif sql[index : index + 2] == "/*":
            end = sql.find("*/", index + 2)
            if end == -1:
                raise ValueError("Unterminated SQL comment in demo file")
            index = end + 1
            buffer.append(" ")
        elif char == ";":
            if statement := "".join(buffer).strip():
                statements.append(statement)
            buffer.clear()
        else:
            buffer.append(char)
        index += 1
    if quote:
        raise ValueError("Unterminated SQL string in demo file")
    if statement := "".join(buffer).strip():
        statements.append(statement)
    return statements


def load_demo_data() -> None:
    statements = _split_sql(DEMO_DATA_FILE.read_text(encoding="utf-8-sig"))
    for statement in statements:
        match = re.match(r"INSERT INTO `([a-z_]+)`\s*\(", statement)
        if not match or match[1] not in Base.metadata.tables:
            raise ValueError("Demo file must contain only INSERTs into application tables")
    with database.engine.begin() as connection:
        for table in Base.metadata.sorted_tables:
            if connection.execute(select(table.c.id).limit(1)).first() is not None:
                raise RuntimeError("Demo import requires empty application tables; no data changed")
        for statement in statements:
            # The fixture is SQL, not SQLAlchemy bind syntax (literal ':' must stay literal).
            connection.exec_driver_sql(statement.replace("%", "%%"))


def manager_exists() -> bool:
    with Session(database.engine) as session:
        return (
            session.scalar(
                select(PUtilisateurs.id)
                .where(PUtilisateurs.role == PUtilisateursRole.MANAGER)
                .limit(1)
            )
            is not None
        )


def ensure_manager() -> None:
    if manager_exists():
        return
    print("Create the first Manager application account (separate from the MySQL user).")
    while True:
        username = input("Manager username [admin]: ").strip() or "admin"
        if len(username) > 100:
            print("Username must be at most 100 characters.")
            continue
        with Session(database.engine) as session:
            if (
                session.scalar(
                    select(PUtilisateurs.id).where(PUtilisateurs.nom_utilisateur == username)
                )
                is not None
            ):
                print("That username already exists; choose another. Existing users are unchanged.")
                continue
        break
    while True:
        email = input("Manager email: ").strip()
        if "@" in email and len(email) <= 255:
            break
        print("Enter an email address (at most 255 characters).")
    while True:
        password = getpass.getpass("Manager password: ")
        if not password or len(password.encode("utf-8")) > 72:
            print("Password must contain 1–72 UTF-8 bytes.")
            continue
        if password == getpass.getpass("Confirm Manager password: "):
            break
        print("Passwords do not match.")
    password_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("ascii")
    with Session(database.engine) as session, session.begin():
        session.add(
            PUtilisateurs(
                nom_utilisateur=username,
                email=email,
                mot_de_passe_hash=password_hash,
                role=PUtilisateursRole.MANAGER,
                actif=1,
            )
        )


def initialize_database(config: DatabaseConfig) -> None:
    created = False
    if provisioning_required(config):
        print("Database/account setup is required. Administrator credentials are not saved.")
        admin_user = input("MySQL administrator [root]: ").strip() or "root"
        admin_password = getpass.getpass("MySQL administrator password (empty for socket auth): ")
        socket = ""
        if config.host in {"localhost", "127.0.0.1", "::1"} and not admin_password:
            socket = input("Administrator Unix socket path (Enter for TCP): ").strip()
        default_host = "localhost" if config.host in {"localhost", "127.0.0.1", "::1"} else ""
        account_host = (
            input(f"Application MySQL account host [{default_host}]: ").strip() or default_host
        )
        if not account_host:
            raise ValueError(
                "Specify the client host allowed to connect to the application account"
            )
        created = provision_database(
            config, admin_user, admin_password, account_host=account_host, socket=socket
        )
        del admin_password
    database.setup(config)
    check_database_connection()
    run_migrations()
    if created and input("Import optional demo data? [y/N]: ").strip().lower() in {"y", "yes"}:
        load_demo_data()
    ensure_manager()


def main() -> int:
    setup_logging()
    logger = get_logger(__name__)
    if sys.argv[1:] != ["init"]:
        print("Usage: python -m database.setup init", file=sys.stderr)
        return 2
    try:
        config = load_config(interactive=True)
        initialize_database(config.database)
        logger.info("Database setup completed successfully")
        return 0
    except (EOFError, KeyboardInterrupt):
        logger.info("Database setup cancelled; run the init command again to resume")
        return 1
    except Exception as error:
        logger.error(
            "Database setup failed: %s. See the log for details.",
            (str(error).splitlines() or [type(error).__name__])[0],
            exc_info=True,
        )
        return 1
    finally:
        database.close()


if __name__ == "__main__":
    sys.exit(main())
