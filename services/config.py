"""Validated application settings; only missing settings require interaction."""

import getpass
import os
import re
import secrets
from dataclasses import dataclass, field
from pathlib import Path

from dotenv import dotenv_values, set_key

from services.paths import PROJECT_ROOT

ENV_FILE = PROJECT_ROOT / ".env"
DEFAULTS = {
    "ENV": "development",
    "DB_HOST": "localhost",
    "DB_PORT": "3306",
    "DB_NAME": "azenz_commercial",
    "DB_USER": "azenz",
    "DB_PASSWORD": "12345678",
    "DB_CHARSET": "utf8mb4",
}
SECRET_KEYS = {"DB_PASSWORD", "ENCRYPTION_KEY"}


class ConfigurationError(ValueError):
    pass


@dataclass(frozen=True)
class DatabaseConfig:
    host: str
    port: int
    name: str
    user: str
    password: str = field(repr=False)
    charset: str


@dataclass(frozen=True)
class AppConfig:
    environment: str
    encryption_key: str = field(repr=False)
    database: DatabaseConfig


def _validate(key: str, value: str) -> str:
    if not value:
        raise ConfigurationError(f"{key} is required")
    if key == "ENV" and value not in {"development", "production"}:
        raise ConfigurationError("ENV must be development or production")
    if key == "DB_PORT" and (not value.isdecimal() or not 1 <= int(value) <= 65535):
        raise ConfigurationError("DB_PORT must be between 1 and 65535")
    if key in {"DB_NAME", "DB_CHARSET"} and not re.fullmatch(r"[A-Za-z0-9_]+", value):
        raise ConfigurationError(f"{key} must contain only letters, numbers, and underscores")
    return value


def load_config(*, interactive: bool = False, env_file: Path | None = None) -> AppConfig:
    path = env_file or ENV_FILE
    saved = dotenv_values(path)
    keys = [
        "ENV",
        "DB_HOST",
        "DB_PORT",
        "DB_NAME",
        "DB_USER",
        "DB_PASSWORD",
        "DB_CHARSET",
        "ENCRYPTION_KEY",
    ]
    values: dict[str, str] = {}
    missing = [key for key in keys if not os.environ.get(key, saved.get(key) or "")]
    if interactive and missing:
        for key in keys:
            current = os.environ.get(key, saved.get(key) or "")
            if current and key not in SECRET_KEYS:
                print(f"{key}={current}")
    for key in keys:
        value = os.environ.get(key, saved.get(key) or "")
        if not value:
            if not interactive:
                raise ConfigurationError(f"Missing {key}. Run python -m database.setup init.")
            default = DEFAULTS.get(key, "")
            if key == "ENCRYPTION_KEY":
                default = secrets.token_urlsafe(32)
            while True:
                if key in SECRET_KEYS:
                    value = getpass.getpass(f"{key} [Enter to use setup default]: ") or default
                else:
                    value = input(f"{key} [{default}]: ").strip() or default
                try:
                    _validate(key, value)
                    break
                except ConfigurationError as error:
                    print(error)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.touch(mode=0o600, exist_ok=True)
            path.chmod(0o600)
            set_key(str(path), key, value)
        values[key] = _validate(key, value)
    if values["ENV"] == "development" and values["DB_HOST"] not in {
        "localhost",
        "127.0.0.1",
        "::1",
    }:
        raise ConfigurationError(
            "Development requires a local DB_HOST; use production for a server."
        )
    return AppConfig(
        environment=values["ENV"],
        encryption_key=values["ENCRYPTION_KEY"],
        database=DatabaseConfig(
            host=values["DB_HOST"],
            port=int(values["DB_PORT"]),
            name=values["DB_NAME"],
            user=values["DB_USER"],
            password=values["DB_PASSWORD"],
            charset=values["DB_CHARSET"],
        ),
    )
