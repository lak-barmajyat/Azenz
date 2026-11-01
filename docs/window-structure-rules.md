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

## Example: login window

- `Login.qml` is the controller.
- `LoginView.ui.qml` is the view.
- `model.py` handles authentication.
- `repository.py` queries users.
