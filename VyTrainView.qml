import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning

Page {
    id: root
    signal back()

    Component.onCompleted: trainFetcher.start()
    Component.onDestruction: trainFetcher.stop()

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            Button {
                text: "Back"
                onClicked: root.back()
            }
            Label {
                text: "Vy Live Trains (%1)".arg(trainFetcher.count)
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            Button {
                text: "↻"
                font.pixelSize: 18
                enabled: !trainFetcher.loading
                onClicked: trainFetcher.refresh()
            }
        }
    }

    Map {
        id: trainMap
        anchors.fill: parent
        center: QtPositioning.coordinate(59.9139, 10.7522) // Oslo
        zoomLevel: 7

        plugin: Plugin {
            name: "maplibre"
            PluginParameter {
                name: "maplibre.map.styles"
                value: styleUrl
            }
        }

        MapItemView {
            model: trainFetcher.trains

            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(modelData.latitude, modelData.longitude)
                anchorPoint.x: marker.width / 2
                anchorPoint.y: marker.height / 2

                sourceItem: Rectangle {
                    id: marker
                    width: {
                        if (trainMap.zoomLevel >= 10) return 16
                        if (trainMap.zoomLevel >= 8) return 12
                        return 8
                    }
                    height: width
                    radius: width / 2
                    color: {
                        if (modelData.delay > 300) return "#e74c3c"  // red: >5min delay
                        if (modelData.delay > 60) return "#f39c12"   // orange: >1min delay
                        return "#2ecc71"                              // green: on time
                    }
                    border.color: "white"
                    border.width: 1

                    ToolTip.visible: mouseArea.containsMouse
                    ToolTip.text: {
                        var text = modelData.publicCode ? modelData.publicCode : modelData.lineRef
                        if (modelData.lineName)
                            text += " — " + modelData.lineName
                        if (modelData.delay !== 0) {
                            var mins = Math.round(modelData.delay / 60)
                            text += "\nDelay: " + mins + " min"
                        }
                        if (modelData.speed > 0)
                            text += "\nSpeed: " + Math.round(modelData.speed) + " km/h"
                        return text
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }
    }

    // Legend overlay
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: legendCol.width + 16
        height: legendCol.height + 12
        radius: 6
        color: "#cc000000"

        Column {
            id: legendCol
            anchors.centerIn: parent
            spacing: 4

            Label {
                text: "Vy Live Trains"
                color: "white"
                font.bold: true
                font.pixelSize: 11
            }

            Row {
                spacing: 4
                Rectangle { width: 10; height: 10; radius: 5; color: "#2ecc71" }
                Label { text: "On time"; color: "white"; font.pixelSize: 10 }
            }
            Row {
                spacing: 4
                Rectangle { width: 10; height: 10; radius: 5; color: "#f39c12" }
                Label { text: "> 1 min late"; color: "white"; font.pixelSize: 10 }
            }
            Row {
                spacing: 4
                Rectangle { width: 10; height: 10; radius: 5; color: "#e74c3c" }
                Label { text: "> 5 min late"; color: "white"; font.pixelSize: 10 }
            }
        }
    }

    // Error banner
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: errorLabel.height + 16
        color: "#e74c3c"
        visible: trainFetcher.error !== ""

        Label {
            id: errorLabel
            anchors.centerIn: parent
            text: trainFetcher.error
            color: "white"
            wrapMode: Text.Wrap
        }
    }

    // Loading indicator
    BusyIndicator {
        anchors.centerIn: parent
        running: trainFetcher.loading && trainFetcher.count === 0
        visible: running
    }
}
