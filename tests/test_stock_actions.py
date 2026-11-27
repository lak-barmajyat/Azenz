import csv
import tempfile
import unittest
from datetime import datetime
from decimal import Decimal
from pathlib import Path

from modules.stockage.document_printing import render_stock_documents
from modules.stockage.liste_stock.model import ListeStockModel


class StockActionTests(unittest.TestCase):
    def test_csv_export_is_excel_friendly_and_keeps_visible_columns(self) -> None:
        records = [
            {
                "code": "INV-2026-0001",
                "type": "Inventaire de stock",
                "date": "15/11/2026",
                "status": "Validé",
                "comment": "Inventaire tournant",
            }
        ]
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "stockage.csv"
            ListeStockModel._write_csv(path, records)
            self.assertTrue(path.read_bytes().startswith(b"\xef\xbb\xbf"))
            with path.open(encoding="utf-8-sig", newline="") as exported:
                rows = list(csv.reader(exported, delimiter=";"))
        self.assertEqual(
            rows[0], ["Code document", "Type document", "Date", "Statut", "Commentaire"]
        )
        self.assertEqual(
            rows[1],
            [
                "INV-2026-0001",
                "Inventaire de stock",
                "15/11/2026",
                "Validé",
                "Inventaire tournant",
            ],
        )

    def test_stock_document_pdf_is_created(self) -> None:
        document = {
            "documentCode": "INV-2026-0001",
            "documentType": "Inventaire de stock",
            "date": datetime(2026, 11, 15),
            "status": "VALIDE",
            "comment": "Inventaire tournant",
            "lines": [
                {
                    "reference": f"ART-{index:03d}",
                    "description": "Article de démonstration",
                    "quantity": Decimal("12.5000"),
                    "comment": "Quantité finale inventoriée",
                }
                for index in range(70)
            ],
        }
        with tempfile.TemporaryDirectory() as directory:
            path = render_stock_documents(Path(directory) / "stockage.pdf", [document])
            content = path.read_bytes()
        self.assertTrue(content.startswith(b"%PDF-"))
        self.assertGreater(len(content), 1_000)


if __name__ == "__main__":
    unittest.main()
