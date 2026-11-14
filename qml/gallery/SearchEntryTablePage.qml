import QtQuick
import QtQuick.Layouts
import "../components"

ColumnLayout {
    id: root
    signal notify(string title, string message)
    spacing: 16

    property var catalog: [
        {id: 1, reference: "LAP-001", description: "MacBook Pro 14", unit: "pcs", price: 1999, vat: 20},
        {id: 2, reference: "ACC-052", description: "USB-C Hub", unit: "pcs", price: 89, vat: 20},
        {id: 3, reference: "MON-024", description: "24-inch Monitor", unit: "pcs", price: 260, vat: 20}
    ]

    GallerySection {
        Layout.fillWidth: true
        title: qsTr("Tableau de saisie")
        subtitle: qsTr("Rechercher par référence ou description, sélectionner, puis ajouter avec Entrée")

        SearchEntryTable {
            id: table
            objectName: "searchEntryTablePreview"
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            defaultValues: ({quantity: 1})
            columns: [
                {key: "reference", title: qsTr("Référence"), width: 140, searchable: true,
                 placeholder: qsTr("Rechercher une référence")},
                {key: "description", title: qsTr("Description"), width: 280, fill: 1, searchable: true,
                 placeholder: qsTr("Rechercher ou saisir un article...")},
                {key: "quantity", title: qsTr("Qté"), width: 76, editable: true,
                 inputType: "number", alignment: "right"},
                {key: "unit", title: qsTr("Unité"), width: 76},
                {key: "price", title: qsTr("Prix HT"), width: 110, editable: true,
                 inputType: "currency", alignment: "right"},
                {key: "vat", title: qsTr("TVA %"), width: 76, alignment: "right"}
            ]
            rows: [
                {id: 1, reference: "LAP-001", description: "MacBook Pro 14",
                 quantity: 5, unit: "pcs", price: 1999, vat: 20},
                {id: 2, reference: "ACC-052", description: "USB-C Hub",
                 quantity: 10, unit: "pcs", price: 89, vat: 20}
            ]
            onSearchRequested: function(field, query) {
                var needle = query.toLowerCase();
                searchResults = {
                    field: field,
                    query: query,
                    items: root.catalog.filter(function(article) {
                        return article.reference.toLowerCase().includes(needle) ||
                               article.description.toLowerCase().includes(needle);
                    })
                };
            }
            onAddRequested: function(values, suggestion) {
                rows = rows.concat([Object.assign({}, values, {id: Date.now()})]);
                root.notify(qsTr("Ligne ajoutée"), suggestion.description);
            }
            onEditRequested: function(row) {
                root.notify(qsTr("Modification demandée"), row.description);
            }
            onRemoveRequested: function(row) {
                rows = rows.filter(function(item) { return item.id !== row.id; });
            }
        }
    }
}
