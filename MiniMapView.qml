import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning

Page {
    id: root
    signal openFullMap()

    header: ToolBar {
        Label {
            text: "Mini Map View"
            anchors.centerIn: parent
            font.bold: true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            text: "This is the main view with a small minimap.\nClick 'Open Full Map' to switch to the large map view."
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }

        // Small minimap
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            border.color: "gray"
            border.width: 1

            Map {
                id: miniMap
                anchors.fill: parent
                anchors.margins: 1
                center: QtPositioning.coordinate(59.9139, 10.7522) // Oslo
                zoomLevel: 10

                plugin: Plugin {
                    name: "maplibre"
                    PluginParameter {
                        name: "maplibre.map.styles"
                        value: styleUrl
                    }
                }
            }
        }

        Button {
            text: "Open Full Map"
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.openFullMap()
        }

        Item { Layout.fillHeight: true }
    }
}
