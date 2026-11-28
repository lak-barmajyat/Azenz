from __future__ import annotations


class UserSession:
    """In-memory identity shared by authentication and business models."""

    def __init__(self) -> None:
        self._user_id: int | None = None

    @property
    def user_id(self) -> int | None:
        return self._user_id

    def authenticate(self, user_id: int) -> None:
        if user_id <= 0:
            raise ValueError("Invalid user id")
        self._user_id = user_id

    def clear(self) -> None:
        self._user_id = None
