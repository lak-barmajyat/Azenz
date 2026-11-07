from collections.abc import Callable
from functools import wraps
from typing import Any

from sqlalchemy.orm import Session, sessionmaker

from database.engine import database

session_factory: sessionmaker[Session] | None = None


def setup_session() -> None:
    global session_factory
    session_factory = sessionmaker(bind=database.engine, expire_on_commit=False)


def with_session() -> Callable[..., Any]:
    def decorator(function: Callable[..., Any]) -> Callable[..., Any]:
        @wraps(function)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            if session_factory is None:
                raise RuntimeError("Session factory is not initialized")

            session = session_factory()
            kwargs["session"] = session
            try:
                result = function(*args, **kwargs)
                session.commit()
                return result
            except Exception:
                session.rollback()
                raise
            finally:
                session.close()

        return wrapper

    return decorator
