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
from database.setup import DEMO_DATA_FILE, load_demo_data
from services.config import AppConfig, load_config
from services.logger import get_logger, setup_logging

ConfirmDatabaseCreation = Callable[[str], bool]
ConfirmDemoData = Callable[[], bool]


class StartupCancelled(RuntimeError):
    pass


def bootstrap_application(
    confirm_database_creation: ConfirmDatabaseCreation,
    confirm_demo_data: ConfirmDemoData,
) -> AppConfig:
    # Configure logging first so every startup step is visible to the user.
    setup_logging()
    logger = get_logger(__name__)

    logger.info("Initializing Azenz")

    # Load and validate the application and database settings from .env.
    config = load_config()
    db_config = config.database

    # Check the server before attempting database-specific operations.
    check_server_connection(db_config)

    database_created = False
    if not database_exists(db_config):
        # A missing database requires explicit user confirmation before creation.
        logger.warning(
            "Database '%s' does not exist",
            db_config.name,
        )

        if not confirm_database_creation(db_config.name):
            raise StartupCancelled("Database creation was cancelled by the user")

        create_database(db_config)
        database_created = True

    # Create the SQLAlchemy engine for the configured application database.
    database.setup(db_config)

    # Confirm that the application can connect to the selected database.
    check_database_connection()

    # Apply all pending Alembic revisions before the application uses the models.
    schema_created = run_migrations()

    # Offer demo data for a new database or an existing database missing its schema.
    if (
        (database_created or schema_created)
        and DEMO_DATA_FILE.exists()
        and confirm_demo_data()
    ):
        load_demo_data()

    # Sessions must be configured after the database engine is ready.
    setup_session()

    logger.info("Application initialized successfully")

    return config
