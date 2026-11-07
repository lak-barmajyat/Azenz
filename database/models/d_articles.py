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
    String,
    Text,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT, TINYINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models import (
        DDocumentLignes,
        DFamilles,
        DMouvementsStock,
        DStock,
        PTvas,
        PUtilisateurs,
    )


class DArticlesTypeArticle(str, enum.Enum):
    PRODUIT = "PRODUIT"
    SERVICE = "SERVICE"
    NUMERIQUE = "NUMERIQUE"
    MATIERE_PREMIERE = "MATIERE_PREMIERE"


class DArticles(Base):
    __tablename__ = "d_articles"
    __table_args__ = (
        ForeignKeyConstraint(
            ["cree_par"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_articles_createur",
        ),
        ForeignKeyConstraint(
            ["famille_id"],
            ["d_familles.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_articles_famille",
        ),
        ForeignKeyConstraint(
            ["tva_id"],
            ["p_tvas.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_articles_tva",
        ),
        Index("code_article", "code_article", unique=True),
        Index("fk_articles_createur", "cree_par"),
        Index("idx_code_article", "code_article"),
        Index("idx_designation", "designation"),
        Index("idx_famille", "famille_id"),
        Index("idx_tva", "tva_id"),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    code_article: Mapped[str] = mapped_column(String(100), nullable=False)
    designation: Mapped[str] = mapped_column(String(255), nullable=False)
    type_article: Mapped[DArticlesTypeArticle] = mapped_column(
        Enum(DArticlesTypeArticle, values_callable=lambda cls: [member.value for member in cls]),
        nullable=False,
    )
    prix_achat_ht: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    prix_achat_ttc: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    prix_vente_ht: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    prix_vente_ttc: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    suivi_stock: Mapped[int] = mapped_column(TINYINT(1), nullable=False, server_default=text("'1'"))
    quantite_min_stock: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 4), nullable=False, server_default=text("'0.0000'")
    )
    date_creation: Mapped[datetime.datetime] = mapped_column(
        TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")
    )
    description: Mapped[Optional[str]] = mapped_column(Text)
    famille_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    unite: Mapped[Optional[str]] = mapped_column(String(30))
    tva_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    image_url: Mapped[Optional[str]] = mapped_column(String(500))
    cree_par: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))

    p_utilisateurs: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", back_populates="d_articles"
    )
    famille: Mapped[Optional["DFamilles"]] = relationship("DFamilles", back_populates="d_articles")
    tva: Mapped[Optional["PTvas"]] = relationship("PTvas", back_populates="d_articles")
    d_document_lignes: Mapped[list["DDocumentLignes"]] = relationship(
        "DDocumentLignes", back_populates="article"
    )
    d_stock: Mapped[list["DStock"]] = relationship("DStock", back_populates="article")
    d_mouvements_stock: Mapped[list["DMouvementsStock"]] = relationship(
        "DMouvementsStock", back_populates="article"
    )
