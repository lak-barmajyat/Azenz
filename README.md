# Azenz

Desktop ERP system for small, medium, and large businesses.

## Startup

MySQL or MariaDB must already be installed and running. Install Python dependencies
with `uv sync`.

- **Development (`ENV=development`):** `make run` (or `uv run python main.py`)
  initializes a missing database/account, applies pending migrations, and opens QML.
- **Production (`ENV=production`):** run `uv run python -m database.setup init`
  from an interactive terminal to provision/migrate first. Normal startup only
  checks connectivity, schema version, and Manager presence; it never provisions
  or migrates. `make init-database` invokes the same setup command.

Missing `.env` values are requested in the terminal and saved. Existing values
are retained; passwords are entered without echo. Environment variables override
`.env`. Defaults are database `azenz_commercial`, application database user
`azenz`, password `12345678`, port `3306`, and charset `utf8mb4`.

Administrator credentials are requested only when provisioning is needed and
are never saved. For a remote server, the account-host prompt refers to the
**client machine allowed to connect**, not the database server hostname. Local
socket authentication is supported when the administrator permits the current
OS user to authenticate that way. Existing database-user passwords are never reset;
if authentication fails, correct `DB_PASSWORD` or the account's access separately.

These database credentials are separate from the **Manager application login**.
Setup prompts for the first Manager's username, email, and password, stores a
bcrypt hash, and skips creation if a Manager already exists.

Optional demo data is offered only when setup creates a new database. Declining
it inserts no reference/demo rows; the first Manager is still created. Demo users
are inactive and cannot log in. Demo import is transactional and refuses populated
tables. A retry after a database has already been created does not offer demo data
again; migrations and first-Manager setup still resume.

The initial Alembic revision creates all 14 model tables. SQL files under
`database/schema/` are references/fixtures, not startup schema scripts. Compatible
partial initial schemas can resume; incompatible unversioned schemas stop for
manual review, without overwriting tables or data. Destructive setup commands
are not provided. `database/legacy/` is historical and is not called by startup.

Startup errors are short in the terminal, with tracebacks in the rotating log;
the log path is printed at launch. QML opens only after database readiness checks.

The fixed development database password and database-wide application grants are
intentional for this version, as recorded in `plan.md`.

## Checks

```sh
uv run ruff check .
uv run ruff format --check .
uv run mypy main.py modules database services
QT_QPA_PLATFORM=offscreen uv run pytest -q
make qmllint
```

Database integration tests are opt-in and require a **disposable test server**:

```sh
AZENZ_TEST_MYSQL_URL='mysql+pymysql://root@localhost/?unix_socket=/path/to/test.sock' \
  QT_QPA_PLATFORM=offscreen uv run pytest -q
```

They create uniquely named test databases/accounts and remove those test objects
at teardown. They never read the application `.env` for a test connection.
