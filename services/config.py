import os
import re
from dataclasses import dataclass

from dotenv import load_dotenv

from services.paths import PROJECT_ROOT


class ConfigurationError(RuntimeError):
    pass


@dataclass(frozen=True)
class DatabaseConfig:
    host: str
    port: int
    name: str
    user: str
    password: str
    charset: str


@dataclass(frozen=True)
class AppConfig:
    environment: str
    encryption_key: str
    database: DatabaseConfig


def _required(name: str) -> str:
    value = os.getenv(name)

    if value is None or not value.strip():
        raise ConfigurationError(
            f"Missing required environment variable: {name}"
        )

    return value.strip()


def load_config() -> AppConfig:
    """Load and validate the Azenz configuration."""
    load_dotenv(PROJECT_ROOT / ".env")

    try:
        db_port = int(_required("DB_PORT"))
    except ValueError as exc:
        raise ConfigurationError("DB_PORT must be an integer") from exc

    db_name = _required("DB_NAME")
    db_charset = _required("DB_CHARSET")

    if not re.fullmatch(r"[A-Za-z0-9_]+", db_name):
        raise ConfigurationError("DB_NAME contains invalid characters")

    if not re.fullmatch(r"[A-Za-z0-9_]+", db_charset):
        raise ConfigurationError("DB_CHARSET contains invalid characters")

    return AppConfig(
        environment=_required("ENV"),
        encryption_key=_required("ENCRYPTION_KEY"),
        database=DatabaseConfig(
            host=_required("DB_HOST"),
            port=db_port,
            name=db_name,
            user=_required("DB_USER"),
            password=_required("DB_PASSWORD"),
            charset=db_charset,
        ),
    )