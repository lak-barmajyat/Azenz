import re
import sys
from pathlib import Path

from sqlalchemy import text
from sqlalchemy.exc import OperationalError

from database.engine import (
    create_database,
    database,
    drop_database,
)
from services.config import load_config

DEMO_DATA_FILE = Path(__file__).parent / "schema" / "azenz_commercial_demo.sql"


def load_demo_data() -> None:
    if not DEMO_DATA_FILE.exists():
        raise FileNotFoundError(f"Demo data file not found: {DEMO_DATA_FILE}")

    statements = _split_sql(DEMO_DATA_FILE.read_text(encoding="utf-8-sig"))
    with database.engine.begin() as connection:
        for statement in statements:
            statement = re.sub(r"^(?:\s*--[^\n]*(?:\n|$))+", "", statement).strip()
            if statement.upper().startswith(("SET ", "START TRANSACTION", "COMMIT", "USE ")):
                continue
            connection.execute(text(statement))


def _split_sql(sql: str) -> list[str]:
    statements: list[str] = []
    buffer: list[str] = []
    quote: str | None = None
    escaped = False

    for character in sql:
        if quote is not None:
            buffer.append(character)
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = None
            continue

        if character in {"'", '"', "`"}:
            quote = character
            buffer.append(character)
        elif character == ";":
            statement = "".join(buffer).strip()
            if statement:
                statements.append(statement)
            buffer.clear()
        else:
            buffer.append(character)

    statement = "".join(buffer).strip()
    if statement:
        statements.append(statement)
    return statements


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in {"create", "destroy", "demo"}:
        raise SystemExit("Usage: python -m database.setup [create|destroy|demo]")

    config = load_config().database
    action = sys.argv[1]

    if action == "create":
        try:
            create_database(config)
        except OperationalError as error:
            print(
                "Database creation failed. Check that MySQL/MariaDB is running and "
                "the database connection settings are correct. "
                f"Details: {error.orig}",
                file=sys.stderr,
            )
            raise SystemExit(1) from None
        return

    if action == "demo":
        load_demo_data()
        return

    print(f"This will permanently delete '{config.name}'.")
    if input(f"Type '{config.name}' to continue: ").strip() == config.name:
        drop_database(config)
        print(f"Deleted '{config.name}'.")
    else:
        print("Cancelled.")


if __name__ == "__main__":
    main()
