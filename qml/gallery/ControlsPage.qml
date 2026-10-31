import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../controls"
import "../components"
import "../theme"

ColumnLayout {
    id: root
    spacing: 16
    GallerySection {
        title: "05 / Boutons"
        subtitle: "Six familles • Trois tailles • Survol, pression, focus, désactivation et chargement"
        Layout.fillWidth: true
        RowLayout {
            spacing: 12
            AzenzButton {
                text: "Créer devis"
                iconName: "add"
            }
            AzenzButton {
                text: "Imprimer"
                iconName: "print"
                variant: "secondary"
            }
            AzenzButton {
                text: "Annuler"
                iconName: "close"
                variant: "ghost"
            }
            AzenzButton {
                text: "Supprimer"
                iconName: "delete"
                variant: "danger"
            }
            AzenzButton {
                text: "Modifier"
                iconName: "edit"
                variant: "toolbar"
            }
            IconButton {
                iconName: "refresh"
                tooltip: "Actualiser"
            }
        }
        RowLayout {
            spacing: 12
            AzenzButton {
                text: "Compact · 28px"
                size: "compact"
            }
            AzenzButton {
                text: "Standard · 32px"
                size: "standard"
            }
            AzenzButton {
                text: "Confortable · 38px"
                size: "comfortable"
            }
            AzenzButton {
                text: "Indisponible"
                enabled: false
            }
            AzenzButton {
                text: "Traitement…"
                loading: true
            }
        }
    }
    GallerySection {
        title: "06 / Champs de saisie"
        subtitle: "Six familles d'inputs • Lecture seule indépendante • Validation et focus clavier"
        Layout.fillWidth: true
        GridLayout {
            columns: 3
            columnSpacing: 20
            rowSpacing: 16
            Layout.fillWidth: true
            InputField {
                label: "Raison sociale"
                required: true
                placeholderText: "Saisir un client"
                helperText: "Nom ou raison sociale complète"
                Layout.fillWidth: true
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Label {
                    text: "Quantité facturée"
                    font.pixelSize: 12
                }
                NumberInput {
                    objectName: "quantity"
                    value: 12
                    minimum: 0
                    Layout.fillWidth: true
                }
                Label {
                    text: "Flèches ↑ ↓ pour ajuster"
                    color: Colors.textSecondary
                    font.pixelSize: 11
                }
            }
            InputField {
                label: "Montant total HT"
                inputType: "currency"
                text: "14 250,00"
                helperText: "Devise : dirham marocain"
                Layout.fillWidth: true
            }
            InputField {
                label: "Recherche globale"
                inputType: "search"
                placeholderText: "Client, article, document…"
                field.shortcutEnabled: true
                helperText: "Ctrl+K pour rechercher"
                Layout.fillWidth: true
            }
            InputField {
                label: "Mot de passe"
                inputType: "password"
                text: "demonstration"
                validationState: "valid"
                helperText: "Afficher ou masquer la saisie"
                Layout.fillWidth: true
            }
            InputField {
                label: "Numéro de pièce"
                inputType: "documentCode"
                text: "DV-2025-0042"
                prefix: "DEVIS"
                helperText: "Code de document modifiable"
                Layout.fillWidth: true
            }
            InputField {
                label: "Lecture seule"
                text: "FA-2025-0105"
                readOnly: true
                helperText: "Valeur sélectionnable et copiable"
                Layout.fillWidth: true
            }
            InputField {
                label: "Champ désactivé"
                text: "Compte bloqué"
                enabled: false
                helperText: "Non disponible"
                Layout.fillWidth: true
            }
            InputField {
                label: "Code client"
                text: "CLI-?"
                validationState: "error"
                errorMessage: "Format attendu : CLI-XXXXX"
                Layout.fillWidth: true
            }
        }
    }
    GallerySection {
        title: "07 / Sélection & calendrier"
        subtitle: "Sélection simple ou multiple, liste filtrable, saisie et navigation des dates"
        Layout.fillWidth: true
        RowLayout {
            spacing: 24
            AzenzCheckBox {
                text: "Option"
            }
            AzenzCheckBox {
                text: "Coché"
                checked: true
            }
            AzenzCheckBox {
                text: "Partiel"
                tristate: true
                checkState: Qt.PartiallyChecked
            }
            AzenzCheckBox {
                text: "Verrouillé"
                checked: true
                enabled: false
            }
            AzenzSwitch {
                text: "Notifications"
                checked: true
            }
        }
        RowLayout {
            spacing: 24
            C.ButtonGroup {
                id: payments
            }
            AzenzRadioButton {
                text: "Chèque bancaire"
                C.ButtonGroup.group: payments
            }
            AzenzRadioButton {
                text: "Virement"
                checked: true
                C.ButtonGroup.group: payments
            }
            AzenzRadioButton {
                text: "Espèces"
                C.ButtonGroup.group: payments
            }
            AzenzRadioButton {
                text: "Bloqué"
                enabled: false
                C.ButtonGroup.group: payments
            }
        }
        RowLayout {
            spacing: 20
            Layout.fillWidth: true
            AzenzComboBox {
                objectName: "clientCombo"
                searchable: true
                model: [
                    {
                        text: "SARL ATLAS DISTRIBUTION",
                        value: "CLI-00109"
                    },
                    {
                        text: "ATLAS LOGISTICS TRANSIT",
                        value: "CLI-00142"
                    },
                    {
                        text: "ATLAS MINING INDUSTRIE (bloqué)",
                        value: "CLI-00055",
                        enabled: false
                    }
                ]
                Layout.fillWidth: true
            }
            AzenzComboBox {
                model: ["MAD · Dirham", "EUR · Euro", "USD · Dollar"]
                currentIndex: 0
                Layout.fillWidth: true
            }
            DateInput {
                objectName: "documentDate"
                hasValue: true
                value: new Date(2026, 9, 8)
                Layout.fillWidth: true
            }
        }
    }
}
