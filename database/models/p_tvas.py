import decimal
from typing import TYPE_CHECKING

from sqlalchemy import DECIMAL, Index, String, text
from sqlalchemy.dialects.mysql import BIGINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models import DArticles, DDocumentLignes, DFamilles, PInformationsSociete


class PTvas(Base):
    __tablename__ = "p_tvas"
    __table_args__ = (Index("code_tva", "code_tva", unique=True),)

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    code_tva: Mapped[str] = mapped_column(String(50), nullable=False)
    nom_tva: Mapped[str] = mapped_column(String(100), nullable=False)
    taux: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(6, 3), nullable=False, server_default=text("'0.000'")
    )

    d_familles: Mapped[list["DFamilles"]] = relationship("DFamilles", back_populates="tva")
    p_informations_societe: Mapped[list["PInformationsSociete"]] = relationship(
        "PInformationsSociete", back_populates="tva"
    )
    d_articles: Mapped[list["DArticles"]] = relationship("DArticles", back_populates="tva")
    d_document_lignes: Mapped[list["DDocumentLignes"]] = relationship(
        "DDocumentLignes", back_populates="tva"
    )
