from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from database.models.d_documents import DDocuments
from database.models.p_types_documents import PTypesDocuments
from database.session import with_session


@with_session()
def list_ventes(*, session: Session) -> list[dict[str, object]]:
    """Return non-deleted sales documents for the ventes frame."""
    documents = session.scalars(
        select(DDocuments)
        .join(DDocuments.type_document)
        .where(
            DDocuments.supprime == 0,
            PTypesDocuments.domaine == "VENTE",
        )
        .order_by(DDocuments.date_document.desc())
    ).all()
    return [
        {
            "id": document.id,
            "documentCode": document.code_document,
            "date": document.date_document,
            "ht": document.montant_ht,
            "vat": document.montant_tva,
            "ttc": document.montant_ttc,
            "documentType": document.type_document.nom_type_document,
        }
        for document in documents
    ]
