import QtQuick
import "../../../qml/components"

NouveauDocView {
    id: root
    objectName: "nouveauDocScreen"
    property bool previewMode: false
    property int editingLineId: -1
    property int editingPaymentId: -1
    // Installed by the Python launcher before loading the frame.
    // qmllint disable unqualified
    readonly property var backend: typeof nouveauDocModel !== "undefined" ? nouveauDocModel : null
    // qmllint enable unqualified

    signal backRequested

    clients: backend ? backend.clients : []
    documentTypes: backend ? backend.documentTypes : []
    lookupsBusy: backend ? backend.lookupsBusy : false
    codeBusy: backend ? backend.codeBusy : false
    onClientCodeChanged: {
        if (backend)
            clientPicker.currentIndex = backend.clientIndexForCode(clientCode);
    }

    busy: backend ? backend.busy : false
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
    totalHTText: formatMoney(backend ? backend.totals.ht : 0)
    totalVATText: formatMoney(backend ? backend.totals.vat : 0)
    totalTTCText: formatMoney(backend ? backend.totals.ttc : 0)
    editingLine: editingLineId >= 0
    canAddLine: backend !== null && linesTable.selectedSuggestion !== null && backend.validLine(linesTable.draft)

    Component.onCompleted: {
        documentDate.value = new Date();
        documentDate.hasValue = true;
        if (backend) {
            backend.reset();
            backend.loadLookups();
        }
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
            return qsTr("Choisissez un client, renseignez le document et ajoutez au moins une ligne.");
        }
    }

    function editLine(line) {
        editingLineId = line.id;
        linesTable.draft = Object.assign({}, line);
        linesTable.selectedSuggestion = line;
        activeTab = 0;
        Qt.callLater(linesTable.focusFirstSearch);
    }

    function removeLine(line) {
        if (!backend)
            return;
        backend.removeLine(line.id);
        if (editingLineId === line.id) {
            editingLineId = -1;
            linesTable.clearDraft();
        }
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
            client: clients[clientPicker.currentIndex] || null,
            code: documentCode,
            type: documentType.currentValue,
            date: documentDate.hasValue && documentDate.validationState !== "error" ? Qt.formatDate(documentDate.value, "yyyy-MM-dd") : ""
        });
    }

    Connections {
        target: root.backend
        function onLookupsChanged() {
            root.errorMessage = "";
            root.clientPicker.currentIndex = root.backend.clientIndexForCode(root.clientCode);
            root.documentType.currentIndex = root.documentTypes.length > 0 ? 0 : -1;
            root.backend.generateDocumentCode(root.documentType.currentValue || "");
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
            root.errorMessage = qsTr("Impossible de charger les clients et les types de documents. Vérifiez la connexion et rouvrez le formulaire.");
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
            saved.message = qsTr("Le document %1 et ses lignes ont été enregistrés en brouillon.").arg(code);
            saved.open();
        }
    }
    Connections {
        target: root.documentType
        function onCurrentValueChanged() {
            if (root.backend)
                root.backend.generateDocumentCode(root.documentType.currentValue || "");
        }
    }
    Connections {
        target: root.clientPicker
        function onActivated(index) {
            root.clientCode = index >= 0 && index < root.clients.length ? root.clients[index].code || "" : "";
        }
    }
    Connections {
        target: root.linesTable
        function onSearchRequested(field, query) {
            if (root.backend)
                root.backend.searchArticles(field, query);
        }
        function onAddRequested(values, suggestion) {
            if (root.backend && root.backend.addLine(values, suggestion || {}, root.editingLineId))
                root.editingLineId = -1;
        }
        function onEditRequested(line) {
            root.editLine(line);
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
