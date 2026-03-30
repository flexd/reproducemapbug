const ENTUR_VEHICLES_URL = 'https://api.entur.io/realtime/v2/vehicles/graphql';

const GRAPHQL_QUERY = `{
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
}`;

const REFRESH_INTERVAL = 15000; // Entur updates every 15 seconds

let map;
let popup;
let trainData = [];

function getDelayColor(delay) {
    if (delay > 300) return '#e74c3c';  // red: >5 min
    if (delay > 60) return '#f39c12';   // orange: >1 min
    return '#2ecc71';                    // green: on time
}

function formatDelay(seconds) {
    if (!seconds || seconds <= 0) return null;
    const mins = Math.round(seconds / 60);
    if (mins < 1) return `${seconds}s`;
    return `${mins} min`;
}

function buildPopupHTML(train) {
    const code = train.publicCode || train.lineRef || 'Unknown';
    const name = train.lineName || '';
    const delayStr = formatDelay(train.delay);
    const speed = train.speed > 0 ? `${Math.round(train.speed)} km/h` : 'Stopped';
    const status = train.vehicleStatus || '';

    let delayHTML;
    if (delayStr) {
        delayHTML = `<div class="popup-delay-late">Delayed: +${delayStr}</div>`;
    } else {
        delayHTML = `<div class="popup-delay-ok">On time</div>`;
    }

    return `
        <div class="popup-title">${code}${name ? ' — ' + name : ''}</div>
        ${delayHTML}
        <div class="popup-detail">Speed: ${speed}</div>
        ${status ? `<div class="popup-detail">Status: ${status}</div>` : ''}
    `;
}

async function fetchTrains() {
    try {
        const res = await fetch(ENTUR_VEHICLES_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'ET-Client-Name': 'flexd-vy-live-trains',
            },
            body: JSON.stringify({ query: GRAPHQL_QUERY }),
        });

        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const json = await res.json();
        const vehicles = json.data?.vehicles || [];

        trainData = vehicles
            .filter(v => v.location?.latitude && v.location?.longitude)
            .map(v => ({
                latitude: v.location.latitude,
                longitude: v.location.longitude,
                lineName: v.line?.lineName || '',
                publicCode: v.line?.publicCode || '',
                lineRef: v.line?.lineRef || '',
                speed: v.speed || 0,
                delay: v.delay || 0,
                direction: v.direction || '',
                vehicleStatus: v.vehicleStatus || '',
                lastUpdated: v.lastUpdated || '',
            }));

        updateMap();
        updateStatus();
    } catch (err) {
        document.getElementById('status').textContent = `Error: ${err.message}`;
        console.error('Failed to fetch train data:', err);
    }
}

function trainsToGeoJSON() {
    return {
        type: 'FeatureCollection',
        features: trainData.map(t => ({
            type: 'Feature',
            geometry: {
                type: 'Point',
                coordinates: [t.longitude, t.latitude],
            },
            properties: {
                ...t,
                color: getDelayColor(t.delay),
            },
        })),
    };
}

function updateMap() {
    const source = map.getSource('trains');
    if (source) {
        source.setData(trainsToGeoJSON());
    }
}

function updateStatus() {
    const now = new Date().toLocaleTimeString();
    document.getElementById('status').textContent =
        `${trainData.length} trains · Updated ${now}`;
}

function initMap() {
    map = new maplibregl.Map({
        container: 'map',
        style: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
        center: [10.7522, 59.9139], // Oslo
        zoom: 6.5,
    });

    popup = new maplibregl.Popup({
        closeButton: false,
        closeOnClick: false,
    });

    map.on('load', () => {
        map.addSource('trains', {
            type: 'geojson',
            data: trainsToGeoJSON(),
        });

        map.addLayer({
            id: 'trains-circle',
            type: 'circle',
            source: 'trains',
            paint: {
                'circle-radius': [
                    'interpolate', ['linear'], ['zoom'],
                    5, 4,
                    8, 7,
                    12, 12,
                ],
                'circle-color': ['get', 'color'],
                'circle-stroke-color': '#ffffff',
                'circle-stroke-width': 1.5,
                'circle-opacity': 0.9,
            },
        });

        // Show labels at higher zoom levels
        map.addLayer({
            id: 'trains-label',
            type: 'symbol',
            source: 'trains',
            minzoom: 9,
            layout: {
                'text-field': ['get', 'publicCode'],
                'text-size': 11,
                'text-offset': [0, -1.5],
                'text-font': ['Open Sans Bold', 'Arial Unicode MS Bold'],
            },
            paint: {
                'text-color': '#333',
                'text-halo-color': '#fff',
                'text-halo-width': 1.5,
            },
        });

        // Hover popup
        map.on('mouseenter', 'trains-circle', (e) => {
            map.getCanvas().style.cursor = 'pointer';
            const props = e.features[0].properties;
            popup
                .setLngLat(e.lngLat)
                .setHTML(buildPopupHTML(props))
                .addTo(map);
        });

        map.on('mouseleave', 'trains-circle', () => {
            map.getCanvas().style.cursor = '';
            popup.remove();
        });

        map.on('mousemove', 'trains-circle', (e) => {
            const props = e.features[0].properties;
            popup
                .setLngLat(e.lngLat)
                .setHTML(buildPopupHTML(props));
        });

        // Initial fetch + auto-refresh
        fetchTrains();
        setInterval(fetchTrains, REFRESH_INTERVAL);
    });
}

initMap();
