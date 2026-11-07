import datetime
import decimal
import enum
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    DECIMAL,
    TIMESTAMP,
    Enum,
    ForeignKeyConstraint,
    Index,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models import DDocuments, DReglements, PUtilisateurs


class DDocumentReglementsTypeAffectation(str, enum.Enum):
    REGLEMENT = "REGLEMENT"
    ACOMPTE = "ACOMPTE"
    AVANCE = "AVANCE"
    AVOIR = "AVOIR"


class DDocumentReglements(Base):
    __tablename__ = "d_document_reglements"
    __table_args__ = (
        ForeignKeyConstraint(
            ["cree_par"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_document_reglements_createur",
        ),
        ForeignKeyConstraint(
            ["document_id"],
            ["d_documents.id"],
            ondelete="RESTRICT",
            onupdate="CASCADE",
            name="fk_document_reglements_document",
        ),
        ForeignKeyConstraint(
            ["reglement_id"],
            ["d_reglements.id"],
            ondelete="RESTRICT",
            onupdate="CASCADE",
            name="fk_document_reglements_reglement",
        ),
        Index("fk_document_reglements_createur", "cree_par"),
        Index("idx_date_liaison", "date_liaison"),
        Index("idx_document", "document_id"),
        Index("idx_reglement", "reglement_id"),
        Index("idx_type_affectation", "type_affectation"),
        Index("uq_document_reglement", "document_id", "reglement_id", unique=True),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    document_id: Mapped[int] = mapped_column(BIGINT(unsigned=True), nullable=False)
    reglement_id: Mapped[int] = mapped_column(BIGINT(unsigned=True), nullable=False)
    date_liaison: Mapped[datetime.datetime] = mapped_column(
        TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")
    )
    montant_affecte: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    type_affectation: Mapped[DDocumentReglementsTypeAffectation] = mapped_column(
        Enum(
            DDocumentReglementsTypeAffectation,
            values_callable=lambda cls: [member.value for member in cls],
        ),
        nullable=False,
        server_default=text("'REGLEMENT'"),
    )
    date_creation: Mapped[datetime.datetime] = mapped_column(
        TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")
    )
    cree_par: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))

    p_utilisateurs: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", back_populates="d_document_reglements"
    )
    document: Mapped["DDocuments"] = relationship(
        "DDocuments", back_populates="d_document_reglements"
    )
    reglement: Mapped["DReglements"] = relationship(
        "DReglements", back_populates="d_document_reglements"
    )
