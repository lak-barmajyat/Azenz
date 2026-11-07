from alembic import command
from alembic.config import Config


def run_migrations() -> None:
    config = Config()
    config.set_main_option("script_location", "database/migrations")
    command.upgrade(config, "head")
