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
            onOpenOsmMap: stackView.push(osmMapPage)
            onOpenVyTrains: stackView.push(vyTrainPage)
        }
    }

    Component {
        id: fullMapPage
        FullMapView {
            onBack: stackView.pop()
        }
    }

    Component {
        id: osmMapPage
        OsmMapView {
            onBack: stackView.pop()
        }
    }

    Component {
        id: vyTrainPage
        VyTrainView {
            onBack: stackView.pop()
        }
    }
}
