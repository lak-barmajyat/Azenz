import unittest

from services.user_session import UserSession


class UserSessionTests(unittest.TestCase):
    def test_authenticate_and_clear(self) -> None:
        session = UserSession()
        self.assertIsNone(session.user_id)
        session.authenticate(42)
        self.assertEqual(session.user_id, 42)
        session.clear()
        self.assertIsNone(session.user_id)

    def test_rejects_invalid_user_id(self) -> None:
        session = UserSession()
        with self.assertRaises(ValueError):
            session.authenticate(0)


if __name__ == "__main__":
    unittest.main()
