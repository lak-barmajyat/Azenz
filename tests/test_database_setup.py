from database.setup import _split_sql


def test_split_sql_ignores_semicolons_inside_quoted_values() -> None:
    statements = _split_sql(
        "-- header;\nINSERT INTO users (name) VALUES ('Ada; Lovelace');\n-- trailing comment;\n;\n"
    )

    assert statements == [
        "-- header",
        "INSERT INTO users (name) VALUES ('Ada; Lovelace')",
        "-- trailing comment",
    ]
