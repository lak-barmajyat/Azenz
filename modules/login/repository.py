from __future__ import annotations

from datetime import datetime, timezone

import bcrypt
from sqlalchemy import select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from database.models.p_utilisateurs import PUtilisateurs
from database.session import with_session


class AuthenticationError(RuntimeError):
    """Raised when the authentication query cannot be completed."""


@with_session()
def authenticate_user(
    username: str,
    password: str,
    *,
    session: Session,
) -> PUtilisateurs | None:
    """Return the active user matching the credentials, if one exists."""
    try:
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
                password.encode("utf-8"),
                user.mot_de_passe_hash.encode("utf-8"),
            )
        except ValueError:
            matches = False
        if not matches:
            return None

        user.date_derniere_connexion = datetime.now(timezone.utc).replace(tzinfo=None)
        return user
    except (SQLAlchemyError, ValueError) as error:
        raise AuthenticationError("Authentication service unavailable") from error
