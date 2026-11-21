"""Stateless code formatting shared by documents, articles, families, etc.

The caller reads the latest saved code for its own series. A preview reserves
nothing; saving must re-read under the caller's transaction/locking policy.
"""

import re


def next_code(last_code: str | None, *, prefix: str, width: int = 3) -> str:
    """Increment the trailing number, preserving the existing prefix and padding."""
    if last_code is None:
        return f"{prefix}{1:0{width}d}"
    match = re.fullmatch(r"(.*?)([0-9]+)", last_code)
    if match is None:
        raise ValueError("The last saved code must end with a number")
    stem, number = match.groups()
    return f"{stem}{int(number) + 1:0{len(number)}d}"
