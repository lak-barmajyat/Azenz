import csv
import tempfile
import unittest
from decimal import Decimal
from pathlib import Path

from PySide6.QtCore import QCoreApplication

from modules.achats.liste_achats.document_printing import render_purchase_documents
from modules.achats.liste_achats.model import ListeAchatsModel
from modules.achats.nouveau_doc import NouveauDocModel


class PurchaseActionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.app = QCoreApplication.instance() or QCoreApplication([])

    def setUp(self) -> None:
        self.document_model = NouveauDocModel()
        self.addCleanup(self.document_model.shutdown)
        self.header = {
            "supplier": {"value": 7},
            "code": "BC007",
            "type": "BC",
            "date": "2026-11-21",
        }
        self.document_model._lines = [
            {
                "id": 1,
                "lineId": 11,
                "articleId": 3,
                "quantity": 2,
                "priceHT": 10,
                "vat": 20,
                "tvaId": 1,
                "tvaCode": "TVA20",
                "totalHT": 20,
                "totalTTC": 24,
            }
        ]
        self.document_model._editing_document_id = 5
        self.document_model._header_draft = dict(self.header)
        self.document_model._original_state = self.document_model._change_state(self.header)

    def test_edit_change_flag_tracks_header_and_lines(self) -> None:
        self.assertFalse(self.document_model.hasChanges)
        self.document_model.updateDraftState({**self.header, "code": "BC008"})
        self.assertTrue(self.document_model.hasChanges)
        self.document_model.updateDraftState(self.header)
        self.assertFalse(self.document_model.hasChanges)
        self.document_model.removeLine(1)
        self.assertTrue(self.document_model.hasChanges)

    def test_new_document_baseline_tracks_later_header_changes(self) -> None:
        self.document_model.captureDraftBaseline(self.header)
        self.assertFalse(self.document_model.hasChanges)
        self.document_model.updateDraftState({**self.header, "code": "BC008"})
        self.assertTrue(self.document_model.hasChanges)

    def test_unchanged_edit_does_not_start_a_database_worker(self) -> None:
        unchanged = []
        self.document_model.documentUnchanged.connect(lambda: unchanged.append(True))
        self.document_model.saveDocument(self.header)
        self.assertEqual(unchanged, [True])
        self.assertIsNone(self.document_model._save_worker)

    def test_csv_export_is_excel_friendly_and_keeps_visible_columns(self) -> None:
        records = [
            {
                "supplierCode": "FR001",
                "supplier": "Fournisseur test",
                "documentCode": "BC001",
                "documentType": "Facture",
                "date": "21/11/2026",
                "ht": 100,
                "vat": 20,
                "ttc": 120,
            }
        ]
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "achats.csv"
            ListeAchatsModel._write_csv(path, records)
            self.assertTrue(path.read_bytes().startswith(b"\xef\xbb\xbf"))
            with path.open(encoding="utf-8-sig", newline="") as exported:
                rows = list(csv.reader(exported, delimiter=";"))
        self.assertEqual(rows[0][0:3], ["Code fournisseur", "Fournisseur", "Code document"])
        self.assertEqual(
            rows[1],
            ["FR001", "Fournisseur test", "BC001", "Facture", "21/11/2026", "100", "20", "120"],
        )

    def test_number_normalization_does_not_mark_equivalent_values_changed(self) -> None:
        self.document_model._lines[0]["quantity"] = "2,00"
        self.document_model._discount = Decimal("0.000")
        self.document_model.updateDraftState(self.header)
        self.assertFalse(self.document_model.hasChanges)

    def test_purchase_document_pdf_is_created(self) -> None:
        document = {
            "documentCode": "BC001",
            "documentType": "Facture",
            "date": "2026-11-21",
            "supplierCode": "FR001",
            "supplier": "Fournisseur test",
            "totalHT": Decimal("100"),
            "totalVAT": Decimal("20"),
            "discount": Decimal("0"),
            "totalNetTTC": Decimal("120"),
            "lines": [
                {
                    "reference": f"ART{index:03d}",
                    "description": "Article de démonstration avec une désignation longue",
                    "quantity": 2,
                    "priceHT": 10,
                    "priceTTC": 12,
                    "vat": 20,
                    "totalHT": 20,
                    "totalTTC": 24,
                }
                for index in range(70)
            ],
        }
        with tempfile.TemporaryDirectory() as directory:
            path = render_purchase_documents(Path(directory) / "achat.pdf", [document])
            content = path.read_bytes()
        self.assertTrue(content.startswith(b"%PDF-"))
        self.assertGreater(len(content), 1_000)


if __name__ == "__main__":
    unittest.main()
