#!/bin/bash
# Run with Qt's built-in OSM raster plugin (no MapLibre) to verify Qt raster rendering works
QT_DIR=${QT_DIR:-"$HOME/Qt/6.10.2/gcc_64"}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export LD_LIBRARY_PATH=$QT_DIR/lib
export QT_PLUGIN_PATH=$QT_DIR/plugins
export QSG_INFO=1

cd "$SCRIPT_DIR"
exec ./build/reproducemapbug "$@" 2>&1
