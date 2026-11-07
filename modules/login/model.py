from __future__ import annotations

import logging

from PySide6.QtCore import QObject, Signal, Slot

from modules.login.repository import AuthenticationError, authenticate_user


class LoginModel(QObject):
    authenticationCompleted = Signal(bool, str, str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._logger = logging.getLogger(__name__)

    @Slot(str, str, str)
    def authenticate(self, username: str, password: str, language: str) -> None:
        """Authenticate one login attempt and notify QML of the result."""
        try:
            user = authenticate_user(username, password)
        except (AuthenticationError, RuntimeError):
            self._logger.exception("Authentication query failed")
            self.authenticationCompleted.emit(
                False,
                "service_unavailable",
                "",
            )
            return

        if user is None:
            self.authenticationCompleted.emit(
                False,
                "invalid_credentials",
                "",
            )
            return

        self.authenticationCompleted.emit(True, "", user.nom_utilisateur)
