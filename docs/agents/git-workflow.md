# Git Workflow — Azenz

Read this file before changing any file or performing a Git operation.

## Before Editing
- Check the current branch and working tree.
- Alert the user before editing if the branch is `main`, belongs to another task, or contains changes that should be isolated.
- Recommend creating or switching to a task-specific branch when needed, but never switch branches without explicit approval.
- Point out unrelated uncommitted changes and keep new work separate.

## Main Branch
- `main` must always remain stable and working.
- Never develop directly on `main`.
- Merge changes into `main` only through pull requests.
- Pull requests must pass required linting checks.

## Development Branches
- Use a dedicated branch for each feature, fix, or task.
- Continue on an existing branch if it belongs to the same task.
- Use clear names, such as `feature/login`, `fix/invoice-total`, or `refactor/database-session`.
- Keep branches focused; avoid unrelated changes.

## Commits and Pull Requests
- When a coherent unit of work is complete and verified, remind the user that it is a good time to commit.
- Suggest a concise Conventional Commit message with an appropriate type, such as `feat`, `fix`, `docs`, `style`, `refactor`, `test`, or `chore`.
- Never commit unrelated changes or sensitive information.
- Never commit, push, or merge without explicit user approval.
- Resolve conflicts and failing checks before merging.

## Existing Work
- Preserve all existing uncommitted changes.
- Never discard, overwrite, stash, or commit another developer's work without explicit approval.
- Never force-push, reset destructively, or rewrite shared Git history without explicit approval.
- If existing changes conflict with the task, ask before proceeding.
