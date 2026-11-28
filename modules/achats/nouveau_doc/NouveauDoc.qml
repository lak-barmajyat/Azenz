import QtQuick
import "../../../qml/components"

NouveauDocView {
    id: root
    objectName: "nouveauDocScreen"
    property bool previewMode: false
    property int editingPaymentId: -1
    property string documentMode: "new"
    property int sourceDocumentId: 0
    property var loadedHeader: ({})
    property bool initializingDocument: false
    property bool opened: false
    // Installed by the Python launcher before loading the frame.
    // qmllint disable unqualified
    readonly property var backend: typeof nouveauDocAchatsModel !== "undefined" ? nouveauDocAchatsModel : null
    // qmllint enable unqualified

    signal backRequested

    suppliers: backend ? backend.suppliers : []
    documentTypes: backend ? backend.documentTypes : []
    lookupsBusy: backend ? backend.lookupsBusy : false
    codeBusy: backend ? backend.codeBusy : false
    onSupplierCodeChanged: {
        if (backend)
            supplierPicker.currentIndex = backend.supplierIndexForCode(supplierCode);
        trackDraft();
    }

    busy: backend ? backend.busy : false
    canSave: documentMode !== "edit" || (backend ? backend.hasChanges : false)
    pageTitle: documentMode === "edit" ? qsTr("Modifier le document")
               : documentMode === "duplicate" ? qsTr("Dupliquer le document")
               : qsTr("Nouveau document")
    articleSearchResults: backend ? backend.articleSearchResults : ({field: "", query: "", items: []})
    articleSearchBusy: backend ? backend.searchBusy : false
    articleRows: backend ? backend.lines : []
    paymentRows: backend ? backend.payments.map(function (payment) {
        return Object.assign({}, payment, {
            amountDisplay: root.formatMoney(payment.amount),
            dateDisplay: Qt.formatDate(new Date(payment.date + "T00:00:00"), "dd/MM/yyyy")
        });
    }) : []
    computedDraft: backend ? backend.computeLine(linesTable.draft) : ({})
    computedEdit: backend ? backend.computeLine(linesTable.editDraft) : ({})
    totalHTText: formatMoney(backend ? backend.totals.ht : 0)
    totalVATText: formatMoney(backend ? backend.totals.vat : 0)
    totalTTCText: formatMoney(backend ? backend.totals.ttc : 0)
    canAddLine: backend !== null && linesTable.selectedSuggestion !== null && backend.validLine(linesTable.draft)
    canUpdateLine: backend !== null && backend.validLine(linesTable.editDraft)

    Component.onCompleted: Qt.callLater(function () {
        if (!root.opened)
            root.openDocument("new", 0);
    })

    function openDocument(action, documentId) {
        opened = true;
        documentMode = action === "duplicate" ? "duplicate" : action === "edit" ? "edit" : "new";
        sourceDocumentId = documentId || 0;
        loadedHeader = {};
        linesTable.finishEdit();
        initializingDocument = true;
        supplierCode = "";
        supplierPicker.currentIndex = -1;
        documentCode = "";
        documentType.currentIndex = -1;
        documentDate.value = new Date();
        documentDate.hasValue = true;
        paymentsTab.discountText = "0,00";
        if (backend) {
            backend.reset();
            backend.loadLookups();
            if (sourceDocumentId > 0)
                backend.loadDocument(sourceDocumentId, documentMode === "duplicate");
        }
        Qt.callLater(function () {
            root.initializingDocument = false;
            root.trackDraft();
        });
    }

    function headerDraft() {
        return {
            supplier: suppliers[supplierPicker.currentIndex] || null,
            code: documentCode,
            type: documentType.currentValue || "",
            date: documentDate.hasValue ? Qt.formatDate(documentDate.value, "yyyy-MM-dd") : ""
        };
    }

    function trackDraft() {
        if (!initializingDocument && backend)
            backend.updateDraftState(headerDraft());
    }

    function applyLoadedHeader() {
        if (!loadedHeader.id)
            return;
        initializingDocument = true;
        supplierCode = loadedHeader.supplierCode;
        supplierPicker.currentIndex = backend ? backend.supplierIndexForCode(loadedHeader.supplierCode) : -1;
        documentType.currentIndex = backend ? backend.documentTypeIndexForCode(loadedHeader.type) : -1;
        documentCode = documentMode === "duplicate" && backend ? backend.documentCode : loadedHeader.code;
        documentDate.value = new Date(loadedHeader.date + "T00:00:00");
        documentDate.hasValue = true;
        paymentsTab.discountText = String(loadedHeader.discount || 0);
        Qt.callLater(function () {
            root.initializingDocument = false;
            root.trackDraft();
        });
    }

    function formatMoney(value) {
        return Number(value).toLocaleString(Qt.locale("fr_MA"), "f", 2) + qsTr(" MAD");
    }

    function validationMessage(code) {
        switch (code) {
        case "invalid_line":
            return qsTr("Choisissez un article et saisissez une quantité, un prix et une TVA valides.");
        case "invalid_payment":
            return qsTr("Saisissez la description, un montant positif et une date valide.");
        case "invalid_article":
            return qsTr("Un article n'existe plus. Recherchez-le à nouveau avant d'enregistrer.");
        case "invalid_discount":
            return qsTr("La remise doit être comprise entre zéro et le total TTC.");
        default:
            return qsTr("Choisissez un fournisseur, renseignez le document et ajoutez au moins une ligne.");
        }
    }

    function removeLine(line) {
        if (!backend)
            return;
        backend.removeLine(line.id);
        if (linesTable.editingRowId === line.id)
            linesTable.finishEdit();
    }

    function addPayment() {
        if (!backend)
            return;
        paymentsTab.paymentDate.commit();
        var values = {
            code: paymentsTab.referenceText,
            description: paymentsTab.descriptionText,
            amount: paymentsTab.amountText,
            date: paymentsTab.paymentDate.hasValue && paymentsTab.paymentDate.validationState !== "error" ? Qt.formatDate(paymentsTab.paymentDate.value, "yyyy-MM-dd") : "",
            method: paymentsTab.paymentMethod.currentText
        };
        if (backend.addPayment(values, editingPaymentId))
            clearPaymentForm();
    }

    function clearPaymentForm() {
        editingPaymentId = -1;
        paymentsTab.referenceText = "";
        paymentsTab.descriptionText = "";
        paymentsTab.amountText = "";
        paymentsTab.paymentDate.hasValue = false;
        paymentsTab.paymentDate.text = "";
        paymentsTab.paymentDate.validationState = "default";
        paymentsTab.editingPayment = false;
    }

    function editPayment(payment) {
        editingPaymentId = payment.id;
        paymentsTab.referenceText = payment.code;
        paymentsTab.descriptionText = payment.description;
        paymentsTab.amountText = String(payment.amount);
        paymentsTab.paymentDate.value = new Date(payment.date + "T00:00:00");
        paymentsTab.paymentDate.hasValue = true;
        paymentsTab.paymentDate.validationState = "default";
        var index = paymentsTab.paymentMethods.indexOf(payment.method);
        paymentsTab.paymentMethod.currentIndex = index >= 0 ? index : 0;
        paymentsTab.editingPayment = true;
    }

    function removePayment(payment) {
        if (!backend)
            return;
        backend.removePayment(payment.id);
        if (editingPaymentId === payment.id)
            clearPaymentForm();
    }

    function saveDocument() {
        if (!backend)
            return;
        documentDate.commit();
        errorMessage = "";
        backend.saveDocument({
            supplier: suppliers[supplierPicker.currentIndex] || null,
            code: documentCode,
            type: documentType.currentValue,
            date: documentDate.hasValue && documentDate.validationState !== "error" ? Qt.formatDate(documentDate.value, "yyyy-MM-dd") : ""
        });
    }

    Connections {
        target: root.backend
        function onLookupsChanged() {
            root.errorMessage = "";
            if (root.loadedHeader.id) {
                root.applyLoadedHeader();
            } else {
                root.documentType.currentIndex = root.documentTypes.length > 0 ? 0 : -1;
                root.backend.generateDocumentCode(root.documentType.currentValue || "");
            }
        }
        function onDocumentLoaded(header) {
            root.loadedHeader = header;
            root.applyLoadedHeader();
        }
        function onDocumentLoadFailed(code) {
            root.errorMessage = qsTr("Impossible de charger ce document. Il a peut-être été supprimé.");
        }
        function onDocumentCodeChanged() {
            root.documentCode = root.backend.documentCode;
            if (root.backend.documentCode)
                root.errorMessage = "";
        }
        function onCodeGenerationFailed() {
            root.errorMessage = qsTr("Impossible de générer le code du document. Vérifiez le dernier code enregistré et la connexion.");
        }
        function onLookupsFailed() {
            root.errorMessage = qsTr("Impossible de charger les fournisseurs et les types de documents. Vérifiez la connexion et rouvrez le formulaire.");
        }
        function onDataChanged() {
            root.errorMessage = "";
        }
        function onValidationFailed(code) {
            root.errorMessage = root.validationMessage(code);
        }
        function onSearchFailed() {
            root.errorMessage = qsTr("Impossible de rechercher les articles. Vérifiez la connexion.");
        }
        function onSaveFailed(code) {
            if (code === "duplicate_code")
                root.errorMessage = qsTr("Ce code document existe déjà pour ce type. Choisissez un autre code.");
            else if (code === "payments_not_supported")
                root.errorMessage = qsTr("Les règlements ne sont pas encore enregistrables ici. Retirez-les pour enregistrer le document et ses lignes.");
            else if (code === "preview_only")
                root.errorMessage = qsTr("L'enregistrement n'est pas disponible en mode aperçu.");
            else if (code === "service_unavailable")
                root.errorMessage = qsTr("Échec de l'enregistrement. Vos saisies sont conservées ; vérifiez la connexion et réessayez.");
            else
                root.errorMessage = root.validationMessage(code);
        }
        function onDocumentSaved(documentId, code) {
            root.errorMessage = "";
            root.documentCode = code;
            saved.message = root.documentMode === "edit"
                    ? qsTr("Les modifications du document %1 ont été enregistrées.").arg(code)
                    : qsTr("Le document %1 et ses lignes ont été enregistrés en brouillon.").arg(code);
            saved.open();
        }
    }
    Connections {
        target: root.documentType
        function onCurrentValueChanged() {
            if (!root.initializingDocument && root.backend && root.documentMode !== "edit")
                root.backend.generateDocumentCode(root.documentType.currentValue || "");
            root.trackDraft();
        }
    }
    Connections {
        target: root.supplierPicker
        function onCurrentIndexChanged() {
            root.trackDraft();
        }
        function onActivated(index) {
            root.supplierCode = index >= 0 && index < root.suppliers.length ? root.suppliers[index].code || "" : "";
            root.trackDraft();
        }
    }
    Connections {
        target: root.documentCodeField
        function onTextChanged() { root.trackDraft(); }
    }
    Connections {
        target: root.documentDate
        function onDateEdited(value) { root.trackDraft(); }
        function onDateCleared() { root.trackDraft(); }
    }
    Connections {
        target: root.linesTable
        function onSearchRequested(field, query) {
            if (root.backend)
                root.backend.searchArticles(field, query);
        }
        function onAddRequested(values, suggestion) {
            if (root.backend)
                root.backend.addLine(values, suggestion || {}, -1);
        }
        function onUpdateRequested(row, values, suggestion) {
            if (root.backend && root.backend.addLine(values, suggestion, row.id))
                root.linesTable.finishEdit();
        }
        function onRemoveRequested(line) {
            root.removeLine(line);
        }
    }
    Connections {
        target: root.paymentsTab.applyButton
        function onClicked() {
            if (root.backend)
                root.backend.applyDiscount(root.paymentsTab.discountText);
        }
    }
    Connections {
        target: root.paymentsTab.addButton
        function onClicked() {
            root.addPayment();
        }
    }
    Connections {
        target: root.paymentsTab.grid
        function onRowActivated(payment) {
            root.editPayment(payment);
        }
        function onContextMenuRequested(payment, x, y) {
            paymentMenu.targetRecord = payment;
            paymentMenu.popup(root.paymentsTab.grid, x, y);
        }
    }
    Connections {
        target: root.backButton
        function onClicked() {
            root.backRequested();
        }
    }
    Connections {
        target: root.saveButton
        function onClicked() {
            root.saveDocument();
        }
    }
    AzenzDialog {
        id: saved
        objectName: "nouveauDocSaved"
        dialogType: "information"
        title: qsTr("Document enregistré")
        confirmText: qsTr("Retour à la liste")
        onClosed: root.backRequested()
    }
    ContextMenu {
        id: paymentMenu
        ContextMenuItem {
            text: qsTr("Modifier")
            iconName: "edit"
            onTriggered: root.editPayment(paymentMenu.targetRecord)
        }
        ContextMenuItem {
            text: qsTr("Supprimer")
            iconName: "delete"
            destructive: true
            onTriggered: root.removePayment(paymentMenu.targetRecord)
        }
    }
}
