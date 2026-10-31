pragma Singleton
import QtQuick

QtObject {
    readonly property color navy: "#113657"
    readonly property color accent: "#F17D24"
    readonly property color accentHover: "#DE6E1B"
    readonly property color accentPressed: "#C75E12"
    readonly property color canvas: "#F8FAFC"
    readonly property color surface: "#FFFFFF"
    readonly property color subtle: "#F1F5F9"
    readonly property color border: "#E5E7EB"
    readonly property color borderStrong: "#CBD5E1"
    readonly property color text: "#1F2937"
    readonly property color textSecondary: "#6B7280"
    readonly property color rowHover: "#F1F5F9"
    readonly property color rowSelected: "#EBF3FA"
    readonly property color disabled: "#F3F4F6"
    readonly property color disabledText: "#9CA3AF"
    readonly property color navHover: "#1E4976"
    readonly property color success: "#10B981"
    readonly property color warning: "#F59E0B"
    readonly property color danger: "#EF4444"
    readonly property color info: "#3B82F6"
    readonly property color header: "#E2E8F8"
    readonly property color scrim: "#4D113657"

    function semantic(variant) {
        switch (variant.toLowerCase()) {
        case "success":
            return success;
        case "warning":
            return warning;
        case "danger":
        case "error":
            return danger;
        case "info":
        case "information":
            return info;
        default:
            return textSecondary;
        }
    }
    function tint(variant) {
        switch (variant.toLowerCase()) {
        case "success":
            return "#ECFDF5";
        case "warning":
            return "#FFFBEB";
        case "danger":
        case "error":
            return "#FEF2F2";
        case "info":
        case "information":
            return "#EFF6FF";
        default:
            return subtle;
        }
    }
    function ink(variant) {
        switch (variant.toLowerCase()) {
        case "success":
            return "#047857";
        case "warning":
            return "#92400E";
        case "danger":
        case "error":
            return "#B91C1C";
        case "info":
        case "information":
            return "#1D4ED8";
        default:
            return textSecondary;
        }
    }
}
