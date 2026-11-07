import datetime
import decimal
import enum
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    DECIMAL,
    TIMESTAMP,
    DateTime,
    Enum,
    ForeignKeyConstraint,
    Index,
    String,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models import DDocumentReglements, DTiers, PUtilisateurs


class DReglementsSensReglement(str, enum.Enum):
    ENTREE = "ENTREE"
    SORTIE = "SORTIE"


class DReglementsStatutReglement(str, enum.Enum):
    BROUILLON = "BROUILLON"
    VALIDE = "VALIDE"
    IMPUTE_PARTIEL = "IMPUTE_PARTIEL"
    IMPUTE_TOTAL = "IMPUTE_TOTAL"
    ANNULE = "ANNULE"
    IMPAYE = "IMPAYE"


class DReglements(Base):
    __tablename__ = "d_reglements"
    __table_args__ = (
        ForeignKeyConstraint(
            ["cree_par"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_reglements_createur",
        ),
        ForeignKeyConstraint(
            ["tier_id"], ["d_tiers.id"], onupdate="CASCADE", name="fk_reglements_tier"
        ),
        ForeignKeyConstraint(
            ["utilisateur_id"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_reglements_utilisateur",
        ),
        Index("code_reglement", "code_reglement", unique=True),
        Index("fk_reglements_createur", "cree_par"),
        Index("idx_date_reglement", "date_reglement"),
        Index("idx_statut_reglement", "statut_reglement"),
        Index("idx_tier", "tier_id"),
        Index("idx_utilisateur", "utilisateur_id"),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    code_reglement: Mapped[str] = mapped_column(String(100), nullable=False)
    tier_id: Mapped[int] = mapped_column(BIGINT(unsigned=True), nullable=False)
    date_reglement: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)
    sens_reglement: Mapped[DReglementsSensReglement] = mapped_column(
        Enum(
            DReglementsSensReglement, values_callable=lambda cls: [member.value for member in cls]
        ),
        nullable=False,
    )
    montant_total: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_affecte: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    montant_restant: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    statut_reglement: Mapped[DReglementsStatutReglement] = mapped_column(
        Enum(
            DReglementsStatutReglement, values_callable=lambda cls: [member.value for member in cls]
        ),
        nullable=False,
        server_default=text("'BROUILLON'"),
    )
    date_creation: Mapped[datetime.datetime] = mapped_column(
        TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")
    )
    utilisateur_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    description: Mapped[Optional[str]] = mapped_column(String(255))
    mode_reglement: Mapped[Optional[str]] = mapped_column(String(50))
    reference_piece: Mapped[Optional[str]] = mapped_column(String(100))
    cree_par: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))

    p_utilisateurs: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", foreign_keys=[cree_par], back_populates="d_reglements_cree_par"
    )
    tier: Mapped["DTiers"] = relationship("DTiers", back_populates="d_reglements")
    utilisateur: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", foreign_keys=[utilisateur_id], back_populates="d_reglements_utilisateur"
    )
    d_document_reglements: Mapped[list["DDocumentReglements"]] = relationship(
        "DDocumentReglements", back_populates="reglement"
    )
