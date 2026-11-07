pragma Singleton
import QtQuick

QtObject {
    property string density: "compact"
    property bool rightToLeft: false
    property bool reducedMotion: false
    readonly property int spaceXS: 4
    readonly property int spaceSM: 8
    readonly property int spaceMD: 12
    readonly property int spaceLG: 16
    readonly property int spaceXL: 24
    readonly property int radiusSM: 4
    readonly property int radiusMD: 6
    readonly property int radiusLG: 8
    readonly property int sidebarExpanded: 224
    readonly property int sidebarCollapsed: 56
    readonly property int tooltipDelay: 400
    function densityFor(item) {
        for (var ancestor = item; ancestor; ancestor = ancestor.parent) {
            if (ancestor.density !== undefined)
                return ancestor.density;
        }
        return density;
    }
    function controlHeight(mode) {
        return mode === "comfortable" ? 38 : 32;
    }
    function rowHeight(mode) {
        return mode === "comfortable" ? 32 : 28;
    }
    function headerHeight(mode) {
        return mode === "comfortable" ? 36 : 32;
    }
}
