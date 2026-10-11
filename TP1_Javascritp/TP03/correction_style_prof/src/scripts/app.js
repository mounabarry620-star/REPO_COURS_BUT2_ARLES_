import * as L from 'leaflet'
import 'leaflet.markercluster'
import iconUrl from 'leaflet/dist/images/marker-icon.png'
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png'
import shadowUrl from 'leaflet/dist/images/marker-shadow.png'
// Version navigateur de Handlebars : l'import de 'handlebars' seul vise Node.js
// et provoque l'avertissement « require.extensions is not supported by webpack »
import Handlebars from 'handlebars/dist/handlebars.js'

import { VELIB } from './velib.js'
import logo from '../images/velo_prof.png'
import mainTpl from './tpl/main.tpl.html'
import popupTpl from './tpl/popupview.tpl.html'

// Correction des icônes de marqueurs de Leaflet avec webpack (cf. issue 4968)
delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({ iconUrl, iconRetinaUrl, shadowUrl })

const CENTRE_PARIS = [48.8566, 2.3522]
const DELAI_MISE_A_JOUR = 5 * 60 * 1000 // 5 minutes : inutile de surcharger le serveur

const mainView = Handlebars.compile(mainTpl)
const popupView = Handlebars.compile(popupTpl)

// station_id → { station, marqueur }
// Les deux flux partagent station_id : la Map permet de retrouver directement
// le marqueur d'une station quand son statut arrive, sans reparcourir la liste.
const marqueurs = new Map()

const creerCarte = () => {
  document.body.innerHTML = mainView({ logo })

  const carte = L.map('map').setView(CENTRE_PARIS, 13)
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(carte)

  return carte
}

const afficherMessage = (message) => {
  document.querySelector('#derniere-maj').textContent = message
}

// Le statut est optionnel : tant qu'il n'est pas arrivé, la popup l'indique
const contenuPopup = (station, statut = null) => {
  if (statut === null) {
    return popupView({ station })
  }
  // num_bikes_available_types vaut [{ mechanical: 3 }, { ebike: 1 }]
  let mecaniques = 0
  let electriques = 0
  for (const type of statut.num_bikes_available_types) {
    if (type.mechanical !== undefined) {
      mecaniques = type.mechanical
    }
    if (type.ebike !== undefined) {
      electriques = type.ebike
    }
  }
  return popupView({
    station,
    statut: {
      velos: statut.num_bikes_available,
      mecaniques,
      electriques,
      bornes: statut.num_docks_available
    }
  })
}

const ajouterStations = (groupe, stations) => {
  for (const station of stations) {
    const marqueur = L.marker([station.lat, station.lon])
    marqueur.bindPopup(contenuPopup(station))
    groupe.addLayer(marqueur)
    marqueurs.set(station.station_id, { station, marqueur })
  }
}

const appliquerStatut = (statut) => {
  const entree = marqueurs.get(statut.station_id)
  if (entree !== undefined) {
    entree.marqueur.setPopupContent(contenuPopup(entree.station, statut))
  }
}

// Met à jour les disponibilités, puis se reprogramme dans 5 minutes.
// setTimeout plutôt que setInterval : la requête suivante n'est programmée
// qu'une fois la précédente terminée, même si le serveur est lent.
const mettreAJour = async () => {
  try {
    const statuts = await VELIB.getStatuts()
    statuts.forEach(appliquerStatut)
    afficherMessage('Disponibilités à jour (actualisation toutes les 5 min)')
  } catch (erreur) {
    console.log(`Une erreur s'est produite : ${erreur.message}`)
    afficherMessage('Mise à jour impossible, nouvel essai dans 5 min')
  }
  setTimeout(mettreAJour, DELAI_MISE_A_JOUR)
}

const init = async () => {
  const carte = creerCarte()
  // Regroupe les ~1500 marqueurs proches pour garder une carte lisible et fluide
  const groupe = L.markerClusterGroup()
  carte.addLayer(groupe)

  try {
    ajouterStations(groupe, await VELIB.getStations())
  } catch (erreur) {
    console.log(`Une erreur s'est produite : ${erreur.message}`)
    afficherMessage('Impossible de charger les stations')
    return
  }

  mettreAJour()
}

init()
