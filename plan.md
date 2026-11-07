Azenz — Startup & Database Plan
Rules
- Development: MySQL runs locally. python main.py automatically sets up a missing database and applies pending Alembic migrations.
- Production: MySQL runs on a server. Provisioning and migrations run only through python -m database.setup init; normal app startup never changes the schema.
- MySQL must already be installed and running. Never drop or overwrite an existing database or user data.
First-time setup (development automatically; production via command)
1. Initialize console + rotating-file logging; load .env. For missing settings, prompt in terminal. Show existing non-secret .env values as defaults; save new values to .env. Mask passwords. Never store MySQL administrator credentials.
2. Ask for administrator credentials only if database/user provisioning is required.
3. Create database azenz_commercial and MySQL user azenz with password 12345678 if missing; grant azenz all privileges on azenz_commercial only (not global server privileges). Do not change an existing user's password silently.
4. Connect using the application user and run Alembic upgrade head. The initial schema is one Alembic revision generated from the 14 SQLAlchemy models. Keep schema .sql as reference only; do not execute it at startup.
5. On a new database only, offer optional demo import from database/schema/azenz_commercial_demo.sql (repair/validate the demo file first). Demo data is not an Alembic migration. No reference/seed data is inserted when demo is declined.
6. Always create the first Manager application account, even without demo. Prompt for credentials, hash the password, and skip creation if a Manager already exists.
7. Initialize SQLAlchemy session factory and continue to the QML application. All setup steps must be safe to retry without duplicated data.
Subsequent startup
- Development: load config → check MySQL connectivity → apply pending migrations → initialize sessions → open QML.
- Production: load config → check connectivity and schema version → initialize sessions → open QML. If migrations are needed, stop with an actionable terminal error and require the setup command.
- On failure, print a short terminal message, write full details to log, and exit; do not start QML with an unusable database.
File responsibilities
- main.py: log application start, call bootstrap, launch Qt/QML; keep minimal.
- services/bootstrap.py: orchestrate startup based on environment; no raw SQL.
- services/config.py: validate and prompt for .env settings; persist changed values.
- database/setup.py: first-run provisioning CLI, optional demo import, initial Manager creation.
- database/engine.py: SQLAlchemy engine, server/DB connection checks, create DB/user/grants.
- database/migrations/versions/: initial schema revision and all later revisions.
- database/migrations/env.py, runner.py: Alembic configuration and upgrades.
- database/session.py: session factory and transaction lifecycle.
Implementation order
1. Validate all 14 SQLAlchemy models and Alembic model imports.
2. Build/test the one initial migration on a fresh database.
3. Implement config + provisioning + demo + Manager creation.
4. Implement environment-specific bootstrap + minimal main.py.
5. Add tests: fresh install, repeated startup, missing .env, demo/no-demo, existing DB, failed connection, production migration guard.
Important: The fixed MySQL password and broad DB privileges are accepted for this version by project decision; revisit before real production deployment.