from __future__ import annotations

from collections.abc import Callable
from datetime import datetime, timezone

import bcrypt
from PySide6.QtCore import Property, QObject, QThread, Signal, Slot
from sqlalchemy import select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from database.models.p_utilisateurs import PUtilisateurs
from database.session import with_session
from services.logger import get_logger


class _AuthenticationThread(QThread):
    def __init__(self, operation: Callable[[], tuple[bool, str, str]], parent: QObject) -> None:
        super().__init__(parent)
        self._operation: Callable[[], tuple[bool, str, str]] | None = operation
        self.result = (False, "service_unavailable", "")

    def run(self) -> None:
        try:
            if self._operation is not None:
                self.result = self._operation()
        finally:
            self._operation = None


class LoginModel(QObject):
    authenticationCompleted = Signal(bool, str, str)
    busyChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._logger = get_logger(__name__)
        self._worker: _AuthenticationThread | None = None

    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return self._worker is not None

    @Slot(str, str)
    def authenticate(self, username: str, password: str) -> None:
        if self._worker is not None:
            return
        self._worker = _AuthenticationThread(lambda: self._authenticate(username, password), self)
        self._worker.finished.connect(self._complete)
        self.busyChanged.emit()
        self._worker.start()

    @Slot()
    def _complete(self) -> None:
        worker = self._worker
        if worker is None:
            return
        self._worker = None
        self.busyChanged.emit()
        self.authenticationCompleted.emit(*worker.result)
        worker.deleteLater()

    @Slot()
    def shutdown(self) -> None:
        """Finish any transaction before the application disposes the database."""
        if self._worker is not None:
            self._worker.wait()
            self._complete()

    def _authenticate(self, username: str, password: str) -> tuple[bool, str, str]:
        try:
            name = self._authenticate_user(username.strip(), password)
        except (SQLAlchemyError, RuntimeError, ValueError):
            self._logger.exception("Authentication query failed")
            return False, "service_unavailable", ""
        if name is None:
            return False, "invalid_credentials", ""
        return True, "", name

    @with_session()
    def _authenticate_user(self, username: str, password: str, *, session: Session) -> str | None:
        """The worker creates, commits and closes its own session via the decorator."""
        user = session.scalar(
            select(PUtilisateurs).where(
                PUtilisateurs.nom_utilisateur == username,
                PUtilisateurs.actif == 1,
            )
        )
        if user is None:
            return None
        try:
            matches = bcrypt.checkpw(
                password.encode("utf-8"), user.mot_de_passe_hash.encode("utf-8")
            )
        except ValueError:
            matches = False
        if not matches:
            return None
        user.date_derniere_connexion = datetime.now(timezone.utc).replace(tzinfo=None)
        return user.nom_utilisateur
