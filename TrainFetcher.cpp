#include "TrainFetcher.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>

static const char *ENTUR_VEHICLES_URL = "https://api.entur.io/realtime/v2/vehicles/graphql";

static const char *GRAPHQL_QUERY = R"({
  vehicles(codespaceId: "VYT", mode: RAIL) {
    line {
      lineRef
      lineName
      publicCode
    }
    lastUpdated
    location {
      latitude
      longitude
    }
    direction
    speed
    vehicleStatus
    delay
    monitored
  }
})";

TrainFetcher::TrainFetcher(QObject *parent)
    : QObject(parent)
{
    m_timer.setInterval(15000); // Entur updates every 15 seconds
    connect(&m_timer, &QTimer::timeout, this, &TrainFetcher::fetchTrains);
}

void TrainFetcher::start()
{
    fetchTrains();
    m_timer.start();
}

void TrainFetcher::stop()
{
    m_timer.stop();
}

void TrainFetcher::refresh()
{
    fetchTrains();
}

void TrainFetcher::fetchTrains()
{
    if (m_loading)
        return;

    m_loading = true;
    emit loadingChanged();

    QNetworkRequest request(QUrl(ENTUR_VEHICLES_URL));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("ET-Client-Name", "reproducemapbug-vytrains");

    QJsonObject body;
    body["query"] = QString(GRAPHQL_QUERY);
    QByteArray payload = QJsonDocument(body).toJson(QJsonDocument::Compact);

    QNetworkReply *reply = m_nam.post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        m_loading = false;
        emit loadingChanged();

        if (reply->error() != QNetworkReply::NoError) {
            m_error = reply->errorString();
            emit errorChanged();
            return;
        }

        const QByteArray data = reply->readAll();
        const QJsonDocument doc = QJsonDocument::fromJson(data);
        const QJsonObject root = doc.object();
        const QJsonArray vehicles = root["data"].toObject()["vehicles"].toArray();

        QVariantList trains;
        for (const QJsonValue &v : vehicles) {
            const QJsonObject obj = v.toObject();
            const QJsonObject loc = obj["location"].toObject();
            const QJsonObject line = obj["line"].toObject();

            if (loc.isEmpty())
                continue;

            QVariantMap train;
            train["latitude"] = loc["latitude"].toDouble();
            train["longitude"] = loc["longitude"].toDouble();
            train["lineName"] = line["lineName"].toString();
            train["publicCode"] = line["publicCode"].toString();
            train["lineRef"] = line["lineRef"].toString();
            train["speed"] = obj["speed"].toDouble();
            train["delay"] = obj["delay"].toInt();
            train["direction"] = obj["direction"].toString();
            train["vehicleStatus"] = obj["vehicleStatus"].toString();
            train["lastUpdated"] = obj["lastUpdated"].toString();
            trains.append(train);
        }

        m_trains = trains;
        emit trainsChanged();

        if (!m_error.isEmpty()) {
            m_error.clear();
            emit errorChanged();
        }
    });
}
