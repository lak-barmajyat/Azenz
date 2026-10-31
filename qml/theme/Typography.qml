pragma Singleton
import QtQuick

QtObject {
    readonly property string latin: inter.status === FontLoader.Ready ? inter.name : "Segoe UI"
    readonly property string arabic: noto.status === FontLoader.Ready ? noto.name : "Segoe UI"
    readonly property int title: 20
    readonly property int section: 16
    readonly property int subtitle: 14
    readonly property int body: 13
    readonly property int caption: 12
    readonly property int micro: 11
    readonly property FontLoader inter: FontLoader {
        source: "../../resources/fonts/Inter.ttf"
    }
    readonly property FontLoader noto: FontLoader {
        source: "../../resources/fonts/NotoSansArabic.ttf"
    }
}
