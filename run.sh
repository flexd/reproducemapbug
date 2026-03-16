#!/bin/bash
# Run with MapLibre plugin against Qt 6.10
# Adjust these paths to match your environment:
MAPLIBRE_PKG=${MAPLIBRE_PKG:-""}      # Path to MapLibre Native Qt install prefix
QT_DIR=${QT_DIR:-"$HOME/Qt/6.10.2/gcc_64"}

if [ -z "$MAPLIBRE_PKG" ]; then
    echo "Error: set MAPLIBRE_PKG to your MapLibre Native Qt install prefix"
    echo "  e.g.: MAPLIBRE_PKG=/path/to/maplibre-native-qt/install ./run.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export LD_LIBRARY_PATH=$QT_DIR/lib:$MAPLIBRE_PKG/lib
export QT_PLUGIN_PATH=$QT_DIR/plugins:$MAPLIBRE_PKG/plugins
export QML_IMPORT_PATH=$MAPLIBRE_PKG/qml
export STYLE_URL="file://$SCRIPT_DIR/style-raster.json"
export QSG_INFO=1

cd "$SCRIPT_DIR"
exec ./build/reproducemapbug "$@" 2>&1
