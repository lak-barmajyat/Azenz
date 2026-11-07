"""Run the interactive sales screen directly, without a database or login.

From the project folder:
    .\.venv-qml\Scripts\python.exe run_sales.py
"""

import sys

from preview_screens import main

if __name__ == "__main__":
    if "--sales" not in sys.argv:
        sys.argv.append("--sales")
    sys.exit(main())
