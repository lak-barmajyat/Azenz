# Git Workflow — Azenz

## Main Branch
- `main` must always remain stable and working.
- Never develop directly on `main`.
- Merge changes into `main` only through pull requests.
- Pull requests must pass required linting and tests.

## Development Branches
- Use a dedicated branch for each feature, fix, or task.
- Continue on an existing branch if it belongs to the same task.
- Use clear names, such as `feature/login`, `fix/invoice-total`, or `refactor/database-session`.
- Keep branches focused; avoid unrelated changes.

## Commits and Pull Requests
- Write short, meaningful commit messages.
- Never commit unrelated changes or sensitive information.
- Never commit, push, or merge without explicit user approval.
- Resolve conflicts and failing checks before merging.

## Existing Work
- Preserve all existing uncommitted changes.
- Never discard or overwrite another developer's work.
- Never force-push, reset destructively, or rewrite shared Git history without explicit approval.
- If existing changes conflict with the task, ask before proceeding.