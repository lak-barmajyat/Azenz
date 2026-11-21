import QtQuick
import QtQuick.Dialogs
import "../../../qml/components"

ListeVentesView {
    id: root
    property var sourceRows: []
    property bool updatingFilters: false
    property var pendingDelete: []
    signal actionRequested(string action, var records)
    signal navigationRequested(string page)
    signal backRequested
    signal quitRequested
    signal minimizeRequested
    signal maximizeRequested
    readonly property var selectedRecords: records.filter(function (row) {
        return root.grid.selectedIds.indexOf(row.id) >= 0;
    })
    // Python installs this context property before loading the view.
    // qmllint disable unqualified
    readonly property var backend: typeof listeVentesModel !== "undefined" ? listeVentesModel : null
    // qmllint enable unqualified
    property bool loadError: false
    records: backend ? backend.records : []
    totalHT: backend ? backend.totals.ht : 0
    totalVAT: backend ? backend.totals.vat : 0
    totalTTC: backend ? backend.totals.ttc : 0
    viewState: backend && backend.busy ? "loading" : loadError || !backend ? "error" : "default"
    documentTypes: [
        {
            text: qsTr("Tous les types"),
            value: ""
        }
    ].concat(backend ? backend.documentTypes.map(function (name) {
        return {
            text: name,
            value: name
        };
    }) : [])
    Component.onCompleted: {
        if (backend) {
            backend.applyFilters("", "", "", "");
            if (previewMode)
                backend.setPreviewRecords(sourceRows);
            else
                backend.refresh();
        }
    }
    onSourceRowsChanged: {
        if (previewMode && backend)
            backend.setPreviewRecords(sourceRows);
    }
    Connections {
        target: root.backend
        function onDataChanged() {
            root.loadError = false;
            root.filterError = "";
        }
        function onLoadFailed(code) {
            root.loadError = true;
        }
        function onValidationFailed(code) {
            root.filterError = code === "invalid_range" ? qsTr("La date de début doit précéder la date de fin.") : qsTr("Veuillez saisir des dates valides (JJ/MM/AAAA).");
        }
        function onDeleteFailed(code) {
            root.filterError = qsTr("La suppression a échoué. Vérifiez la connexion et réessayez.");
        }
        function onExportFailed(code) {
            root.filterError = qsTr("Impossible d'enregistrer le fichier d'export.");
        }
    }
    columns: [
        {
            key: "clientCode",
            title: qsTr("CODE CLIENT"),
            type: "code",
            width: 110
        },
        {
            key: "client",
            title: qsTr("CLIENT"),
            width: Math.max(260, grid.width - 838)
        },
        {
            key: "documentCode",
            title: qsTr("CODE DOC"),
            type: "code",
            width: 108
        },
        {
            key: "documentType",
            title: qsTr("TYPE"),
            type: "status",
            alignment: "center",
            width: 100,
            sortable: false
        },
        {
            key: "date",
            title: qsTr("DATE"),
            type: "date",
            alignment: "center",
            width: 104
        },
        {
            key: "ht",
            title: qsTr("TOTAL HT"),
            type: "currency",
            suffix: qsTr("MAD"),
            alignment: "right",
            width: 128
        },
        {
            key: "vat",
            title: qsTr("TVA"),
            type: "currency",
            suffix: qsTr("MAD"),
            alignment: "right",
            width: 120
        },
        {
            key: "ttc",
            title: qsTr("TOTAL TTC"),
            type: "currency",
            suffix: qsTr("MAD"),
            alignment: "right",
            width: 132
        }
    ]
    function applyFilters() {
        if (updatingFilters)
            return;
        updatingFilters = true;
        fromDate.commit();
        toDate.commit();
        updatingFilters = false;
        if (fromDate.validationState === "error" || toDate.validationState === "error") {
            filterError = qsTr("Veuillez saisir des dates valides (JJ/MM/AAAA).");
            return;
        }
        if (backend)
            backend.applyFilters(codeFilter.text, typeFilter.currentValue || "", fromDate.hasValue ? Qt.formatDate(fromDate.value, "yyyy-MM-dd") : "", toDate.hasValue ? Qt.formatDate(toDate.value, "yyyy-MM-dd") : "");
    }
    function resetFilters() {
        updatingFilters = true;
        codeFilter.text = "";
        typeFilter.currentIndex = 0;
        fromDate.hasValue = false;
        fromDate.text = "";
        fromDate.validationState = "default";
        toDate.hasValue = false;
        toDate.text = "";
        toDate.validationState = "default";
        updatingFilters = false;
        applyFilters();
    }
    function requestAction(action, target) {
        if (backend && backend.busy)
            return;
        if (action === "refresh" && !previewMode) {
            if (backend)
                backend.refresh();
            return;
        }
        var selected = target || selectedRecords;
        if (["edit", "duplicate", "open"].indexOf(action) >= 0 && selected.length !== 1)
            return;
        if (["delete", "print"].indexOf(action) >= 0 && selected.length === 0)
            return;
        if (action === "delete") {
            pendingDelete = selected.slice();
            confirmDelete.open();
            return;
        }
        if (action === "export") {
            exportDialog.open();
            return;
        }
        actionRequested(action, action === "export" ? records : selected);
    }
    Connections {
        target: root.codeFilter
        function onTextChanged() {
            root.applyFilters();
        }
    }
    Connections {
        target: root.typeFilter
        function onActivated(index) {
            root.applyFilters();
        }
    }
    Connections {
        target: root.fromDate
        function onDateCleared() {
            root.applyFilters();
        }
        function onDateEdited(value) {
            root.applyFilters();
        }
    }
    Connections {
        target: root.toDate
        function onDateCleared() {
            root.applyFilters();
        }
        function onDateEdited(value) {
            root.applyFilters();
        }
    }
    Connections {
        target: root.applyButton
        function onClicked() {
            root.applyFilters();
        }
    }
    Connections {
        target: root.resetButton
        function onClicked() {
            root.resetFilters();
        }
    }
    Connections {
        target: root.newButton
        function onClicked() {
            root.requestAction("new");
        }
    }
    Connections {
        target: root.newDocumentButton
        function onClicked() {
            root.requestAction("new");
        }
    }
    Connections {
        target: root.editButton
        function onClicked() {
            root.requestAction("edit");
        }
    }
    Connections {
        target: root.deleteButton
        function onClicked() {
            root.requestAction("delete");
        }
    }
    Connections {
        target: root.duplicateButton
        function onClicked() {
            root.requestAction("duplicate");
        }
    }
    Connections {
        target: root.printButton
        function onClicked() {
            root.requestAction("print");
        }
    }
    Connections {
        target: root.exportButton
        function onClicked() {
            root.requestAction("export");
        }
    }
    Connections {
        target: root.refreshButton
        function onClicked() {
            root.requestAction("refresh");
        }
    }
    Connections {
        target: root.backButton
        function onClicked() {
            root.backRequested();
        }
    }
    Connections {
        target: root.grid
        function onContextMenuRequested(record, x, y) {
            context.targetRecord = record;
            context.popup(root.grid, x, y);
        }
        function onRowActivated(record) {
            root.requestAction("open", [record]);
        }
        function onRetryRequested() {
            root.requestAction("refresh");
        }
    }
    Shortcut {
        sequence: "F5"
        enabled: root.visible
        onActivated: root.requestAction("refresh")
    }
    Shortcut {
        sequence: "Ctrl+N"
        enabled: root.visible
        onActivated: root.requestAction("new")
    }
    Shortcut {
        sequence: "F2"
        enabled: root.visible && root.grid.activeFocus
        onActivated: root.requestAction("edit")
    }
    Shortcut {
        sequence: "Delete"
        enabled: root.visible && root.grid.activeFocus
        onActivated: root.requestAction("delete")
    }
    ContextMenu {
        id: context
        ContextMenuItem {
            text: qsTr("Ouvrir")
            iconName: "open"
            shortcutText: qsTr("Entrée")
            onTriggered: root.requestAction("open", [context.targetRecord])
        }
        ContextMenuItem {
            text: qsTr("Modifier")
            iconName: "edit"
            shortcutText: qsTr("F2")
            onTriggered: root.requestAction("edit", [context.targetRecord])
        }
        ContextMenuItem {
            text: qsTr("Dupliquer")
            iconName: "copy"
            onTriggered: root.requestAction("duplicate", [context.targetRecord])
        }
        ContextMenuItem {
            text: qsTr("Imprimer")
            iconName: "print"
            onTriggered: root.requestAction("print", [context.targetRecord])
        }
        MenuSeparator {}
        ContextMenuItem {
            text: qsTr("Supprimer")
            iconName: "delete"
            destructive: true
            onTriggered: root.requestAction("delete", [context.targetRecord])
        }
    }
    AzenzDialog {
        id: confirmDelete
        objectName: "ventesDeleteDialog"
        dialogType: "destructive"
        title: qsTr("Confirmer la suppression")
        message: qsTr("Supprimer %n document(s) sélectionné(s) ?", "", root.pendingDelete.length)
        supportingMessage: qsTr("Vérifiez les documents sélectionnés avant de continuer.")
        onAccepted: {
            if (root.backend) {
                root.backend.deleteDocuments(root.pendingDelete.map(function (record) {
                    return record.id;
                }));
            }
            root.pendingDelete = [];
        }
        onRejected: root.pendingDelete = []
    }
    FileDialog {
        id: exportDialog
        title: qsTr("Exporter la liste des ventes")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("Fichier Excel CSV (*.csv)")]
        defaultSuffix: "csv"
        onAccepted: {
            if (root.backend)
                root.backend.exportCsv(selectedFile, root.records);
        }
    }
}
