"""Public Qt bridge for new purchase documents.

The frame handles search/save feedback and emits backRequested to its host.
The model owns lookups, draft state and atomic document/line persistence.
"""

from .model import NouveauDocModel

__all__ = ["NouveauDocModel"]
