import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning

Page {
    id: root
    signal back()

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            Button {
                text: "Back"
                onClicked: root.back()
            }
            Label {
                text: "Full Map View"
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            Item { implicitWidth: 48 } // spacer to balance the back button
        }
    }

    Map {
        id: fullMap
        anchors.fill: parent
        center: QtPositioning.coordinate(59.9139, 10.7522) // Oslo
        zoomLevel: 12

        plugin: Plugin {
            name: "maplibre"
            PluginParameter {
                name: "maplibre.map.styles"
                value: styleUrl
            }
        }
    }
}
