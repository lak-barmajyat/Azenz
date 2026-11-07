"""Connections and non-destructive database/account provisioning."""

import re
from dataclasses import replace

from sqlalchemy import Engine, create_engine, text
from sqlalchemy.engine import URL
from sqlalchemy.exc import OperationalError

from services.config import DatabaseConfig


class Database:
    def __init__(self) -> None:
        self._engine: Engine | None = None

    @property
    def engine(self) -> Engine:
        if self._engine is None:
            raise RuntimeError("Database engine is not initialized")
        return self._engine

    def setup(self, config: DatabaseConfig) -> None:
        self.close()
        self._engine = make_engine(config)

    def close(self) -> None:
        if self._engine is not None:
            self._engine.dispose()
            self._engine = None


database = Database()


def database_url(config: DatabaseConfig, *, include_database: bool = True) -> URL:
    return URL.create(
        "mysql+pymysql",
        username=config.user,
        password=config.password,
        host=config.host,
        port=config.port,
        database=config.name if include_database else None,
        query={"charset": config.charset},
    )


def make_engine(
    config: DatabaseConfig, *, include_database: bool = True, socket: str = ""
) -> Engine:
    options: dict = {"connect_timeout": 5}
    if socket:
        options["unix_socket"] = socket
    return create_engine(
        database_url(config, include_database=include_database),
        connect_args=options,
        pool_pre_ping=True,
        hide_parameters=True,
    )


def check_database_connection() -> None:
    with database.engine.connect() as connection:
        connection.execute(text("SELECT 1"))


def provisioning_required(config: DatabaseConfig) -> bool:
    """Try the application connection first; never request admin for a stopped server."""
    engine = make_engine(config)
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
            scopes = {f"`{config.name}`.*", "*.*"}
            grants: list[str] = list(connection.execute(text("SHOW GRANTS")).scalars())
            for grant in grants:
                normalized = grant.replace(r"\_", "_")
                if any(f"ALL PRIVILEGES ON {scope} TO " in normalized for scope in scopes):
                    return False
            return True
    except OperationalError as error:
        if error.orig is not None and error.orig.args[0] in {1044, 1045, 1049, 1130}:
            return True
        raise
    finally:
        engine.dispose()


def provision_database(
    config: DatabaseConfig,
    admin_user: str,
    admin_password: str,
    *,
    account_host: str,
    socket: str = "",
) -> bool:
    """Create missing objects, preserve existing passwords, grant only this database."""
    for identifier in (config.name, config.charset):
        if not re.fullmatch(r"[A-Za-z0-9_]+", identifier):
            raise ValueError("Invalid database name or charset")
    if admin_user == config.user:
        raise ValueError("The application user must be separate from the administrator")
    admin = make_engine(
        replace(config, user=admin_user, password=admin_password),
        include_database=False,
        socket=socket,
    )
    try:
        with admin.begin() as connection:
            existed = (
                connection.scalar(
                    text("SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME=:name"),
                    {"name": config.name},
                )
                is not None
            )
            connection.execute(
                text(
                    f"CREATE DATABASE IF NOT EXISTS `{config.name}` "
                    f"CHARACTER SET `{config.charset}`"
                )
            )
            params = {"user": config.user, "host": account_host, "password": config.password}
            exists = connection.scalar(
                text("SELECT 1 FROM mysql.user WHERE User=:user AND Host=:host"), params
            )
            if exists is None:
                connection.execute(text("CREATE USER :user@:host IDENTIFIED BY :password"), params)
            # GRANT database identifiers treat underscores as wildcards unless escaped.
            grant_name = config.name.replace("_", r"\_")
            connection.execute(
                text(f"GRANT ALL PRIVILEGES ON `{grant_name}`.* TO :user@:host"), params
            )
            return not existed
    finally:
        admin.dispose()
