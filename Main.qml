import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 800
    height: 600
    visible: true
    title: "MapLibre Raster Bug Reproducer"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: miniMapPage
    }

    Component {
        id: miniMapPage
        MiniMapView {
            onOpenFullMap: stackView.push(fullMapPage)
        }
    }

    Component {
        id: fullMapPage
        FullMapView {
            onBack: stackView.pop()
        }
    }
}
