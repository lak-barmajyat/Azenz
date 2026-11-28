"""Stock transaction tests against an explicitly supplied disposable MariaDB socket."""

import os
import unittest
from decimal import Decimal
from unittest.mock import patch
from uuid import uuid4

from sqlalchemy import create_engine, delete, func, select, text
from sqlalchemy.orm import Session, sessionmaker

from database.models import (
    Base,
    DArticles,
    DDocumentLignes,
    DDocuments,
    DMouvementsStock,
    DStock,
    PTypesDocuments,
)
from modules.stockage.liste_stock.model import ListeStockModel
from modules.stockage.nouveau_document.model import NouveauDocumentModel

SOCKET = os.environ.get("AZENZ_TEST_SOCKET", "")


@unittest.skipUnless(SOCKET.startswith("/tmp/azenz-save-test."), "Requires isolated test server")
class StockageDatabaseTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.name = "azenz_stock_test_" + uuid4().hex
        cls.admin = create_engine(
            "mysql+pymysql://root@localhost", connect_args={"unix_socket": SOCKET}
        )
        with cls.admin.begin() as connection:
            connection.execute(text(f"CREATE DATABASE `{cls.name}`"))
        cls.engine = create_engine(
            f"mysql+pymysql://root@localhost/{cls.name}",
            connect_args={"unix_socket": SOCKET},
            hide_parameters=True,
        )
        Base.metadata.create_all(cls.engine)

    @classmethod
    def tearDownClass(cls) -> None:
        cls.engine.dispose()
        with cls.admin.begin() as connection:
            connection.execute(text(f"DROP DATABASE `{cls.name}`"))
        cls.admin.dispose()

    def setUp(self) -> None:
        session_patch = patch("database.session.session_factory", sessionmaker(self.engine))
        session_patch.start()
        self.addCleanup(session_patch.stop)
        with Session(self.engine) as session, session.begin():
            for table in (
                DMouvementsStock,
                DStock,
                DDocumentLignes,
                DDocuments,
                DArticles,
                PTypesDocuments,
            ):
                session.execute(delete(table))
            session.add_all(
                [
                    PTypesDocuments(
                        id=1,
                        code_type_document="EN",
                        nom_type_document="Entrée de stock",
                        domaine="STOCK",
                        sens_stock="ENTREE",
                        impacte_stock=1,
                    ),
                    PTypesDocuments(
                        id=2,
                        code_type_document="SO",
                        nom_type_document="Sortie de stock",
                        domaine="STOCK",
                        sens_stock="SORTIE",
                        impacte_stock=1,
                    ),
                    PTypesDocuments(
                        id=3,
                        code_type_document="INV",
                        nom_type_document="Inventaire",
                        domaine="STOCK",
                        sens_stock="AUCUN",
                        impacte_stock=1,
                    ),
                ]
            )
            session.add(
                DArticles(
                    id=1,
                    code_article="ART001",
                    designation="Article stocké",
                    type_article="PRODUIT",
                    suivi_stock=1,
                )
            )
            session.add(DStock(article_id=1, quantite_stock=Decimal("10")))
        self.document_model = NouveauDocumentModel()
        self.list_model = ListeStockModel()
        self.addCleanup(self.document_model.shutdown)
        self.addCleanup(self.list_model.shutdown)

    @staticmethod
    def draft(document_type: str, quantity: str, code: str = "") -> dict:
        return {
            "code": code,
            "type": document_type,
            "date": "2026-11-27",
            "comment": "Test",
            "lines": [
                {
                    "articleId": 1,
                    "reference": "ART001",
                    "description": "Article stocké",
                    "quantity": quantity,
                    "comment": "",
                }
            ],
            "editingDocumentId": None,
        }

    def stock(self) -> Decimal:
        with Session(self.engine) as session:
            return session.scalar(select(DStock.quantite_stock).where(DStock.article_id == 1))

    def test_entry_updates_stock_and_creates_linked_movement(self) -> None:
        result = self.document_model._persist(self.draft("EN", "5"))
        self.assertEqual(result["code"], "EN001")
        self.assertEqual(self.stock(), Decimal("15.0000"))
        with Session(self.engine) as session:
            movement = session.scalar(select(DMouvementsStock))
            self.assertEqual(movement.document_id, result["id"])
            self.assertEqual(movement.sens_mouvement, "IN")
            self.assertEqual(movement.quantite, Decimal("5.0000"))

    def test_code_preview_uses_shared_next_code_service(self) -> None:
        document_type = next(
            item for item in self.document_model._query_types() if item["value"] == "EN"
        )
        self.assertEqual(self.document_model._query_code(document_type), "EN001")
        self.document_model._persist(self.draft("EN", "5"))
        self.assertEqual(self.document_model._query_code(document_type), "EN002")

    def test_exit_cannot_make_stock_negative_and_rolls_back(self) -> None:
        with self.assertRaisesRegex(ValueError, "negative_stock"):
            self.document_model._persist(self.draft("SO", "11"))
        self.assertEqual(self.stock(), Decimal("10.0000"))
        with Session(self.engine) as session:
            self.assertEqual(session.scalar(select(func.count()).select_from(DDocuments)), 0)

    def test_inventory_uses_final_counted_quantity(self) -> None:
        self.document_model._persist(self.draft("INV", "4"))
        self.assertEqual(self.stock(), Decimal("4.0000"))
        with Session(self.engine) as session:
            movement = session.scalar(select(DMouvementsStock))
            self.assertEqual(movement.sens_mouvement, "OUT")
            self.assertEqual(movement.quantite, Decimal("6.0000"))

    def test_editing_validated_document_replaces_its_stock_effect(self) -> None:
        created = self.document_model._persist(self.draft("EN", "5"))
        edited = self.draft("EN", "2", created["code"])
        edited["editingDocumentId"] = created["id"]
        self.assertEqual(self.document_model._persist(edited), created)
        self.assertEqual(self.stock(), Decimal("12.0000"))
        with Session(self.engine) as session:
            movements = list(session.scalars(select(DMouvementsStock)))
            self.assertEqual(len(movements), 1)
            self.assertEqual(movements[0].quantite, Decimal("2.0000"))

    def test_deleting_validated_document_reverses_stock(self) -> None:
        created = self.document_model._persist(self.draft("EN", "5"))
        self.assertEqual(self.list_model._delete_documents([created["id"]]), 1)
        self.assertEqual(self.stock(), Decimal("10.0000"))
        with Session(self.engine) as session:
            self.assertEqual(session.get(DDocuments, created["id"]).supprime, 1)
            self.assertEqual(session.scalar(select(func.count()).select_from(DMouvementsStock)), 0)


if __name__ == "__main__":
    unittest.main()
