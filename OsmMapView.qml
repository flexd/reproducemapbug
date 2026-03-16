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
                text: "OSM Plugin (Qt built-in raster)"
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            Item { implicitWidth: 48 }
        }
    }

    Map {
        id: osmMap
        anchors.fill: parent
        center: QtPositioning.coordinate(59.9139, 10.7522) // Oslo
        zoomLevel: 12

        plugin: Plugin {
            name: "osm"
        }
    }
}
