from pathlib import Path

from alembic import command
from alembic.autogenerate import compare_metadata
from alembic.config import Config
from alembic.migration import MigrationContext
from alembic.script import ScriptDirectory
from sqlalchemy import Engine, inspect

from database.engine import database
from database.models import Base

MIGRATIONS_DIR = Path(__file__).resolve().parent


class SchemaError(RuntimeError):
    pass


def migration_config() -> Config:
    config = Config()
    config.set_main_option("script_location", str(MIGRATIONS_DIR))
    return config


def run_migrations(engine: Engine | None = None) -> None:
    engine = engine or database.engine
    config = migration_config()
    with engine.connect() as connection:
        context = MigrationContext.configure(connection)
        if not context.get_current_heads():
            # Resume partial initial DDL, but never silently adopt an incompatible schema.
            differences = compare_metadata(context, Base.metadata)
            if any(
                not isinstance(diff, tuple) or diff[0] not in {"add_table", "add_index"}
                for diff in differences
            ):
                raise SchemaError(
                    "Existing unversioned schema differs from the models. "
                    "Review/baseline it before running setup; no tables were overwritten."
                )
        connection.commit()
        config.attributes["connection"] = connection
        command.upgrade(config, "head")
    check_schema(engine)


def check_schema(engine: Engine | None = None) -> None:
    engine = engine or database.engine
    expected = set(ScriptDirectory.from_config(migration_config()).get_heads())
    with engine.connect() as connection:
        actual = set(MigrationContext.configure(connection).get_current_heads())
        if not expected or actual != expected:
            raise SchemaError(
                "Database migrations are required. Run python -m database.setup init."
            )
        missing = set(Base.metadata.tables) - set(inspect(connection).get_table_names())
        if missing:
            raise SchemaError(
                f"Database tables are missing: {', '.join(sorted(missing))}. "
                "Run python -m database.setup init or restore the schema."
            )
