# Backend Rules — Azenz

Applies to Python code in feature windows, especially `model.py`.

## Structure
- Each window has one main class in `model.py`: `<Window>Model` (e.g. `liste_ventes/model.py` → `ListeVentesModel`).
- Keep window backend logic in this class. Use small private helper methods when useful.
- Each UI action requiring Python logic starts at a clear method in this class.
- Expose QML-callable methods using PySide6 `@Slot(...)` with appropriate signatures.
- Use Qt signals and properties to communicate with QML.

## UI Communication
- Use signals to report operation success, errors, and loading state to QML.
- Distinguish validation failures from technical errors when useful.
- QML handles visual feedback (toasts, dialogs, loading indicators).
- Never manipulate QML UI elements directly from Python.

## Database
- Write database queries in `model.py` using SQLAlchemy.
- Use the existing `@with_session()` decorator for database operations, following `database/session.py`.
- Never create ad-hoc database connections or sessions.
- Keep database transactions short and use parameterized queries through SQLAlchemy.

## Threading
- Never block the UI thread with slow database or other expensive operations.
- Automatically use `QThread` or Qt workers when background execution is needed.
- Keep UI updates on the main Qt thread; communicate results using signals.
- Never share SQLAlchemy sessions across threads. Each worker must obtain its own session through the approved session mechanism.
- Do not introduce threading for quick operations.
- Clean up workers and threads correctly after completion.

## Code Quality
- Prefer the simplest correct implementation; avoid unnecessary abstractions and extra files.
- Use clear, descriptive names for classes, methods, and variables.
- Keep code concise and efficient. Avoid unreachable branches, redundant checks, and speculative edge cases.
- Handle realistic failures clearly; never hide errors silently.
- Follow the project's configured linters and formatters, including Ruff and Mypy.

## Logging
- Use the existing logger for technical errors and approved operational events.
- **Ask the project owner before adding logs for new business actions**, such as invoice creation.
- Never log credentials or sensitive data.

## Reference Implementation
- No canonical reference implementation exists yet.
- Existing implementations are not assumed to follow these rules.
- Once a compliant implementation is approved, document its exact file path here.
- Until then, follow this document as the source of truth.