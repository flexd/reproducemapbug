#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QGuiApplication app(argc, argv);

    const QString styleUrl = qEnvironmentVariable("STYLE_URL",
        QStringLiteral("https://demotiles.maplibre.org/style.json"));

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("styleUrl", styleUrl);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule("ReproduceMapBug", "Main");

    return app.exec();
}
