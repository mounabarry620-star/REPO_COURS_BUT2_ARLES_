import { contientTousLesMots } from '../outils.js'

export class Formation {
  #code
  #etablissement
  #intitule
  #commune
  #filiere
  #places
  #candidats
  #tauxAcces
  #lon
  #lat
  #lien

  constructor ({ code, etablissement, intitule, commune, filiere, places, candidats, tauxAcces, lon, lat, lien }) {
    this.#code = code
    this.#etablissement = etablissement
    this.#intitule = intitule
    this.#commune = commune
    this.#filiere = filiere
    this.#places = places
    this.#candidats = candidats
    this.#tauxAcces = tauxAcces
    this.#lon = lon
    this.#lat = lat
    this.#lien = lien
  }

  get code () {
    return this.#code
  }

  get etablissement () {
    return this.#etablissement
  }

  get intitule () {
    return this.#intitule
  }

  get commune () {
    return this.#commune
  }

  get filiere () {
    return this.#filiere
  }

  get places () {
    return this.#places
  }

  get candidats () {
    return this.#candidats
  }

  get tauxAcces () {
    return this.#tauxAcces
  }

  get lon () {
    return this.#lon
  }

  get lat () {
    return this.#lat
  }

  get lien () {
    return this.#lien
  }

  correspond (recherche) {
    return contientTousLesMots([this.#intitule, this.#etablissement, this.#commune], recherche)
  }

  get candidatsParPlace () {
    if (!this.#places || this.#candidats === null) {
      return null
    }
    return Math.round(this.#candidats / this.#places * 10) / 10
  }
}
