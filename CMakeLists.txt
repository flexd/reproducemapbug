cmake_minimum_required(VERSION 3.16)

project(reproducemapbug VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(reproducemapbug
    main.cpp
)

qt_add_qml_module(reproducemapbug
    URI ReproduceMapBug
    VERSION 1.0
    QML_FILES
        Main.qml
        MiniMapView.qml
        FullMapView.qml
        OsmMapView.qml
)

target_link_libraries(reproducemapbug PRIVATE
    Qt6::Quick
)
