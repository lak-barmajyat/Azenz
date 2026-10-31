from alembic import context

from database.engine import database
from database.models import Base
from services.config import load_config

target_metadata = Base.metadata


try:
    database.engine
except RuntimeError:
    database.setup(load_config().database)


def run_migrations_offline() -> None:
    context.configure(url=str(database.engine.url), target_metadata=target_metadata)

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    with database.engine.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
