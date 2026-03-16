#!/bin/bash
# Build against Qt 6.10
QT_DIR=${QT_DIR:-"$HOME/Qt/6.10.2/gcc_64"}

cmake -S "$(dirname "$0")" -B "$(dirname "$0")/build" -DCMAKE_PREFIX_PATH="$QT_DIR" && \
cmake --build "$(dirname "$0")/build"
