from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    CHAR,
    ForeignKeyConstraint,
    Index,
    String,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models import PTvas


class PInformationsSociete(Base):
    __tablename__ = "p_informations_societe"
    __table_args__ = (
        ForeignKeyConstraint(
            ["tva_id"],
            ["p_tvas.id"],
            ondelete="SET NULL",
            onupdate="CASCADE",
            name="fk_infos_societe_tva",
        ),
        Index("idx_tva", "tva_id"),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    raison_sociale: Mapped[str] = mapped_column(String(255), nullable=False)
    pays: Mapped[str] = mapped_column(String(100), nullable=False, server_default=text("'Maroc'"))
    nom_commercial: Mapped[Optional[str]] = mapped_column(String(255))
    activite: Mapped[Optional[str]] = mapped_column(String(255))
    identifiant_fiscal: Mapped[Optional[str]] = mapped_column(String(100))
    ice: Mapped[Optional[str]] = mapped_column(String(50))
    rc: Mapped[Optional[str]] = mapped_column(String(100))
    patente: Mapped[Optional[str]] = mapped_column(String(100))
    cnss: Mapped[Optional[str]] = mapped_column(String(100))
    adresse: Mapped[Optional[str]] = mapped_column(String(500))
    code_postal: Mapped[Optional[str]] = mapped_column(String(20))
    ville: Mapped[Optional[str]] = mapped_column(String(100))
    region: Mapped[Optional[str]] = mapped_column(String(100))
    devise: Mapped[Optional[str]] = mapped_column(CHAR(3), server_default=text("'MAD'"))
    telephone: Mapped[Optional[str]] = mapped_column(String(30))
    email: Mapped[Optional[str]] = mapped_column(String(255))
    site_web: Mapped[Optional[str]] = mapped_column(String(255))
    logo_url: Mapped[Optional[str]] = mapped_column(String(500))
    tva_id: Mapped[Optional[int]] = mapped_column(BIGINT(unsigned=True))

    tva: Mapped[Optional["PTvas"]] = relationship("PTvas", back_populates="p_informations_societe")
