from typing import TYPE_CHECKING

from sqlalchemy import ForeignKeyConstraint, Index, String, text
from sqlalchemy.dialects.mysql import BIGINT, INTEGER
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models.p_types_documents import PTypesDocuments


class PNumerotationDocuments(Base):
    __tablename__ = "p_numerotation_documents"
    __table_args__ = (
        ForeignKeyConstraint(
            ["type_document_id"],
            ["p_types_documents.id"],
            ondelete="CASCADE",
            onupdate="CASCADE",
            name="fk_numerotation_type_document",
        ),
        Index("idx_type_document", "type_document_id"),
        Index("uq_numerotation_type_annee", "type_document_id", "annee", unique=True),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    type_document_id: Mapped[int] = mapped_column(BIGINT(unsigned=True), nullable=False)
    prefixe: Mapped[str] = mapped_column(String(20), nullable=False)
    annee: Mapped[int] = mapped_column(INTEGER(unsigned=True), nullable=False)
    dernier_numero: Mapped[str] = mapped_column(String(20), nullable=False)
    longueur_numero: Mapped[int] = mapped_column(
        INTEGER(unsigned=True), nullable=False, server_default=text("'4'")
    )

    type_document: Mapped["PTypesDocuments"] = relationship(
        "PTypesDocuments", back_populates="p_numerotation_documents"
    )
