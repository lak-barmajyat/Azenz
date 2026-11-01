import datetime
import enum
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    DateTime,
    Enum,
    Index,
    String,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT, TINYINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models.d_articles import DArticles
    from database.models.d_document_lignes import DDocumentLignes
    from database.models.d_document_reglements import DDocumentReglements
    from database.models.d_documents import DDocuments
    from database.models.d_familles import DFamilles
    from database.models.d_mouvements_stock import DMouvementsStock
    from database.models.d_reglements import DReglements
    from database.models.d_tiers import DTiers


class PUtilisateursRole(str, enum.Enum):
    MANAGER = "MANAGER"
    MERCHANT = "MERCHANT"


class PUtilisateurs(Base):
    __tablename__ = "p_utilisateurs"
    __table_args__ = (
        Index("idx_nom_utilisateur", "nom_utilisateur"),
        Index("nom_utilisateur", "nom_utilisateur", unique=True),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    nom_utilisateur: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    mot_de_passe_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[PUtilisateursRole] = mapped_column(
        Enum(PUtilisateursRole, values_callable=lambda cls: [member.value for member in cls]),
        nullable=False,
    )
    actif: Mapped[int] = mapped_column(TINYINT(1), nullable=False, server_default=text("'1'"))
    telephone: Mapped[Optional[str]] = mapped_column(String(30))
    date_derniere_connexion: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)

    d_familles: Mapped[list["DFamilles"]] = relationship(
        "DFamilles", back_populates="p_utilisateurs"
    )
    d_tiers: Mapped[list["DTiers"]] = relationship("DTiers", back_populates="p_utilisateurs")
    d_articles: Mapped[list["DArticles"]] = relationship(
        "DArticles", back_populates="p_utilisateurs"
    )
    d_documents: Mapped[list["DDocuments"]] = relationship(
        "DDocuments", back_populates="utilisateur"
    )
    d_reglements_cree_par: Mapped[list["DReglements"]] = relationship(
        "DReglements", foreign_keys="[DReglements.cree_par]", back_populates="p_utilisateurs"
    )
    d_reglements_utilisateur: Mapped[list["DReglements"]] = relationship(
        "DReglements", foreign_keys="[DReglements.utilisateur_id]", back_populates="utilisateur"
    )
    d_document_lignes: Mapped[list["DDocumentLignes"]] = relationship(
        "DDocumentLignes", back_populates="p_utilisateurs"
    )
    d_document_reglements: Mapped[list["DDocumentReglements"]] = relationship(
        "DDocumentReglements", back_populates="p_utilisateurs"
    )
    d_mouvements_stock: Mapped[list["DMouvementsStock"]] = relationship(
        "DMouvementsStock", back_populates="p_utilisateurs"
    )
