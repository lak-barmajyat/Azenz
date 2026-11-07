from alembic import context

from database.engine import database_url, make_engine
from database.models import Base
from services.config import load_config


def run(connection) -> None:
    context.configure(connection=connection, target_metadata=Base.metadata, compare_type=True)
    with context.begin_transaction():
        context.run_migrations()


if context.is_offline_mode():
    context.configure(
        url=database_url(load_config().database), target_metadata=Base.metadata, literal_binds=True
    )
    with context.begin_transaction():
        context.run_migrations()
else:
    supplied = context.config.attributes.get("connection")
    if supplied is not None:
        run(supplied)
    else:
        engine = make_engine(load_config().database)
        try:
            with engine.connect() as connection:
                run(connection)
        finally:
            engine.dispose()
