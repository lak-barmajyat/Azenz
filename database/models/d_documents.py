import datetime
import decimal
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    DECIMAL,
    DateTime,
    ForeignKeyConstraint,
    Index,
    String,
    Text,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT, TINYINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models.d_document_lignes import DDocumentLignes
    from database.models.d_document_reglements import DDocumentReglements
    from database.models.d_mouvements_stock import DMouvementsStock
    from database.models.d_tiers import DTiers
    from database.models.p_types_documents import PTypesDocuments
    from database.models.p_utilisateurs import PUtilisateurs


class DDocuments(Base):
    __tablename__ = "d_documents"
    __table_args__ = (
        ForeignKeyConstraint(
            ["tier_id"],
            ["d_tiers.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_documents_tier",
        ),
        ForeignKeyConstraint(
            ["type_document_id"],
            ["p_types_documents.id"],
            onupdate="CASCADE",
            name="fk_documents_type",
        ),
        ForeignKeyConstraint(
            ["utilisateur_id"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_documents_utilisateur",
        ),
        Index("fk_documents_utilisateur", "utilisateur_id"),
        Index("idx_date_document", "date_document"),
        Index("idx_statut", "status"),
        Index("idx_tier", "tier_id"),
        Index("idx_type_document", "type_document_id"),
        Index("uq_document_reference", "type_document_id", "code_document", unique=True),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    type_document_id: Mapped[int] = mapped_column(BIGINT(unsigned=True), nullable=False)
    code_document: Mapped[str] = mapped_column(String(50), nullable=False)
    montant_ht: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_remise: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_net_ht: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_tva: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_ttc: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_net_ttc: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_paye: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_restant: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    status: Mapped[str] = mapped_column(String(30), nullable=False)
    date_document: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)
    supprime: Mapped[int] = mapped_column(TINYINT(1), nullable=False, server_default=text("'0'"))
    tier_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    utilisateur_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    commentaire: Mapped[Optional[str]] = mapped_column(Text)

    tier: Mapped[Optional["DTiers"]] = relationship("DTiers", back_populates="d_documents")
    type_document: Mapped["PTypesDocuments"] = relationship(
        "PTypesDocuments", back_populates="d_documents"
    )
    utilisateur: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", back_populates="d_documents"
    )
    d_document_lignes: Mapped[list["DDocumentLignes"]] = relationship(
        "DDocumentLignes", back_populates="document"
    )
    d_document_reglements: Mapped[list["DDocumentReglements"]] = relationship(
        "DDocumentReglements", back_populates="document"
    )
    d_mouvements_stock: Mapped[list["DMouvementsStock"]] = relationship(
        "DMouvementsStock", back_populates="document"
    )
