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
    from database.models import DArticles, DDocumentLignes, DDocuments, PUtilisateurs


class DMouvementsStockSensMouvement(str, enum.Enum):
    IN = "IN"
    OUT = "OUT"


class DMouvementsStockTypeMouvement(str, enum.Enum):
    ENTREE = "ENTREE"
    SORTIE = "SORTIE"
    AJUSTEMENT = "AJUSTEMENT"
    INVENTAIRE = "INVENTAIRE"


class DMouvementsStock(Base):
    __tablename__ = "d_mouvements_stock"
    __table_args__ = (
        ForeignKeyConstraint(
            ["article_id"], ["d_articles.id"], onupdate="CASCADE", name="fk_mouvements_article"
        ),
        ForeignKeyConstraint(
            ["cree_par"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_mouvements_createur",
        ),
        ForeignKeyConstraint(
            ["document_id"],
            ["d_documents.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_mouvements_document",
        ),
        ForeignKeyConstraint(
            ["document_ligne_id"],
            ["d_document_lignes.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_mouvements_document_ligne",
        ),
        Index("fk_mouvements_createur", "cree_par"),
        Index("idx_article", "article_id"),
        Index("idx_date_mouvement", "date_mouvement"),
        Index("idx_document", "document_id"),
        Index("idx_document_ligne", "document_ligne_id"),
        Index("idx_type_mouvement", "type_mouvement"),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    article_id: Mapped[int] = mapped_column(BIGINT(unsigned=True), nullable=False)
    type_mouvement: Mapped[DMouvementsStockTypeMouvement] = mapped_column(
        Enum(
            DMouvementsStockTypeMouvement,
            values_callable=lambda cls: [member.value for member in cls],
        ),
        nullable=False,
    )
    sens_mouvement: Mapped[DMouvementsStockSensMouvement] = mapped_column(
        Enum(
            DMouvementsStockSensMouvement,
            values_callable=lambda cls: [member.value for member in cls],
        ),
        nullable=False,
    )
    quantite: Mapped[decimal.Decimal] = mapped_column(DECIMAL(18, 4), nullable=False)
    date_mouvement: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)
    date_creation: Mapped[datetime.datetime] = mapped_column(
        TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")
    )
    document_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    document_ligne_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    description: Mapped[Optional[str]] = mapped_column(String(255))
    cree_par: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))

    article: Mapped["DArticles"] = relationship("DArticles", back_populates="d_mouvements_stock")
    p_utilisateurs: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", back_populates="d_mouvements_stock"
    )
    document: Mapped[Optional["DDocuments"]] = relationship(
        "DDocuments", back_populates="d_mouvements_stock"
    )
    document_ligne: Mapped[Optional["DDocumentLignes"]] = relationship(
        "DDocumentLignes", back_populates="d_mouvements_stock"
    )
