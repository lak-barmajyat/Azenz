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

### Role and Scope Boundaries
- Infer the agent's role from the user's prompt and the task context when it is clear; do not ask the user to restate an obvious role.
- Ask for the intended role only when the request is ambiguous and the answer would change which project areas may be edited.
- A frontend task is limited to QML views, UI controllers, and shared frontend components. It must not modify Python models, services, database code, migrations, or backend tests unless the user explicitly expands the scope.
- Frontend changes must preserve the existing Python–QML contract. If a new component is incompatible, adapt it in QML when practical; otherwise explain the required backend change and obtain explicit approval before making it.
- A backend task must not redesign or replace frontend components unless explicitly requested.
- Tasks explicitly described as full-stack, integration, or cross-layer work may span both frontend and backend after reading all applicable instructions.

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
