import datetime
import enum
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    TIMESTAMP,
    Enum,
    ForeignKeyConstraint,
    Index,
    String,
    Text,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models import DDocuments, DReglements, PUtilisateurs


class DTiersTypeTiers(str, enum.Enum):
    CLIENT = "CLIENT"
    FOURNISSEUR = "FOURNISSEUR"
    AUTRE = "AUTRE"


class DTiers(Base):
    __tablename__ = "d_tiers"
    __table_args__ = (
        ForeignKeyConstraint(
            ["cree_par"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_tiers_createur",
        ),
        Index("code_tiers", "code_tiers", unique=True),
        Index("fk_tiers_createur", "cree_par"),
        Index("idx_raison_sociale", "raison_sociale"),
        Index("idx_type_tiers", "type_tiers"),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    code_tiers: Mapped[str] = mapped_column(String(50), nullable=False)
    raison_sociale: Mapped[str] = mapped_column(String(255), nullable=False)
    type_tiers: Mapped[DTiersTypeTiers] = mapped_column(
        Enum(DTiersTypeTiers, values_callable=lambda cls: [member.value for member in cls]),
        nullable=False,
    )
    date_creation: Mapped[datetime.datetime] = mapped_column(
        TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")
    )
    nom_commercial: Mapped[Optional[str]] = mapped_column(String(255))
    contact_principal: Mapped[Optional[str]] = mapped_column(String(255))
    telephone: Mapped[Optional[str]] = mapped_column(String(30))
    telephone_secondaire: Mapped[Optional[str]] = mapped_column(String(30))
    email: Mapped[Optional[str]] = mapped_column(String(255))
    adresse: Mapped[Optional[str]] = mapped_column(String(500))
    code_postal: Mapped[Optional[str]] = mapped_column(String(20))
    ville: Mapped[Optional[str]] = mapped_column(String(100))
    identifiant_fiscal: Mapped[Optional[str]] = mapped_column(String(100))
    ice: Mapped[Optional[str]] = mapped_column(String(50))
    rc: Mapped[Optional[str]] = mapped_column(String(100))
    patente: Mapped[Optional[str]] = mapped_column(String(100))
    cnss: Mapped[Optional[str]] = mapped_column(String(100))
    commentaire: Mapped[Optional[str]] = mapped_column(Text)
    cree_par: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))

    p_utilisateurs: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", back_populates="d_tiers"
    )
    d_documents: Mapped[list["DDocuments"]] = relationship("DDocuments", back_populates="tier")
    d_reglements: Mapped[list["DReglements"]] = relationship("DReglements", back_populates="tier")
