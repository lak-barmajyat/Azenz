import datetime
import decimal
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    DECIMAL,
    DateTime,
    ForeignKeyConstraint,
    Index,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.models.base import Base

if TYPE_CHECKING:
    from database.models import DArticles


class DStock(Base):
    __tablename__ = "d_stock"
    __table_args__ = (
        ForeignKeyConstraint(
            ["article_id"], ["d_articles.id"], onupdate="CASCADE", name="fk_stock_article"
        ),
        Index("idx_article", "article_id"),
        Index("uq_stock_article", "article_id", unique=True),
    )

    id: Mapped[int] = mapped_column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    article_id: Mapped[int] = mapped_column(BIGINT(unsigned=True), nullable=False)
    quantite_stock: Mapped[decimal.Decimal] = mapped_column(
        DECIMAL(18, 4), nullable=False, server_default=text("'0.0000'")
    )
    date_dernier_mouvement: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)

    article: Mapped["DArticles"] = relationship("DArticles", back_populates="d_stock")
