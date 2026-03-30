#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#include "TrainFetcher.h"

int main(int argc, char *argv[])
{
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QGuiApplication app(argc, argv);

    const QString styleUrl = qEnvironmentVariable("STYLE_URL",
        QStringLiteral("https://demotiles.maplibre.org/style.json"));

    TrainFetcher trainFetcher;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("styleUrl", styleUrl);
    engine.rootContext()->setContextProperty("trainFetcher", &trainFetcher);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule("ReproduceMapBug", "Main");

    return app.exec();
}
