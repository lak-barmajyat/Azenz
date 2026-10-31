pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import "../controls"
import "../components"
import "../theme"

ColumnLayout {
    id: root
    signal notify(string title, string message)
    spacing: 16
    GallerySection {
        title: "12 / Badges & indicateurs"
        subtitle: "Cinq variantes sémantiques • Styles subtle / filled • Types de documents et état de connexion"
        Layout.fillWidth: true
        Repeater {
            model: ["neutral", "info", "success", "warning", "danger"]
            RowLayout {
                required property string modelData
                spacing: 20
                Label {
                    text: modelData
                    Layout.preferredWidth: 100
                    font.pixelSize: 12
                }
                Badge {
                    text: modelData
                    variant: modelData
                }
                Badge {
                    text: modelData
                    variant: modelData
                    dot: true
                }
                Badge {
                    text: modelData
                    variant: modelData
                    filled: true
                }
                Badge {
                    text: modelData
                    variant: modelData
                    filled: true
                    dot: true
                }
            }
        }
        RowLayout {
            spacing: 12
            Repeater {
                model: ["DV", "BC", "BL", "BR", "FA", "FR"]
                DocumentTypeBadge {
                    required property string modelData
                    documentType: modelData
                }
            }
            Item {
                Layout.preferredWidth: 24
            }
            ConnectionIndicator {}
            ConnectionIndicator {
                connectionState: "connecting"
            }
            ConnectionIndicator {
                connectionState: "disconnected"
            }
        }
    }
    GallerySection {
        title: "13 / Dialogues"
        subtitle: "Focus piégé • Annuler reçoit le focus pour une suppression • Échap restaure le focus"
        Layout.fillWidth: true
        RowLayout {
            Repeater {
                model: ["confirmation", "destructive", "warning", "information", "error"]
                AzenzButton {
                    required property string modelData
                    text: modelData
                    variant: modelData === "destructive" ? "danger" : "secondary"
                    onClicked: {
                        dialog.dialogType = modelData;
                        dialog.title = modelData === "destructive" ? "Confirmer la suppression" : modelData === "error" ? "Erreur" : modelData === "warning" ? "Avertissement" : modelData === "information" ? "Information" : "Confirmer l'action";
                        dialog.open();
                    }
                }
            }
        }
    }
    GallerySection {
        title: "14 / Retours système"
        subtitle: "Bannières persistantes • Toasts sans vol de focus • Maximum de quatre notifications visibles"
        Layout.fillWidth: true
        GridLayout {
            columns: 2
            columnSpacing: 16
            rowSpacing: 12
            Layout.fillWidth: true
            InlineBanner {
                title: "Enregistrement réussi"
                message: "Le document a été enregistré."
                variant: "success"
                closeButton: false
                Layout.fillWidth: true
            }
            InlineBanner {
                title: "Information"
                message: "Une mise à jour est disponible."
                variant: "info"
                closeButton: false
                Layout.fillWidth: true
            }
            InlineBanner {
                title: "Vérification requise"
                message: "Certains champs nécessitent votre attention."
                variant: "warning"
                closeButton: false
                Layout.fillWidth: true
            }
            InlineBanner {
                title: "Opération interrompue"
                message: "Veuillez réessayer."
                variant: "error"
                actionText: "Réessayer"
                closeButton: false
                Layout.fillWidth: true
                onActionTriggered: root.notify("Réessayer", "Nouvelle tentative demandée")
            }
        }
        RowLayout {
            Toast {
                title: "Document enregistré"
                message: "Les modifications sont disponibles."
                persistent: true
                closeButton: false
                Layout.preferredWidth: 380
            }
            AzenzButton {
                text: "Afficher un toast"
                variant: "secondary"
                onClicked: root.notify("Document enregistré", "Cette notification disparaît après cinq secondes.")
            }
        }
    }
    GallerySection {
        title: "15 / Chargement & états vides"
        Layout.fillWidth: true
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            Skeleton {
                variant: "table"
                Layout.fillWidth: true
                Layout.preferredHeight: 170
            }
            Skeleton {
                variant: "form"
                rows: 2
                Layout.fillWidth: true
                Layout.preferredHeight: 170
            }
            Skeleton {
                variant: "textBlock"
                rows: 4
                Layout.fillWidth: true
                Layout.preferredHeight: 170
            }
        }
        RowLayout {
            Layout.fillWidth: true
            EmptyState {
                actionText: "Créer un document"
                Layout.fillWidth: true
                onActionTriggered: root.notify("Nouveau document", "Action demandée")
            }
            EmptyState {
                variant: "noResults"
                actionText: "Réinitialiser les filtres"
                Layout.fillWidth: true
                onActionTriggered: root.notify("Filtres", "Réinitialisation demandée")
            }
        }
    }
    AzenzDialog {
        id: dialog
        objectName: "exampleDialog"
        parent: root.Window.window ? root.Window.window.contentItem : root
        supportingMessage: "Vérifiez l'élément sélectionné avant de continuer."
        onAccepted: root.notify("Confirmation", "L'action a été confirmée.")
    }
}
