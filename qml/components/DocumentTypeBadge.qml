import QtQuick

Badge {
    property string documentType: "DV"
    text: documentType
    variant: documentType === "FA" ? "success" : documentType === "BC" ? "info" : documentType === "BR" || documentType === "FR" ? "warning" : "neutral"
    radius: 4
}
