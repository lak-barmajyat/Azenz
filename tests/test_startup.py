import logging

import pytest
from dotenv import dotenv_values

from services import config
from services.logger.setup import ConsoleFormatter

KEYS = [*config.DEFAULTS, "ENCRYPTION_KEY"]


@pytest.fixture
def clean_env(monkeypatch):
    for key in KEYS:
        monkeypatch.delenv(key, raising=False)


def test_missing_env_prompts_and_saves_masked_secrets(clean_env, monkeypatch, tmp_path, capsys):
    path = tmp_path / ".env"
    monkeypatch.setattr("builtins.input", lambda _: "")
    monkeypatch.setattr(config.getpass, "getpass", lambda _: "")
    result = config.load_config(interactive=True, env_file=path)
    assert result.database.name == "azenz_commercial"
    assert result.database.user == "azenz"
    assert result.database.password == "12345678"
    assert result.encryption_key
    assert dotenv_values(path)["DB_PASSWORD"] == result.database.password
    assert "12345678" not in capsys.readouterr().out
    assert "12345678" not in repr(result)
    monkeypatch.setattr("builtins.input", lambda _: pytest.fail("No repeat prompt"))
    monkeypatch.setattr(config.getpass, "getpass", lambda _: pytest.fail("No repeat secret prompt"))
    assert config.load_config(interactive=True, env_file=path) == result


def test_existing_values_preserved_and_shown_without_secrets(
    clean_env, monkeypatch, tmp_path, capsys
):
    path = tmp_path / ".env"
    path.write_text("ENV=production\nDB_HOST=db.example.com\nDB_PASSWORD=existing-secret\n")
    monkeypatch.setattr("builtins.input", lambda _: "")
    monkeypatch.setattr(config.getpass, "getpass", lambda _: "")
    result = config.load_config(interactive=True, env_file=path)
    output = capsys.readouterr().out
    assert "DB_HOST=db.example.com" in output
    assert "existing-secret" not in output
    assert result.database.password == "existing-secret"
    assert result.environment == "production"


def test_missing_config_noninteractive_does_not_write(clean_env, tmp_path):
    path = tmp_path / ".env"
    with pytest.raises(config.ConfigurationError, match="Missing ENV"):
        config.load_config(env_file=path)
    assert not path.exists()


@pytest.mark.parametrize(
    "key,value",
    [("ENV", "staging"), ("DB_PORT", "0"), ("DB_PORT", "65536"), ("DB_NAME", "bad;name")],
)
def test_invalid_settings(key, value):
    with pytest.raises(config.ConfigurationError):
        config._validate(key, value)


def test_console_short_file_formatter_retains_exception():
    try:
        raise RuntimeError("details")
    except RuntimeError:
        import sys

        record = logging.LogRecord(
            "test", logging.ERROR, __file__, 1, "Startup failed", (), sys.exc_info()
        )
    assert ConsoleFormatter("%(message)s").format(record) == "Startup failed"
    assert "Traceback" in logging.Formatter("%(message)s").format(record)


def test_main_never_launches_qml_on_bootstrap_failure(monkeypatch):
    import main

    monkeypatch.setattr(main, "setup_logging", lambda: None)

    def fail():
        raise RuntimeError("database unavailable")

    monkeypatch.setattr(main, "bootstrap_application", fail)
    monkeypatch.setattr(main, "run_application", lambda _: pytest.fail("QML must not open"))
    assert main.main() == 1
