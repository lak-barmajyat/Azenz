from sqlalchemy import Engine

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
        """
        Create and store the SQLAlchemy engine.

        Fatima will implement this after learning SQLAlchemy Engine.
        """
        pass


database = Database()


def check_server_connection(config: DatabaseConfig) -> None:
    """Check whether the MySQL server can be reached."""
    pass


def database_exists(config: DatabaseConfig) -> bool:
    """Return True if the configured database exists."""
    pass


def create_database(config: DatabaseConfig) -> None:
    """Create the configured database."""
    pass


def check_database_connection() -> None:
    """
    Check whether the application database can be reached.

    Use `database.engine` internally.
    """
    pass