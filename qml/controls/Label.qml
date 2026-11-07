import QtQuick
import "../theme"

Text {
    property bool arabic: false
    property bool tabular: false
    color: Colors.text
    font.family: arabic ? Typography.arabic : Typography.latin
    font.pixelSize: Typography.body
    font.features: tabular ? {
        "tnum": 1
    } : ({})
    textFormat: Text.PlainText
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}
