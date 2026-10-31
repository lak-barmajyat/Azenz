run:
	@uv run python main.py

qmllint:
	@output="$$(script -qec 'uv run pyside6-project qmllint' /dev/null 2>&1)"; \
	status=$$?; \
	if [ $$status -ne 0 ] || printf '%s\n' "$$output" | grep -Eq "returned [1-9][0-9]*"; then \
		printf '%s\n' "$$output" \
			| sed "s|$$(pwd)/||g" \
			| grep -Ev '^pyside6-(qmllint|rcc) '; \
		exit 1; \
	fi

lint: qmllint
	@uv run ruff check .
	@uv run ruff format --check .
	@uv run mypy main.py modules database services

test:
	@uv run pytest

check: lint test

create-database:
	@uv run python -m database.setup create

destroy-database:
	@uv run python -m database.setup destroy

load-demo-data:
	@uv run python -m database.setup demo

create-migration:
	@uv run alembic revision --autogenerate -m "initial schema"

apply-migrations:
	@uv run alembic upgrade head

show-current-revision:
	@uv run alembic current

show-migration-history:
	@uv run alembic history

check-migrations:
	@uv run alembic check
