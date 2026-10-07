import * as L from 'leaflet';
import iconUrl from 'leaflet/dist/images/marker-icon.png';
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png';
import shadowUrl from 'leaflet/dist/images/marker-shadow.png';

import veloLogo from '../images/velo_prof.png';
import mainTpl from '../tpl/main.tpl.html';
import popupTpl from '../tpl/popupview.tpl.html';

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({ iconUrl, iconRetinaUrl, shadowUrl });

const mapMarqueurs = new Map();

function creerContenuPopup(code, nom, velos, docks) {
    return popupTpl
        .replace('{{code}}', code)
        .replace('{{nom}}', nom)
        .replace('{{velos}}', velos)
        .replace('{{docks}}', docks);
}

async function actualiserStatuts() {
    try {
        const reponse = await fetch('/api/opendata/Velib_Metropole/station_status.json');
        const donnees = await reponse.json();
        const statuts = donnees.data.stations;

        statuts.forEach(st => {
            const markerData = mapMarqueurs.get(st.station_id);
            if (markerData) {
                const totalVelos = st.num_bikes_available || 0;
                const docksLibres = st.num_docks_available || 0;

                const nouveauContenu = creerContenuPopup(
                    markerData.code,
                    markerData.nom,
                    totalVelos,
                    docksLibres
                );
                markerData.marker.setPopupContent(nouveauContenu);
            }
        });
    } catch (erreur) {
        console.error("Erreur actualisation :", erreur);
    }

    setTimeout(actualiserStatuts, 300000);
}

async function initCarte() {
    document.body.innerHTML = mainTpl;
    document.querySelector('#nav-logo').src = veloLogo;

    const map = L.map('map').setView([48.8566, 2.3522], 12);

    const fondCarte = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    const calqueStations = L.layerGroup().addTo(map);

    L.control.layers(
        { "OpenStreetMap": fondCarte },
        { "Stations Vélib": calqueStations }
    ).addTo(map);

    const reponse = await fetch('/api/opendata/Velib_Metropole/station_information.json');
    const donnees = await reponse.json();
    const stations = donnees.data.stations;

    stations.forEach(station => {
        const marker = L.marker([station.lat, station.lon]).addTo(calqueStations);
        marker.bindPopup(`<b>${station.stationCode} - ${station.name}</b><br>Chargement des disponibilités...`);

        mapMarqueurs.set(station.station_id, {
            marker: marker,
            code: station.stationCode,
            nom: station.name
        });
    });

    await actualiserStatuts();
}

initCarte();
