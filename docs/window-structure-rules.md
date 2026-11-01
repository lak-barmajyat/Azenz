# Window structure rules

- `<Window>.qml`: controller; validates input and emits feature signals.
- `<Window>View.ui.qml`: visual window and controls; use `qsTr()` for UI text.
- `model.py`: Qt/Python bridge; calls the feature logic and reports results.
- `repository.py`: SQLAlchemy database access; use `@with_session()` from
  `database/session.py` for session lifecycle and transactions.
- `__init__.py`: marks the directory as a Python package.
- `main.py`: standalone development runner for the window.

The application creates the feature model, attaches it to the QML window, and
connects model signals to controller completion handlers.
