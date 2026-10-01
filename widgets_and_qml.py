import os
import sys
from PySide6.QtCore import QUrl
from PySide6.QtWidgets import QApplication, QWidget, QHBoxLayout, QVBoxLayout, QPushButton, QLabel
from PySide6.QtQuickWidgets import QQuickWidget
from PySide6.QtQml import QQmlComponent  # Added import

# Define a simple QML string to avoid external file dependencies
QML_DATA = b"""
import QtQuick

Rectangle {
    width: 300
    height: 300
    color: "#34495e"
    radius: 10

    Text {
        anchors.centerIn: parent
        text: "Hi! I am live QML\\n(GPU Accelerated)"
        color: "#ecf0f1"
        font.pixelSize: 18
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }
}
"""

def main():
    app = QApplication(sys.argv)

    # 1. Create the single main window
    main_window = QWidget()
    main_window.setWindowTitle("Widgets & QML Combined Window")
    main_window.resize(600, 350)

    # 2. Main horizontal layout to hold both sides side-by-side
    main_layout = QHBoxLayout(main_window)
    main_layout.setContentsMargins(15, 15, 15, 15)
    main_layout.setSpacing(15)

    # 3. Left Side: Traditional Qt Widgets
    widget_panel = QWidget()
    widget_layout = QVBoxLayout(widget_panel)
    widget_layout.setContentsMargins(0, 0, 0, 0)
    
    label = QLabel("I am a native Qt Widget Label")
    label.setStyleSheet("font-size: 14px; font-weight: bold;")
    
    button = QPushButton("Native Click Me Button")
    button.setMinimumHeight(40)
    
    widget_layout.addWidget(label)
    widget_layout.addWidget(button)
    widget_layout.addStretch()

    # 4. Right Side: Embedded QML Surface
    qml_container = QQuickWidget()
    
    # --- FIXED SECTION ---
    # Retrieve the inner engine from the container to compile our bytes
    engine = qml_container.engine()
    
    component = QQmlComponent(engine)
    component.setData(QML_DATA, QUrl())
    
    # Create the top-level QML visual object instance
    root_object = component.create()
    
    # Supply all three required arguments to setContent
    qml_container.setContent(QUrl(), component, root_object)
    # ---------------------
    
    qml_container.setResizeMode(QQuickWidget.ResizeMode.SizeRootObjectToView)

    # 5. Add both sides into the unified window layout
    main_layout.addWidget(widget_panel, stretch=1)
    main_layout.addWidget(qml_container, stretch=1)

    main_window.show()
    sys.argv = [sys.argv[0]] # Clean arguments for safety
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
