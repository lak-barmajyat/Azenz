import QtQuick
import "../../../qml/components"
import "NouveauDocumentSample.js" as Sample

NouveauDocumentView {
    id: root
    objectName: "newDocumentScreen"
    property bool previewMode: false
    property var catalog: []
    property real appliedDiscount: 0
    property var editingLineId: null
    property var editingPaymentId: null
    readonly property real amountHT: articleRows.reduce(function(sum, row) {
        return sum + root.number(row.totalHT);
    }, 0)
    readonly property real amountVAT: articleRows.reduce(function(sum, row) {
        return sum + root.number(row.totalTTC) - root.number(row.totalHT);
    }, 0)
    readonly property real amountTTC: Math.max(0, amountHT + amountVAT - appliedDiscount)

    signal backRequested
    signal articleSearchRequested(string field, string query)
    signal lineAdded(var line)
    signal lineUpdated(var line)
    signal lineRemoved(var line)
    signal paymentAdded(var payment)
    signal paymentUpdated(var payment)
    signal paymentRemoved(var payment)
    signal discountApplied(real amount)
    signal saveRequested(var document)

    computedDraft: computeLine(linesTable.draft)
    totalHTText: formatMoney(amountHT)
    totalVATText: formatMoney(amountVAT)
    totalTTCText: formatMoney(amountTTC)
    editingLine: editingLineId !== null
    canAddLine: linesTable.selectedSuggestion !== null &&
                parseNumber(linesTable.draft.quantity) > 0

    function parseNumber(value) {
        if (typeof value === "number")
            return value;
        var text = String(value || "").replace(/\s|MAD/g, "");
        if (text.indexOf(",") >= 0)
            text = text.replace(/\./g, "").replace(",", ".");
        return text === "" ? NaN : Number(text);
    }

    function number(value) {
        var result = parseNumber(value);
        return isFinite(result) ? result : 0;
    }

    function formatMoney(value) {
        return Number(value).toLocaleString(Qt.locale("fr_MA"), "f", 2) + " MAD";
    }

    function computeLine(values) {
        var quantity = Math.max(0, number(values.quantity));
        var price = Math.max(0, number(values.priceHT));
        var vat = Math.max(0, number(values.vat));
        var totalHT = quantity * price;
        return {
            priceTTC: price * (1 + vat / 100),
            totalHT: totalHT,
            totalTTC: totalHT * (1 + vat / 100)
        };
    }

    function addLine(values, suggestion) {
        var quantity = parseNumber(values.quantity);
        var price = parseNumber(values.priceHT);
        if (!suggestion || !isFinite(quantity) || quantity <= 0 ||
                !isFinite(price) || price < 0) {
            errorMessage = qsTr("Choisissez un article et saisissez une quantité valide.");
            return;
        }
        errorMessage = "";
        var line = Object.assign({}, values, computeLine(values));
        line.quantity = quantity;
        line.priceHT = price;
        if (editingLineId !== null) {
            line.id = editingLineId;
            articleRows = articleRows.map(function(row) {
                return row.id === root.editingLineId ? line : row;
            });
            editingLineId = null;
            lineUpdated(line);
        } else {
            line.id = Date.now() + Math.random();
            articleRows = articleRows.concat([line]);
            lineAdded(line);
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
        articleRows = articleRows.filter(function(row) { return row.id !== line.id; });
        if (editingLineId === line.id) {
            editingLineId = null;
            linesTable.clearDraft();
        }
        lineRemoved(line);
    }

    function searchArticles(field, query) {
        articleSearchRequested(field, query);
        if (!previewMode)
            return;
        var needle = query.toLowerCase();
        articleSearchResults = {
            field: field,
            query: query,
            items: catalog.filter(function(article) {
                return String(article.reference).toLowerCase().includes(needle) ||
                       String(article.description).toLowerCase().includes(needle);
            })
        };
    }

    function addPayment() {
        paymentsTab.paymentDate.commit();
        var amount = parseNumber(paymentsTab.amountText);
        if (!paymentsTab.descriptionText.trim() || !isFinite(amount) || amount <= 0 ||
                !paymentsTab.paymentDate.hasValue) {
            errorMessage = qsTr("Saisissez la description, un montant positif et une date valide.");
            return;
        }
        errorMessage = "";
        var payment = {
            id: editingPaymentId !== null ? editingPaymentId : Date.now() + Math.random(),
            code: paymentsTab.referenceText.trim(),
            description: paymentsTab.descriptionText.trim(),
            amount: amount,
            amountDisplay: formatMoney(amount),
            date: paymentsTab.paymentDate.value,
            dateDisplay: Qt.formatDate(paymentsTab.paymentDate.value, "dd/MM/yyyy"),
            method: paymentsTab.paymentMethod.currentText
        };
        if (editingPaymentId !== null) {
            paymentRows = paymentRows.map(function(row) {
                return row.id === root.editingPaymentId ? payment : row;
            });
            editingPaymentId = null;
            paymentUpdated(payment);
        } else {
            paymentRows = paymentRows.concat([payment]);
            paymentAdded(payment);
        }
        paymentsTab.referenceText = "";
        paymentsTab.descriptionText = "";
        paymentsTab.amountText = "";
        paymentsTab.paymentDate.hasValue = false;
        paymentsTab.editingPayment = false;
    }

    function editPayment(payment) {
        editingPaymentId = payment.id;
        paymentsTab.referenceText = payment.code;
        paymentsTab.descriptionText = payment.description;
        paymentsTab.amountText = String(payment.amount);
        paymentsTab.paymentDate.value = payment.date;
        paymentsTab.paymentDate.hasValue = true;
        var index = paymentsTab.paymentMethods.indexOf(payment.method);
        paymentsTab.paymentMethod.currentIndex = index >= 0 ? index : 0;
        paymentsTab.editingPayment = true;
    }

    function removePayment(payment) {
        paymentRows = paymentRows.filter(function(row) { return row.id !== payment.id; });
        if (editingPaymentId === payment.id) {
            editingPaymentId = null;
            paymentsTab.editingPayment = false;
        }
        paymentRemoved(payment);
    }

    function applyDiscount() {
        var amount = parseNumber(paymentsTab.discountText);
        if (!isFinite(amount) || amount < 0 || amount > amountHT + amountVAT) {
            errorMessage = qsTr("La remise doit être comprise entre zéro et le total TTC.");
            return;
        }
        errorMessage = "";
        appliedDiscount = amount;
        discountApplied(amount);
    }

    function saveDocument() {
        documentDate.commit();
        if (clientPicker.currentIndex < 0 || !documentCode.trim() ||
                !documentDate.hasValue || articleRows.length === 0) {
            errorMessage = qsTr("Choisissez un client, renseignez le document et ajoutez au moins une ligne.");
            return;
        }
        errorMessage = "";
        saveRequested({
            client: clients[clientPicker.currentIndex],
            code: documentCode.trim(),
            type: documentType.currentValue,
            date: documentDate.value,
            lines: articleRows,
            payments: paymentRows,
            discount: appliedDiscount
        });
    }

    onPreviewModeChanged: if (previewMode) {
        catalog = Sample.catalog;
        articleRows = Sample.lines.map(function(line) { return Object.assign({}, line); });
        paymentRows = Sample.payments.map(function(payment) { return Object.assign({}, payment); });
        clients = Sample.clients;
        documentCode = "FA-2025-0843";
        clientPicker.currentIndex = 0;
        clientCode = Sample.clients[0].code;
        documentDate.value = new Date(2025, 7, 14);
        documentDate.hasValue = true;
        paymentsTab.referenceText = "VIR-2025-08";
        paymentsTab.descriptionText = "Acompte par virement bancaire";
        paymentsTab.amountText = "3610,28";
        paymentsTab.paymentDate.value = new Date(2025, 7, 14);
        paymentsTab.paymentDate.hasValue = true;
        activeTab = 1;
    }

    Connections {
        target: root.clientPicker
        function onActivated(index) {
            root.clientCode = root.clients[index].code || "";
        }
    }
    Connections {
        target: root.linesTable
        function onSearchRequested(field, query) { root.searchArticles(field, query); }
        function onAddRequested(values, suggestion) { root.addLine(values, suggestion); }
        function onEditRequested(line) { root.editLine(line); }
        function onRemoveRequested(line) { root.removeLine(line); }
    }
    Connections {
        target: root.paymentsTab.applyButton
        function onClicked() { root.applyDiscount(); }
    }
    Connections {
        target: root.paymentsTab.addButton
        function onClicked() { root.addPayment(); }
    }
    Connections {
        target: root.paymentsTab.grid
        function onRowActivated(payment) { root.editPayment(payment); }
        function onContextMenuRequested(payment, x, y) {
            paymentMenu.targetRecord = payment;
            paymentMenu.popup(root.paymentsTab.grid, x, y);
        }
    }
    Connections {
        target: root.backButton
        function onClicked() { root.backRequested(); }
    }
    Connections {
        target: root.saveButton
        function onClicked() { root.saveDocument(); }
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
