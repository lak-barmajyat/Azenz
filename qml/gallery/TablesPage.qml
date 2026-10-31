pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../controls"
import "../components"
import "../theme"
import "SalesData.js" as SalesData

ColumnLayout {
    id: root
    signal notify(string title, string message)
    spacing: 16
    GallerySection {
        Layout.fillWidth: true
        title: "09–10 / Ventes · Barre d'outils & grille"
        subtitle: "Données d'exemple du HTML • Tri, redimensionnement, sélection, navigation clavier et menu contextuel"
        RowLayout {
            Layout.fillWidth: true
            Breadcrumb {}
            Item {
                Layout.fillWidth: true
            }
            AzenzComboBox {
                model: ["default", "loading", "empty", "error"]
                currentIndex: 0
                onActivated: table.viewState = currentText
            }
        }
        PageActionToolbar {
            Layout.fillWidth: true
            selectionCount: table.selectionCount
            onActionTriggered: function (action) {
                if (action === "columns")
                    columnOptions.open();
                else
                    root.notify("Action : " + action, "Signal émis pour l'écran Ventes.");
            }
        }
        DataGrid {
            id: table
            objectName: "salesGrid"
            Layout.fillWidth: true
            Layout.preferredHeight: 304
            columns: SalesData.columns
            rows: SalesData.rows
            onRowActivated: function (record) {
                root.notify("Entrée : " + record.documentCode, "L'écran décide de l'action à exécuter.");
            }
            onContextMenuRequested: function (record, x, y) {
                context.targetRecord = record;
                context.popup(table, x, y);
            }
            onRetryRequested: viewState = "default"
        }
        Label {
            text: "↑ ↓ déplace le focus • Espace coche la ligne • Ctrl / Shift : sélection multiple • Shift+F10 : menu contextuel"
            font.pixelSize: 11
            color: Colors.textSecondary
            Layout.fillWidth: true
        }
    }
    GallerySection {
        Layout.fillWidth: true
        title: "10 / États de lignes"
        subtitle: "Le focus clavier ne coche pas la ligne. Une pièce annulée reste interactive."
        Repeater {
            model: ["Défaut", "Sélectionné", "Focus", "Désactivé", "Sélection + focus"]
            RowLayout {
                required property int index
                required property string modelData
                Layout.fillWidth: true
                Label {
                    text: modelData
                    Layout.preferredWidth: 140
                    font.pixelSize: 12
                }
                DataGridRow {
                    record: SalesData.rows[index]
                    columns: SalesData.columns.slice(0, 4)
                    selected: index === 1 || index === 4
                    focused: index === 2 || index === 4
                    enabled: index !== 3
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    clip: true
                }
            }
        }
    }
    GallerySection {
        Layout.fillWidth: true
        title: "11 / Menus & surcouches"
        subtitle: "Menus avec focus clavier, séparateurs, raccourcis et sous-menus"
        RowLayout {
            AzenzButton {
                id: menuTrigger
                text: "Actions de gestion"
                iconName: "menu"
                variant: "secondary"
                onClicked: dropdown.popup(menuTrigger, 0, menuTrigger.height)
            }
            AzenzButton {
                text: "Affichage des colonnes"
                iconName: "columns"
                variant: "secondary"
                onClicked: columnOptions.open()
            }
            IconButton {
                iconName: "info"
                tooltip: "Infobulle temporisée · 400 ms"
            }
        }
    }
    ContextMenu {
        id: context
        ContextMenuItem {
            text: "Ouvrir"
            iconName: "open"
            shortcutText: "Entrée"
            onTriggered: root.notify("Ouvrir", context.targetRecord.documentCode)
        }
        ContextMenuItem {
            text: "Modifier"
            iconName: "edit"
            shortcutText: "F2"
            onTriggered: root.notify("Modifier", context.targetRecord.documentCode)
        }
        ContextMenuItem {
            text: "Dupliquer"
            iconName: "copy"
            shortcutText: "Ctrl+D"
            onTriggered: root.notify("Dupliquer", context.targetRecord.documentCode)
        }
        ContextMenuItem {
            text: "Imprimer"
            iconName: "print"
            shortcutText: "Ctrl+P"
            onTriggered: root.notify("Imprimer", context.targetRecord.documentCode)
        }
        MenuSeparator {}
        ContextMenuItem {
            text: "Supprimer"
            iconName: "delete"
            destructive: true
            shortcutText: "Suppr"
            onTriggered: root.notify("Suppression demandée", context.targetRecord.documentCode)
        }
    }
    DropdownMenu {
        id: dropdown
        DropdownMenuItem {
            text: "Action principale"
            iconName: "check"
            onTriggered: root.notify("Action principale", "Signal de démonstration")
        }
        DropdownMenuItem {
            text: "Option cochée"
            checkable: true
            checked: true
        }
        DropdownMenu {
            title: "Autres options"
            DropdownMenuItem {
                text: "Option supplémentaire"
                onTriggered: root.notify("Sous-menu", "Option sélectionnée")
            }
        }
        MenuSeparator {}
        DropdownMenuItem {
            text: "Option indisponible"
            enabled: false
        }
    }
    Popover {
        id: columnOptions
        x: Math.max(0, root.width - width)
        y: 90
        contentItem: ColumnLayout {
            Label {
                text: "Affichage des colonnes"
                font.weight: Font.DemiBold
            }
            AzenzCheckBox {
                text: "Code Client · Fixé"
                checked: true
                enabled: false
            }
            AzenzCheckBox {
                text: "Client · Fixé"
                checked: true
                enabled: false
            }
            AzenzCheckBox {
                id: dateOption
                text: "Date du document"
                checked: true
            }
            AzenzCheckBox {
                id: vatOption
                text: "TVA détaillée"
                checked: true
            }
            AzenzButton {
                text: "Appliquer"
                onClicked: {
                    table.columns = SalesData.columns.filter(function (c) {
                        return (c.key !== "date" || dateOption.checked) && (c.key !== "vat" || vatOption.checked);
                    });
                    columnOptions.close();
                }
            }
        }
    }
}
