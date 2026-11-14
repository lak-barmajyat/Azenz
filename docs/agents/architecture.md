# Azenz Architecture

## Project Structure

- `modules/` — Independent application features.
- `qml/` — Shared QML components, controls, layouts, and theme.
- `services/` — Shared Python infrastructure (configuration, logging, startup).
- `database/` — SQLAlchemy models, sessions, and Alembic migrations.
- `resources/` — Fonts, images, and icons.
- `i18n/` — Translations.

## Modules and Windows

- Each feature has its own folder under `modules/`.
- Single-window modules keep window files directly in their folder.
- Multi-window modules use one subfolder per window.
- Folder names use `snake_case`.
- Window class/file names use the folder name converted to `PascalCase`.

Each window has four default files:

| File | Responsibility |
|---|---|
| `<Window>.qml` | UI controller, events, and Python integration |
| `<Window>View.ui.qml` | Visual layout, Qt Design Studio compatible |
| `model.py` | `<Window>Model` class, business logic, SQLAlchemy queries, and Qt bridge |
| `main.py` | Standalone development/testing launcher |

Example: `liste_ventes/` contains `ListeVentes.qml`, `ListeVentesView.ui.qml`, `model.py`, and `main.py`.

Add `__init__.py` for Python packages. Additional files are allowed when justified.

## Architecture Rules

- Keep business logic and database queries in Python, not QML.
- Use the shared database session.
- Do not import another window's `model.py` directly.
- Do not place window-specific business logic in `services/`.
- Reuse existing shared components and services.
- Feature windows are standalone frames without duplicated application chrome.
- The shell owns the toolbar, sidebar, footer, and central content area.

## Application Wiring

- Root `main.py` coordinates application startup.
- Python creates each required `<Window>Model` instance.
- Expose models to QML using `QQmlContext.setContextProperty()` before loading the QML component that uses them.
- Name context properties `<windowName>Model`, e.g. `loginModel`.
- Keep Python model instances alive while their windows use them.
- `<Window>.qml` calls exposed model methods decorated with `@Slot`.
- Python signals communicate results and errors to QML.
- Window-level `main.py` uses the same setup for standalone testing.

## Module Communication

- Modules must not import another window's internal implementation.
- When cross-module communication is needed, define an explicit public interface before implementing it.