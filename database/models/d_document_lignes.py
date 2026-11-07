import datetime
import decimal
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    DECIMAL,
    TIMESTAMP,
    Computed,
    ForeignKeyConstraint,
    Index,
    String,
    Text,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT, INTEGER, TINYINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models.d_articles import DArticles
    from database.models.d_documents import DDocuments
    from database.models.d_mouvements_stock import DMouvementsStock
    from database.models.p_tvas import PTvas
    from database.models.p_utilisateurs import PUtilisateurs


class DDocumentLignes(Base):
    __tablename__ = "d_document_lignes"
    __table_args__ = (
        ForeignKeyConstraint(
            ["article_id"],
            ["d_articles.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_lignes_article",
        ),
        ForeignKeyConstraint(
            ["cree_par"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_lignes_createur",
        ),
        ForeignKeyConstraint(
            ["document_id"],
            ["d_documents.id"],
            ondelete="RESTRICT",
            onupdate="CASCADE",
            name="fk_lignes_document",
        ),
        ForeignKeyConstraint(
            ["tva_id"], ["p_tvas.id"], ondelete="SET NULL", onupdate="CASCADE", name="fk_lignes_tva"
        ),
        Index("fk_lignes_createur", "cree_par"),
        Index("fk_lignes_tva", "tva_id"),
        Index("idx_article", "article_id"),
        Index("idx_document", "document_id"),
        Index("idx_supprime", "supprime"),
        Index("uq_document_numero_ligne", "document_id", "numero_ligne", unique=True),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    document_id: Mapped[int] = mapped_column(BIGINT(unsigned=True), nullable=False)
    numero_ligne: Mapped[int] = mapped_column(INTEGER(unsigned=True), nullable=False)
    quantite: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 4), nullable=False, server_default=text("'0.0000'")
    )
    code_tva: Mapped[str] = mapped_column(String(20), nullable=False)
    tva_percentage: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    prix_unitaire_ht: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 6), nullable=False, server_default=text("'0.000000'")
    )
    impact_stock: Mapped[int] = mapped_column(
        TINYINT(1), nullable=False, server_default=text("'1'")
    )
    date_creation: Mapped[datetime.datetime] = mapped_column(
        TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")
    )
    supprime: Mapped[int] = mapped_column(TINYINT(1), nullable=False, server_default=text("'0'"))
    article_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    code_article: Mapped[Optional[str]] = mapped_column(String(100))
    designation: Mapped[Optional[str]] = mapped_column(String(500))
    tva_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    prix_unitaire_ttc: Mapped[Optional[decimal.Decimal]] = mapped_column(
        DECIMAL(18, 6),
        Computed("((`prix_unitaire_ht` * (1 + (`tva_percentage` / 100))))", persisted=True),
    )
    unitaire_tva: Mapped[Optional[decimal.Decimal]] = mapped_column(
        DECIMAL(18, 6),
        Computed("(((`prix_unitaire_ht` * `tva_percentage`) / 100))", persisted=True),
    )
    montant_ht: Mapped[Optional[decimal.Decimal]] = mapped_column(
        DECIMAL(18, 6), Computed("((`quantite` * `prix_unitaire_ht`))", persisted=True)
    )
    montant_ttc: Mapped[Optional[decimal.Decimal]] = mapped_column(
        DECIMAL(18, 6), Computed("((`quantite` * `prix_unitaire_ttc`))", persisted=True)
    )
    montant_tva: Mapped[Optional[decimal.Decimal]] = mapped_column(
        DECIMAL(18, 6), Computed("((`quantite` * `unitaire_tva`))", persisted=True)
    )
    commentaire: Mapped[Optional[str]] = mapped_column(Text)
    cree_par: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))

    article: Mapped[Optional["DArticles"]] = relationship(
        "DArticles", back_populates="d_document_lignes"
    )
    p_utilisateurs: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", back_populates="d_document_lignes"
    )
    document: Mapped["DDocuments"] = relationship("DDocuments", back_populates="d_document_lignes")
    tva: Mapped[Optional["PTvas"]] = relationship("PTvas", back_populates="d_document_lignes")
    d_mouvements_stock: Mapped[list["DMouvementsStock"]] = relationship(
        "DMouvementsStock", back_populates="document_ligne"
    )
