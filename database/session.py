from collections.abc import Callable
from typing import Any


def setup_session() -> None:
    """
    Configure the global SQLAlchemy session factory.

    Use `database.engine` internally.

    Must be called once during application startup.
    """
    pass


def with_session() -> Callable[..., Any]:
    """
    Decorate a repository function with a SQLAlchemy Session.

    The implementation should:

    1. Create a Session.
    2. Pass it to the function as `session`.
    3. Commit on success.
    4. Roll back on failure.
    5. Always close the Session.

    Example:

        @with_session()
        def create_user(name: str, session=None):
            ...
    """
    pass