import QtQuick
import QtQuick.Controls.Basic
import "../qml/controls"
import "../qml/components"
import "../qml/layouts"
import "../qml/theme"

Item {
    id: root
    width: 1200; height: 800
    property int acceptedCount: 0
    property int rejectedCount: 0
    property int buttonClicks: 0
    property int targetId: -1
    property string lastEdit: ""
    AzenzButton { id: trigger; objectName: "trigger"; x: 20; y: 20; text: "Open dialog"; onClicked: { root.buttonClicks++; dialog.open(); } }
    AzenzDialog { id: dialog; objectName: "dialog"; dialogType: "destructive"; onAccepted: root.acceptedCount++; onRejected: root.rejectedCount++ }
    DateInput { id: dateField; objectName: "dateField"; x: 20; y: 70; width: 240 }
    AzenzComboBox { id: combo; objectName: "combo"; x: 280; y: 70; searchable: true; model: [{text:"Atlas",value:1},{text:"Bloqué",value:2,enabled:false},{text:"Comptoir",value:3}] }
    NumberInput { id: numberField; x: 540; y: 70; minimum: 0; maximum: 20; value: 5; stepSize: 2 }
    DensityScope { id: scope; x: 20; y: 120; density: "comfortable"; width: 240; height: 50; AzenzTextField { id: inherited; width: 200 } }
    DataGrid {
        id: grid; objectName: "grid"; x: 20; y: 200; width: 1100; height: 230
        columns: [{key:"code",title:"Code",width:300,type:"code"},{key:"amount",title:"Amount",type:"currency",width:300},{key:"date",title:"Date",type:"date",width:300}]
        rows: [{id:1,code:"B",amount:10,date:"01/01/2026"},{id:2,code:"A",amount:2,date:"31/12/2025"},{id:3,code:"C",amount:30,date:"01/02/2026",enabled:false}]
        onContextMenuRequested: function(record,x,y) { root.targetId = record.id; context.targetRecord = record; context.popup(grid,x,y); }
        onCellEdited: function(record,key,value) { root.lastEdit = key + ":" + value; }
    }
    ContextMenu { id: context; ContextMenuItem { text: "Open" } }
    ToastHost { id: toasts; x: 800; y: 480 }
    DatePicker { id: calendar; x: 400; y: 440 }
    Sidebar { id: sidebar; visible: false }
}
