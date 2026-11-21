import unittest

from services.code_generation import next_code


class CodeGenerationTests(unittest.TestCase):
    def test_existing_formats_and_padding(self) -> None:
        for saved, expected in (
            ("FA005", "FA006"),
            ("DV002", "DV003"),
            ("FA-2026-0040", "FA-2026-0041"),
            ("ART0009", "ART0010"),
            ("FAM999", "FAM1000"),
            ("REG000", "REG001"),
        ):
            with self.subTest(saved=saved):
                self.assertEqual(next_code(saved, prefix="unused"), expected)

    def test_empty_series(self) -> None:
        self.assertEqual(next_code(None, prefix="FA"), "FA001")
        self.assertEqual(next_code(None, prefix="ART-", width=4), "ART-0001")

    def test_preview_does_not_advance_or_share_a_counter(self) -> None:
        self.assertEqual(next_code("FA005", prefix="FA"), "FA006")
        self.assertEqual(next_code("DV002", prefix="DV"), "DV003")
        self.assertEqual(next_code("FA005", prefix="FA"), "FA006")
        self.assertEqual(next_code("FA006", prefix="FA"), "FA007")

    def test_invalid_saved_code_is_not_silently_restarted(self) -> None:
        for saved in ("", "FA", "FA005-draft"):
            with self.subTest(saved=saved), self.assertRaises(ValueError):
                next_code(saved, prefix="FA")


if __name__ == "__main__":
    unittest.main()
