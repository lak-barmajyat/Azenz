import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../theme"

C.Button {
    id: root
    property string variant: "primary" // primary, secondary, ghost, danger, toolbar, icon
    property real cornerRadius: Theme.radiusSM
    property string density: Theme.densityFor(parent)
    property string size: density === "comfortable" ? "comfortable" : "standard"
    property string iconName: ""
    property bool loading: false
    property string tooltip: ""
    readonly property bool solid: variant === "primary"
    implicitHeight: size === "compact" ? 28 : size === "comfortable" ? 38 : 32
    implicitWidth: variant === "icon" ? implicitHeight : Math.max(64, implicitContentWidth + leftPadding + rightPadding)
    leftPadding: variant === "icon" ? 6 : size === "compact" ? 10 : 14
    rightPadding: leftPadding
    spacing: 6
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    enabled: !loading
    font.family: Typography.latin
    font.pixelSize: size === "compact" ? 11 : size === "comfortable" ? 13 : 12
    font.weight: Font.DemiBold
    Accessible.name: text || tooltip
    Keys.onReturnPressed: if (enabled)
        clicked()
    Keys.onEnterPressed: if (enabled)
        clicked()
    background: Rectangle {
        radius: root.cornerRadius
        color: !root.enabled ? Colors.disabled : root.solid ? (root.down ? Colors.accentPressed : root.hovered ? Colors.accentHover : Colors.accent) : root.down ? Colors.rowSelected : root.hovered ? (root.variant === "danger" ? Colors.tint("danger") : Colors.subtle) : root.variant === "ghost" || root.variant === "icon" || root.variant === "toolbar" ? "transparent" : Colors.surface
        border.color: !root.enabled ? Colors.border : root.variant === "secondary" ? Colors.navy : root.variant === "danger" ? "#FECACA" : "transparent"
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            color: "transparent"
            radius: 6
            border.width: 2
            border.color: Colors.accent
            visible: root.visualFocus
        }
    }
    contentItem: RowLayout {
        spacing: root.spacing
        Icon {
            visible: root.iconName !== "" && !root.loading
            name: root.iconName || "info"
            color: !root.enabled ? Colors.disabledText : root.solid ? "white" : root.variant === "danger" ? Colors.danger : Colors.navy
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
        }
        C.BusyIndicator {
            visible: root.loading
            running: visible
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }
        Label {
            visible: root.text !== "" && root.variant !== "icon"
            text: root.text
            font: root.font
            color: !root.enabled ? Colors.disabledText : root.solid ? "white" : root.variant === "danger" ? Colors.danger : Colors.navy
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
    AzenzToolTip {
        text: root.tooltip
        visible: root.tooltip !== "" && (root.hovered || root.visualFocus) && !root.down
    }
}
