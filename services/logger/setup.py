import copy
import logging
from logging.handlers import RotatingFileHandler

from services.paths import logs_dir

LOG_FORMAT = "%(asctime)s | %(levelname)s | %(name)s | %(message)s"


class ConsoleFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        short = copy.copy(record)
        short.exc_info = None
        short.exc_text = None
        return super().format(short)


def setup_logging() -> None:
    root_logger = logging.getLogger()
    if any(handler.get_name() == "azenz" for handler in root_logger.handlers):
        return
    root_logger.setLevel(logging.INFO)
    formatter = logging.Formatter(LOG_FORMAT, datefmt="%Y-%m-%d %H:%M:%S")
    console = logging.StreamHandler()
    console.setFormatter(ConsoleFormatter(LOG_FORMAT, datefmt="%Y-%m-%d %H:%M:%S"))
    log_path = logs_dir() / "azenz.log"
    file_handler = RotatingFileHandler(
        log_path, maxBytes=5_000_000, backupCount=3, encoding="utf-8"
    )
    file_handler.setFormatter(formatter)
    for handler in (console, file_handler):
        handler.set_name("azenz")
        root_logger.addHandler(handler)
    root_logger.info("Log file: %s", log_path)


def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
