from __future__ import annotations

import logging

from PySide6.QtCore import QObject, Signal, Slot

from database import session as database_session
from modules.login.repository import AuthenticationError, authenticate_user


class LoginModel(QObject):
    authenticationCompleted = Signal(bool, str, str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._logger = logging.getLogger(__name__)

    @Slot(str, str, str)
    def authenticate(self, username: str, password: str, language: str) -> None:
        """Authenticate one login attempt and notify QML of the result."""
        if database_session.session_factory is None:
            self._logger.error("Authentication requested before session initialization")
            self.authenticationCompleted.emit(
                False,
                self._message(language, "service_unavailable"),
                "",
            )
            return

        try:
            with database_session.session_factory() as session:
                user = authenticate_user(session, username, password)
        except AuthenticationError:
            self._logger.exception("Authentication query failed")
            self.authenticationCompleted.emit(
                False,
                self._message(language, "service_unavailable"),
                "",
            )
            return

        if user is None:
            self.authenticationCompleted.emit(
                False,
                self._message(language, "invalid_credentials"),
                "",
            )
            return

        self.authenticationCompleted.emit(True, "", user.nom_utilisateur)

    @staticmethod
    def _message(language: str, key: str) -> str:
        messages = {
            "fr": {
                "invalid_credentials": "Identifiant ou mot de passe incorrect.",
                "service_unavailable": "Le service d'authentification est indisponible.",
            },
            "en": {
                "invalid_credentials": "Incorrect username or password.",
                "service_unavailable": "The authentication service is unavailable.",
            },
            "ar": {
                "invalid_credentials": "اسم المستخدم أو كلمة المرور غير صحيحة.",
                "service_unavailable": "خدمة المصادقة غير متاحة.",
            },
        }
        return messages.get(language, messages["fr"])[key]