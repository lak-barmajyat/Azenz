from collections.abc import Callable

from database.engine import (
    check_database_connection,
    check_server_connection,
    create_database,
    database,
    database_exists,
)
from database.migrations.runner import run_migrations
from database.session import setup_session
from services.config import AppConfig, load_config
from services.logger import get_logger, setup_logging


ConfirmDatabaseCreation = Callable[[str], bool]


class StartupCancelled(RuntimeError):
    pass


def bootstrap_application(
    confirm_database_creation: ConfirmDatabaseCreation,
) -> AppConfig:
    setup_logging()
    logger = get_logger(__name__)

    logger.info("Initializing Azenz")

    config = load_config()
    db_config = config.database

    check_server_connection(db_config)

    if not database_exists(db_config):
        logger.warning(
            "Database '%s' does not exist",
            db_config.name,
        )

        if not confirm_database_creation(db_config.name):
            raise StartupCancelled(
                "Database creation was cancelled by the user"
            )

        create_database(db_config)

    database.setup(db_config)

    check_database_connection()

    run_migrations()

    setup_session()

    logger.info("Application initialized successfully")

    return config