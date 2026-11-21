"""Qt objects stay alive here until the application event loop finishes."""

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from modules.achats.liste_achats.model import ListeAchatsModel
from modules.achats.nouveau_doc import NouveauDocModel as NouveauDocAchatsModel
from modules.login.model import LoginModel
from modules.ventes.liste_ventes.model import ListeVentesModel
from modules.ventes.nouveau_doc import NouveauDocModel
from services.logger import get_logger
from services.paths import PROJECT_ROOT, QML_DIR


def run_application(argv: list[str]) -> int:
    app = QGuiApplication(argv)
    app.setApplicationName("Azenz")
    app.setOrganizationName("LakSoftware")
    engine = QQmlApplicationEngine()
    document_model = NouveauDocModel(engine)
    purchase_document_model = NouveauDocAchatsModel(engine)
    app.aboutToQuit.connect(document_model.shutdown)
    app.aboutToQuit.connect(purchase_document_model.shutdown)
    engine.rootContext().setContextProperty("nouveauDocModel", document_model)
    engine.rootContext().setContextProperty("nouveauDocAchatsModel", purchase_document_model)
    model = LoginModel(engine)
    sales_model = ListeVentesModel(engine)
    purchase_model = ListeAchatsModel(engine)
    engine.addImportPath(str(PROJECT_ROOT))
    engine.addImportPath(str(QML_DIR))
    engine.rootContext().setContextProperty("loginModel", model)
    engine.rootContext().setContextProperty("listeVentesModel", sales_model)
    engine.rootContext().setContextProperty("listeAchatsModel", purchase_model)
    app.aboutToQuit.connect(model.shutdown)
    app.aboutToQuit.connect(sales_model.shutdown)
    app.aboutToQuit.connect(purchase_model.shutdown)
    engine.load(QUrl.fromLocalFile(str(QML_DIR / "App.qml")))
    if not engine.rootObjects():
        raise RuntimeError("Unable to load the application UI")
    get_logger(__name__).info("Azenz started successfully")
    return app.exec()
