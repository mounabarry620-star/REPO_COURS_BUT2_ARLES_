import * as L from 'leaflet'
import 'leaflet.markercluster'
import iconUrl from 'leaflet/dist/images/marker-icon.png'
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png'
import shadowUrl from 'leaflet/dist/images/marker-shadow.png'
import Handlebars from 'handlebars/dist/handlebars.js'
import modelePopup from '../tpl/popup.tpl.html'

// Correction des icônes de marqueurs de Leaflet avec webpack (TP03, issue 4968)
delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({ iconUrl, iconRetinaUrl, shadowUrl })

const CENTRE_FRANCE = [46.6, 2.4]
const ZOOM_FRANCE = 5

// Bleu France, la couleur principale de Parcoursup (la même que $bleu-france dans styles.scss)
const BLEU_FRANCE = '#000091'

export class VueCarte {
  #conteneur
  #carte
  #calque
  #cercle = null
  #template

  constructor (conteneur) {
    this.#conteneur = conteneur
    this.#carte = L.map(conteneur).setView(CENTRE_FRANCE, ZOOM_FRANCE)
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.#carte)
    this.#calque = L.markerClusterGroup().addTo(this.#carte)
    this.#template = Handlebars.compile(modelePopup)
  }

  afficherFormations (ville, formations, rayonKm) {
    if (this.#conteneur.hidden) {
      this.#conteneur.hidden = false
      // Leaflet doit recalculer la taille de la carte quand elle réapparaît
      this.#carte.invalidateSize()
    }
    this.effacer()
    this.#cercle = L.circle([ville.lat, ville.lon], {
      radius: rayonKm * 1000,
      color: BLEU_FRANCE,
      weight: 2,
      fillOpacity: 0.08
    }).addTo(this.#carte)

    for (const formation of formations) {
      const contenu = this.#template({
        intitule: formation.intitule,
        etablissement: formation.etablissement,
        commune: formation.commune,
        lien: formation.lien,
        tauxAcces: formation.tauxAcces === null ? 'non communiqué' : `${formation.tauxAcces} %`
      })
      L.marker([formation.lat, formation.lon]).bindPopup(contenu).addTo(this.#calque)
    }
    this.#carte.fitBounds(this.#cercle.getBounds())
  }

  // Mon Master ne publie pas de coordonnées : la carte est cachée
  masquer () {
    this.effacer()
    this.#conteneur.hidden = true
  }

  effacer () {
    this.#calque.clearLayers()
    if (this.#cercle !== null) {
      this.#cercle.remove()
      this.#cercle = null
    }
  }
}
