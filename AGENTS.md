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
- Run `make check` after any edit.
- Never modify database schemas without following migration rules.
- Never commit or push unless explicitly requested.

### Git Hygiene Reminders
- Before making changes, check the current branch and working tree.
- Alert the user before editing if the current branch is `main`, belongs to a different task, or already contains changes that should be isolated. Recommend creating or switching to a task-specific branch, but never do so without explicit approval.
- When a coherent unit of work is complete and verified, remind the user that it is a good time to commit. Suggest a concise commit message, but never commit without explicit approval.
- If unrelated uncommitted changes are present, point them out and keep the new work separate. Do not overwrite, discard, stash, or include them in a commit without explicit approval.
- Give these reminders when they become relevant; do not wait for the user to ask about Git hygiene.

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
