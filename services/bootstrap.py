"""Application startup policy; database implementation belongs to database modules."""

from database.engine import check_database_connection, database
from database.migrations.runner import check_schema
from database.session import setup_session
from database.setup import initialize_database, manager_exists
from services.config import AppConfig, load_config


def bootstrap_application() -> AppConfig:
    config = load_config(interactive=True)
    if config.environment == "development":
        initialize_database(config.database)
    else:
        database.setup(config.database)
        check_database_connection()
        check_schema()
        if not manager_exists():
            raise RuntimeError("First Manager is missing. Run python -m database.setup init.")
    setup_session()
    return config
