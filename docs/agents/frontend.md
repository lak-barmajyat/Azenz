# Frontend Rules — Azenz

## Priorities
- Prioritize clean, maintainable, native Qt/QML architecture over pixel-perfect Figma matching.
- Accept small visual differences when required by existing components or Qt best practices.
- Keep QML simple and efficient. Avoid unnecessary objects, bindings, JavaScript, and abstractions.

## Window Files
- `<Window>View.ui.qml` — Visual layout, properties, and signals compatible with Qt Design Studio. No business logic or JavaScript event handlers.
- `<Window>.qml` — UI controller. Connects UI signals to Python `@Slot` methods, handles UI behavior, and displays feedback.
- `model.py` — Owns business logic, database operations, and Python–QML communication.
- Use `qsTr()` for all user-facing text.

## Components and Theme
- Check `qml/controls/`, `qml/components/`, `qml/layouts/`, and `qml/theme/` before creating new UI elements.
- Reuse existing components and theme values whenever available.
- `qml/controls/` — Shared input controls.
- `qml/components/` — Shared UI components.
- `qml/layouts/` — Shared layout components.
- `qml/theme/` — Colors, typography, and other design values.
- Do not create standalone components for one-time use unless complexity justifies a local component.
- Name components using `PascalCase.qml`.

## Communication and State
- Use signals for events between components; avoid accessing another component's internal IDs.
- Use properties and bindings for state and data updates.
- Keep JavaScript limited to UI behavior in `.qml`.
- Keep all ERP business logic in Python.
- Python emits success/error signals; `.qml` handles visual feedback.

## Figma HTML/CSS → QML
- Treat HTML/CSS as a visual reference, not an implementation template.
- Use native QML layouts, controls, properties, bindings, and signals.
- Prefer existing Azenz components over recreating HTML/CSS elements.
- Never introduce unnecessary complexity solely to match visual details.

## Sizing
- Feature frames must adapt to the shell's available content area.
- Prefer QML layouts and anchors over fixed positioning.
- Avoid unnecessary fixed dimensions.
- Define minimum sizes only when required.
- The shell controls the available space; feature frames must not resize it.

## Verification
- Run `make qmllint` after QML changes.
- Run `make check` for full validation (includes QML linting, Python linting, and type checking).
- On Windows, use `make win-check` if Make is available.
- Keep `.ui.qml` files compatible with Qt Design Studio.
- Open modified `.ui.qml` files in Qt Design Studio when possible.
- Fix relevant errors before completing work.
- Never claim Qt Design Studio compatibility without checking it.