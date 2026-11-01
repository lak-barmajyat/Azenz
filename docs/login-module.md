# Login window structure

- `Login.qml`: controller; validates input and emits login signals.
- `LoginView.ui.qml`: visual window and controls; use `qsTr()` for UI text.
- `model.py`: Qt/Python bridge; calls the repository and reports results.
- `repository.py`: SQLAlchemy authentication query; use `@with_session()`
  from `database/session.py` for session lifecycle and transactions.
- `__init__.py`: marks the directory as a Python package.
- `main.py`: standalone development runner for the login window.

The application creates `LoginModel`, attaches it to the QML window, and
connects `authenticationCompleted` to `Login.completeAuthentication()`.
