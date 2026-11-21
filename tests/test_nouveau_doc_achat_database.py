"""Integration tests against an explicitly supplied, disposable MariaDB socket."""

import os
import threading
import time
import unittest
from concurrent.futures import ThreadPoolExecutor
from copy import deepcopy
from decimal import Decimal
from unittest.mock import patch
from uuid import uuid4

from PySide6.QtCore import QCoreApplication, QEventLoop, QTimer
from sqlalchemy import create_engine, delete, func, select, text
from sqlalchemy.orm import Session, sessionmaker

from database.models import (
    Base,
    DArticles,
    DDocumentLignes,
    DDocuments,
    DTiers,
    PTvas,
    PTypesDocuments,
)
from modules.achats.liste_achats.model import ListeAchatsModel
from modules.achats.nouveau_doc import NouveauDocModel

SOCKET = os.environ.get("AZENZ_TEST_SOCKET", "")


@unittest.skipUnless(SOCKET.startswith("/tmp/azenz-save-test."), "Requires isolated test server")
class NouveauDocAchatDatabaseTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.app = QCoreApplication.instance() or QCoreApplication([])
        cls.name = "azenz_test_" + uuid4().hex
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
        self.session_patch = patch("database.session.session_factory", sessionmaker(self.engine))
        self.session_patch.start()
        self.addCleanup(self.session_patch.stop)
        with Session(self.engine) as session, session.begin():
            for table in (DDocumentLignes, DDocuments, DArticles, DTiers, PTypesDocuments, PTvas):
                session.execute(delete(table))
            session.add(PTvas(id=1, code_tva="TVA20", nom_tva="TVA 20%", taux=20))
            session.add(
                PTypesDocuments(
                    id=1,
                    code_type_document="BC",
                    nom_type_document="Bon de commande achat",
                    domaine="ACHAT",
                    sens_stock="ENTREE",
                    actif=1,
                )
            )
            session.add(
                DTiers(
                    id=1,
                    code_tiers="FR001",
                    raison_sociale="Test fournisseur",
                    type_tiers="FOURNISSEUR",
                )
            )
            session.flush()
            session.add_all(
                [
                    DArticles(
                        id=1,
                        code_article="ART001",
                        designation="Câble cuivre",
                        type_article="PRODUIT",
                        prix_achat_ht=Decimal("12.345678"),
                        tva_id=1,
                    ),
                    DArticles(
                        id=2,
                        code_article="P%100",
                        designation="Service test",
                        type_article="SERVICE",
                        prix_achat_ht=Decimal("10"),
                        suivi_stock=0,
                    ),
                ]
            )
        self.model = NouveauDocModel()
        self.addCleanup(self.model.shutdown)
        self.header = {
            "supplier": {"value": 1},
            "type": "BC",
            "code": "CUSTOM009",
            "date": "2026-11-14",
        }

    def add_line(self, article_id=1, quantity=2):
        query = "ART" if article_id == 1 else "%"
        article = self.model._query_articles("reference", query)[0]
        self.assertTrue(self.model.addLine({**article, "quantity": quantity}, article, -1))

    def draft(self, automatic=False):
        return deepcopy(
            {
                **self.header,
                "lines": self.model.lines,
                "discount": Decimal(0),
                "automaticCode": automatic,
            }
        )

    def counts(self):
        with Session(self.engine) as session:
            return (
                session.scalar(select(func.count()).select_from(DDocuments)),
                session.scalar(select(func.count()).select_from(DDocumentLignes)),
            )

    def test_search_columns_metadata_and_literal_wildcards(self):
        rows = self.model._query_articles("description", "cuivre")
        self.assertEqual([row["articleId"] for row in rows], [1])
        self.assertEqual(rows[0]["priceHT"], "12.345678")
        self.assertEqual(rows[0]["tvaCode"], "TVA20")
        self.assertEqual(Decimal(rows[0]["vat"]), Decimal(20))
        rows = self.model._query_articles("reference", "%")
        self.assertEqual([row["articleId"] for row in rows], [2])
        self.assertIsNone(rows[0]["tvaId"])
        self.assertEqual(rows[0]["tvaCode"], "SANS_TVA")

    def test_save_header_and_generated_lines_preserves_manual_code(self):
        self.add_line()
        self.add_line(2, 3)
        result = self.model._save(self.draft())
        self.assertEqual(result["code"], "CUSTOM009")
        self.assertEqual(self.counts(), (1, 2))
        with Session(self.engine) as session:
            doc = session.get(DDocuments, result["id"])
            rows = session.scalars(
                select(DDocumentLignes).order_by(DDocumentLignes.numero_ligne)
            ).all()
            self.assertEqual(doc.status, "BROUILLON")
            self.assertEqual(doc.tier_id, 1)
            self.assertEqual([row.numero_ligne for row in rows], [1, 2])
            self.assertEqual([row.article_id for row in rows], [1, 2])
            self.assertEqual(rows[0].prix_unitaire_ttc, Decimal("14.814814"))
            self.assertEqual(doc.montant_ht, sum(row.montant_ht for row in rows))
            self.assertEqual(doc.montant_ttc, sum(row.montant_ttc for row in rows))
            self.assertEqual(doc.montant_tva, sum(row.montant_tva for row in rows))
            self.assertEqual(doc.montant_net_ttc, doc.montant_restant)
            self.assertEqual(doc.montant_paye, 0)

    def test_late_failure_rolls_back_header_and_all_lines(self):
        self.add_line()
        self.add_line(2)
        draft = self.draft(automatic=True)
        draft["lines"][1]["tvaId"] = 999
        with self.assertLogs(level="ERROR"):
            self.assertEqual(self.model._save(draft)["error"], "service_unavailable")
        self.assertEqual(self.counts(), (0, 0))
        self.assertEqual(self.model._save(self.draft(automatic=True))["code"], "BC001")
        self.assertEqual(self.counts(), (1, 2))

    def test_duplicate_manual_code_and_deleted_article(self):
        self.add_line()
        self.model._save(self.draft())
        self.assertEqual(self.model._save(self.draft())["error"], "duplicate_code")
        self.assertEqual(self.counts(), (1, 1))
        draft = self.draft()
        draft["code"] = "OTHER001"
        draft["lines"][0]["articleId"] = 999
        self.assertEqual(self.model._save(draft)["error"], "invalid_article")
        self.assertEqual(self.counts(), (1, 1))

    def test_concurrent_saves_recalculate_auto_code_under_type_lock(self):
        self.add_line()
        draft = self.draft(automatic=True)
        barrier = threading.Barrier(2)

        def save():
            barrier.wait(timeout=5)
            return self.model._save(deepcopy(draft))

        with ThreadPoolExecutor(max_workers=2) as pool:
            first = pool.submit(save)
            second = pool.submit(save)
            results = [first.result(timeout=10), second.result(timeout=10)]
        self.assertEqual({result["code"] for result in results}, {"BC001", "BC002"})
        self.assertEqual(self.counts(), (2, 2))

    def test_discount_and_late_discount_validation(self):
        self.add_line(2, 3)
        draft = self.draft()
        draft["discount"] = Decimal(5)
        result = self.model._save(draft)
        with Session(self.engine) as session:
            doc = session.get(DDocuments, result["id"])
            self.assertEqual(doc.montant_net_ttc, Decimal(25))
            self.assertEqual(doc.montant_net_ht, Decimal(25))
        draft["code"] = "OTHER001"
        draft["discount"] = Decimal(100)
        self.assertEqual(self.model._save(draft)["error"], "invalid_discount")
        self.assertEqual(self.counts(), (1, 1))

    def test_worker_is_responsive_and_double_click_saves_once(self):
        self.add_line()
        main_thread = threading.get_ident()
        persist = self.model._persist_document

        def slow_save(draft):
            self.assertNotEqual(threading.get_ident(), main_thread)
            time.sleep(0.08)
            return persist(draft)

        loop = QEventLoop()
        results = []

        def saved(document_id, code):
            self.assertEqual(threading.get_ident(), main_thread)
            self.assertEqual(self.counts(), (1, 1))  # Success is only emitted after commit.
            results.append((document_id, code))
            loop.quit()

        self.model.documentSaved.connect(saved)
        ticks = []
        timer = QTimer()
        timer.setInterval(5)
        timer.timeout.connect(lambda: ticks.append(True))
        timer.start()
        with patch.object(self.model, "_persist_document", slow_save):
            self.model.saveDocument(self.header)
            self.model.saveDocument(self.header)
            QTimer.singleShot(3000, loop.quit)
            loop.exec()
        timer.stop()
        self.assertTrue(ticks)
        self.assertEqual(len(results), 1)
        self.assertFalse(self.model.busy)
        self.model.saveDocument(self.header)
        self.assertEqual(self.counts(), (1, 1))

    def test_payments_are_not_silently_discarded(self):
        self.add_line()
        self.model.addPayment({"description": "Acompte", "amount": "10", "date": "2026-11-14"}, -1)
        errors = []
        self.model.saveFailed.connect(errors.append)
        self.model.saveDocument(self.header)
        self.assertEqual(errors, ["payments_not_supported"])
        self.assertEqual(self.counts(), (0, 0))

    def test_load_and_update_existing_document_and_lines(self):
        self.add_line()
        self.add_line(2, 3)
        created = self.model._save(self.draft())
        loaded = self.model._query_document(created["id"])
        self.assertIsNotNone(loaded)
        removed_line_id = loaded["lines"][0]["lineId"]
        edited_line = loaded["lines"][1]
        edited_line["priceHT"] = 20
        new_line = deepcopy(loaded["lines"][0])
        new_line.pop("lineId")
        new_line["id"] = 99
        self.model._lines = [edited_line, new_line]
        self.model._discount = Decimal(0)
        updated = self.model._update_document(
            {
                **loaded["header"],
                "editingDocumentId": created["id"],
                "lines": self.model._lines,
                "discount": Decimal(0),
            }
        )
        self.assertEqual(updated, created)
        self.assertEqual(self.counts(), (1, 3))
        with Session(self.engine) as session:
            document = session.get(DDocuments, created["id"])
            lines = session.scalars(
                select(DDocumentLignes)
                .where(DDocumentLignes.document_id == created["id"])
                .order_by(DDocumentLignes.id)
            ).all()
            self.assertEqual(sum(line.supprime == 0 for line in lines), 2)
            self.assertEqual(session.get(DDocumentLignes, removed_line_id).supprime, 1)
            self.assertEqual(lines[1].prix_unitaire_ht, Decimal("20.000000"))
            self.assertEqual(document.montant_ht, Decimal("84.691356"))

    def test_duplicate_creates_new_document_with_generated_code(self):
        self.add_line()
        created = self.model._save(self.draft(automatic=True))
        loaded = self.model._query_document(created["id"])
        duplicate = self.model._persist_document(
            {
                **loaded["header"],
                "lines": loaded["lines"],
                "discount": Decimal(loaded["discount"]),
                "automaticCode": True,
            }
        )
        self.assertEqual(created["code"], "BC001")
        self.assertEqual(duplicate["code"], "BC002")
        self.assertEqual(self.counts(), (2, 2))

    def test_list_delete_is_soft_delete(self):
        self.add_line()
        created = self.model._save(self.draft())
        list_model = ListeAchatsModel()
        self.assertEqual(list_model._mark_deleted([created["id"]]), 1)
        with Session(self.engine) as session:
            document = session.get(DDocuments, created["id"])
            self.assertEqual(document.supprime, 1)
            self.assertEqual(session.scalar(select(func.count()).select_from(DDocuments)), 1)

    def test_print_data_contains_document_header_and_active_lines(self):
        self.add_line()
        created = self.model._save(self.draft())
        documents = ListeAchatsModel()._load_print_documents([created["id"]])
        self.assertEqual(len(documents), 1)
        self.assertEqual(documents[0]["documentCode"], "CUSTOM009")
        self.assertEqual(documents[0]["supplierCode"], "FR001")
        self.assertEqual(documents[0]["lines"][0]["reference"], "ART001")
        self.assertEqual(documents[0]["lines"][0]["priceTTC"], Decimal("14.814814"))
        self.assertEqual(documents[0]["lines"][0]["totalTTC"], Decimal("29.629628"))


if __name__ == "__main__":
    unittest.main()
