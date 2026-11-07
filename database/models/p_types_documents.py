import enum
from typing import TYPE_CHECKING

from sqlalchemy import Enum, Index, String, text
from sqlalchemy.dialects.mysql import BIGINT, TINYINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models import DDocuments, PNumerotationDocuments


class PTypesDocumentsDomaine(str, enum.Enum):
    VENTE = "VENTE"
    ACHAT = "ACHAT"
    STOCK = "STOCK"
    INTERNE = "INTERNE"


class PTypesDocumentsSensStock(str, enum.Enum):
    AUCUN = "AUCUN"
    ENTREE = "ENTREE"
    SORTIE = "SORTIE"


class PTypesDocuments(Base):
    __tablename__ = "p_types_documents"
    __table_args__ = (Index("code_type_document", "code_type_document", unique=True),)

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    code_type_document: Mapped[str] = mapped_column(String(50), nullable=False)
    nom_type_document: Mapped[str] = mapped_column(String(100), nullable=False)
    domaine: Mapped[PTypesDocumentsDomaine] = mapped_column(
        Enum(PTypesDocumentsDomaine, values_callable=lambda cls: [member.value for member in cls]),
        nullable=False,
    )
    sens_stock: Mapped[PTypesDocumentsSensStock] = mapped_column(
        Enum(
            PTypesDocumentsSensStock, values_callable=lambda cls: [member.value for member in cls]
        ),
        nullable=False,
        server_default=text("'AUCUN'"),
    )
    impacte_stock: Mapped[int] = mapped_column(
        TINYINT(1), nullable=False, server_default=text("'0'")
    )
    impacte_reglement: Mapped[int] = mapped_column(
        TINYINT(1), nullable=False, server_default=text("'0'")
    )
    actif: Mapped[int] = mapped_column(TINYINT(1), nullable=False, server_default=text("'1'"))

    p_numerotation_documents: Mapped[list["PNumerotationDocuments"]] = relationship(
        "PNumerotationDocuments", back_populates="type_document"
    )
    d_documents: Mapped[list["DDocuments"]] = relationship(
        "DDocuments", back_populates="type_document"
    )
