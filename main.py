import sys

from database.engine import database
from services.application import run_application
from services.bootstrap import bootstrap_application
from services.logger import get_logger, setup_logging


def main() -> int:
    setup_logging()
    logger = get_logger(__name__)
    logger.info("Starting Azenz")
    try:
        bootstrap_application()
        return run_application(sys.argv)
    except (EOFError, KeyboardInterrupt):
        logger.info("Startup cancelled; run Azenz again to resume setup")
        return 1
    except Exception as error:
        logger.error(
            "Startup failed: %s. See the log for details.",
            (str(error).splitlines() or [type(error).__name__])[0],
            exc_info=True,
        )
        return 1
    finally:
        database.close()


if __name__ == "__main__":
    sys.exit(main())
