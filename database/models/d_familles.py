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
from sqlalchemy.dialects.mysql import BIGINT, TINYINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models.d_articles import DArticles
    from database.models.p_tvas import PTvas
    from database.models.p_utilisateurs import PUtilisateurs


class DFamillesTypeFamille(str, enum.Enum):
    PRODUIT = "PRODUIT"
    SERVICE = "SERVICE"
    NUMERIQUE = "NUMERIQUE"
    MATIERE_PREMIERE = "MATIERE_PREMIERE"


class DFamilles(Base):
    __tablename__ = "d_familles"
    __table_args__ = (
        ForeignKeyConstraint(
            ["cree_par"],
            ["p_utilisateurs.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_familles_createur",
        ),
        ForeignKeyConstraint(
            ["tva_id"],
            ["p_tvas.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_familles_tva",
        ),
        Index("code_famille", "code_famille", unique=True),
        Index("fk_familles_createur", "cree_par"),
        Index("idx_tva", "tva_id"),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    code_famille: Mapped[str] = mapped_column(String(100), nullable=False)
    nom_famille: Mapped[str] = mapped_column(String(255), nullable=False)
    type_famille: Mapped[DFamillesTypeFamille] = mapped_column(
        Enum(DFamillesTypeFamille, values_callable=lambda cls: [member.value for member in cls]),
        nullable=False,
    )
    suivi_stock: Mapped[int] = mapped_column(TINYINT(1), nullable=False, server_default=text("'1'"))
    date_creation: Mapped[datetime.datetime] = mapped_column(
        TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")
    )
    description: Mapped[Optional[str]] = mapped_column(Text)
    tva_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))
    cree_par: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))

    p_utilisateurs: Mapped[Optional["PUtilisateurs"]] = relationship(
        "PUtilisateurs", back_populates="d_familles"
    )
    tva: Mapped[Optional["PTvas"]] = relationship("PTvas", back_populates="d_familles")
    d_articles: Mapped[list["DArticles"]] = relationship("DArticles", back_populates="famille")
