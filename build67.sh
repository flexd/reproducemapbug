#!/bin/bash
# Build against Qt 6.7
QT_DIR=${QT_DIR:-"$HOME/Qt/6.7.3/gcc_64"}

cmake -S "$(dirname "$0")" -B "$(dirname "$0")/build67" -DCMAKE_PREFIX_PATH="$QT_DIR" && \
cmake --build "$(dirname "$0")/build67"
