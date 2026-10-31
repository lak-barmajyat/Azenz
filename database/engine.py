import re

from sqlalchemy import Engine, create_engine, text
from sqlalchemy.engine import URL

from services.config import DatabaseConfig


class Database:
    def __init__(self) -> None:
        self._engine: Engine | None = None
        self._config: DatabaseConfig | None = None

    @property
    def engine(self) -> Engine:
        """Return the initialized SQLAlchemy engine."""
        if self._engine is None:
            raise RuntimeError("Database engine is not initialized")

        return self._engine

    @property
    def config(self) -> DatabaseConfig:
        """Return the active database configuration."""
        if self._config is None:
            raise RuntimeError("Database is not initialized")

        return self._config

    def setup(self, config: DatabaseConfig) -> None:
        self._config = config
        self._engine = create_engine(_database_url(config))


database = Database()


def check_server_connection(config: DatabaseConfig) -> None:
    """Check whether the MySQL server can be reached."""
    engine = create_engine(_database_url(config, include_database=False))
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    finally:
        engine.dispose()


def database_exists(config: DatabaseConfig) -> bool:
    """Return True if the configured database exists."""
    engine = create_engine(_database_url(config, include_database=False))
    try:
        with engine.connect() as connection:
            result = connection.execute(
                text("SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = :name"),
                {"name": config.name},
            )
            return result.scalar() is not None
    finally:
        engine.dispose()


def create_database(config: DatabaseConfig) -> None:
    """Create the configured database."""
    _validate_identifier(config.name)
    _validate_identifier(config.charset)
    engine = create_engine(_database_url(config, include_database=False))
    try:
        with engine.begin() as connection:
            connection.execute(
                text(
                    f"CREATE DATABASE IF NOT EXISTS `{config.name}` "
                    f"CHARACTER SET `{config.charset}`"
                )
            )
    finally:
        engine.dispose()


def drop_database(config: DatabaseConfig) -> None:
    """Drop the configured database."""
    _validate_identifier(config.name)
    engine = create_engine(_database_url(config, include_database=False))
    try:
        with engine.begin() as connection:
            connection.execute(text(f"DROP DATABASE IF EXISTS `{config.name}`"))
    finally:
        engine.dispose()


def check_database_connection() -> None:
    """
    Check whether the application database can be reached.

    Use `database.engine` internally.
    """
    with database.engine.connect() as connection:
        connection.execute(text("SELECT 1"))


def _database_url(
    config: DatabaseConfig,
    *,
    include_database: bool = True,
) -> URL:
    return URL.create(
        "mysql+pymysql",
        username=config.user,
        password=config.password,
        host=config.host,
        port=config.port,
        database=config.name if include_database else None,
        query={"charset": config.charset},
    )


def _validate_identifier(value: str) -> None:
    if not re.fullmatch(r"[A-Za-z0-9_]+", value):
        raise ValueError(f"Invalid database identifier: {value}")
