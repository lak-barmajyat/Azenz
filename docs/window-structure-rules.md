# Window structure rules

For every window:

- `<Window>.qml`: controller; handles UI events and emits feature signals.
- `<Window>View.ui.qml`: view; contains visual components and layout. Use
  `qsTr()` for all user-facing text.
- `model.py`: business logic and Qt/Python bridge.
- `repository.py`: database access through SQLAlchemy. Use `@with_session()`
  from `database/session.py` for session lifecycle and transactions.
- `__init__.py`: marks the directory as a Python package.
- `main.py`: optional standalone development runner.

The application creates the model, attaches it to the window, and connects
model signals to controller completion handlers.

Every feature window must be implemented as a standalone frame. The shell
owns the application chrome and displays each feature frame in its central
content area; feature windows must not duplicate the shell toolbar, sidebar,
or footer.

The shared shell is a special window container:

- `Shell.qml` controls navigation and keeps the toolbar, sidebar, footer, and
  central frame alive.
- `ShellView.ui.qml` contains that fixed chrome and exposes `contentFrame`.
- Feature windows are loaded into `contentFrame`; dashboard is the empty
  default page.
- A shell without database access does not need `model.py` or `repository.py`.

## Example: login window

- `Login.qml` is the controller.
- `LoginView.ui.qml` is the view.
- `model.py` handles authentication.
- `repository.py` queries users.
