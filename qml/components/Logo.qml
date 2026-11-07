import QtQuick

Item {
    id: root
    property string variant: "light" // light, dark, symbol, monochrome
    property url lightSource: "../../resources/images/azenz-light.png"
    property url darkSource: "../../resources/images/azenz-dark.png"
    property url symbolSource: "../../resources/images/azenz-symbol.png"
    property url monochromeSource: "../../resources/images/azenz-monochrome.png"
    implicitWidth: variant === "symbol" ? 32 : 120
    implicitHeight: 32
    Image {
        anchors.fill: parent
        source: root.variant === "dark" ? root.darkSource : root.variant === "symbol" ? root.symbolSource : root.variant === "monochrome" ? root.monochromeSource : root.lightSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
    }
}
