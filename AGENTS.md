# Azenz — Agent Instructions

## 1. Project Overview
Azenz is a desktop ERP application built with:
- Python + PySide6 + QML
- MySQL + SQLAlchemy + Alembic
- uv for dependency management
- Ruff, Mypy, and qmllint

## 2. Global Rules
- Read relevant documentation before changing code.
- Follow existing architecture and naming conventions.
- Keep code simple, readable, and maintainable.
- Reuse existing components before creating new ones.
- Avoid unrelated changes.
- Never modify database schemas without following migration rules.
- Never commit or push unless explicitly requested.

## 3. Task-Specific Instructions
Read the relevant files before starting a task:

| Task | Instructions |
|------|--------------|
| Project structure | [architecture.md](docs/agents/architecture.md) |
| Python backend | [backend.md](docs/agents/backend.md) |
| QML frontend | [frontend.md](docs/agents/frontend.md) |
| Database | [database.md](docs/agents/database.md) |
| Git operations | [git-workflow.md](docs/agents/git-workflow.md) |

## 4. Agent Workflow
1. Understand the task.
2. Read all applicable instruction files when a task spans multiple areas.
3. Inspect existing code and patterns.
4. Implement the smallest necessary change.
5. Run relevant checks.
6. Report changes and verification results.
