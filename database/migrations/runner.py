from alembic import command
from alembic.config import Config
from sqlalchemy import inspect

from database.engine import database
from database.models import Base


def run_migrations() -> bool:
    schema_exists = inspect(database.engine).has_table("p_utilisateurs")
    config = Config()
    config.set_main_option("script_location", "database/migrations")
    command.upgrade(config, "head")
    Base.metadata.create_all(bind=database.engine)
    return not schema_exists
