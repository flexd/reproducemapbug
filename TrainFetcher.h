#pragma once

#include <QObject>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QVariantList>

class TrainFetcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList trains READ trains NOTIFY trainsChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    Q_PROPERTY(int count READ count NOTIFY trainsChanged)

public:
    explicit TrainFetcher(QObject *parent = nullptr);

    QVariantList trains() const { return m_trains; }
    bool loading() const { return m_loading; }
    QString error() const { return m_error; }
    int count() const { return m_trains.size(); }

public slots:
    void refresh();
    void start();
    void stop();

signals:
    void trainsChanged();
    void loadingChanged();
    void errorChanged();

private:
    void fetchTrains();

    QNetworkAccessManager m_nam;
    QTimer m_timer;
    QVariantList m_trains;
    bool m_loading = false;
    QString m_error;
};
