import { contientTousLesMots, pourcentage } from '../outils.js'

export class Master {
  #code
  #etablissement
  #mention
  #parcours
  #lieux
  #departements
  #alternance
  #places
  #candidats
  #propositions
  #candidatsLicence3
  #propositionsLicence3
  #candidatsBut3
  #propositionsBut3

  constructor ({ code, etablissement, mention, parcours, lieux, departements, alternance, places, candidats, propositions, candidatsLicence3, propositionsLicence3, candidatsBut3, propositionsBut3 }) {
    this.#code = code
    this.#etablissement = etablissement
    this.#mention = mention
    this.#parcours = parcours
    this.#lieux = lieux
    this.#departements = departements
    this.#alternance = alternance
    this.#places = places
    this.#candidats = candidats
    this.#propositions = propositions
    this.#candidatsLicence3 = candidatsLicence3
    this.#propositionsLicence3 = propositionsLicence3
    this.#candidatsBut3 = candidatsBut3
    this.#propositionsBut3 = propositionsBut3
  }

  get code () {
    return this.#code
  }

  get etablissement () {
    return this.#etablissement
  }

  get mention () {
    return this.#mention
  }

  get parcours () {
    return this.#parcours
  }

  get lieux () {
    return this.#lieux
  }

  get alternance () {
    return this.#alternance
  }

  get places () {
    return this.#places
  }

  get candidats () {
    return this.#candidats
  }

  get propositions () {
    return this.#propositions
  }

  get candidatsLicence3 () {
    return this.#candidatsLicence3
  }

  get propositionsLicence3 () {
    return this.#propositionsLicence3
  }

  get candidatsBut3 () {
    return this.#candidatsBut3
  }

  get propositionsBut3 () {
    return this.#propositionsBut3
  }

  get intitule () {
    return this.#parcours ? `${this.#mention} - ${this.#parcours}` : this.#mention
  }

  // Part des candidats qui ont reçu une proposition d'admission
  get tauxProposition () {
    return pourcentage(this.#propositions, this.#candidats)
  }

  // La même chose pour les seuls candidats inscrits en 3e année de licence générale
  get tauxPropositionLicence3 () {
    return pourcentage(this.#propositionsLicence3, this.#candidatsLicence3)
  }

  // La même chose pour les seuls candidats inscrits en BUT 3
  get tauxPropositionBut3 () {
    return pourcentage(this.#propositionsBut3, this.#candidatsBut3)
  }

  // Mon Master note la Corse "20", alors que l'IGN la découpe en 2A et 2B
  estDansLeDepartement (departement) {
    const code = departement === '2A' || departement === '2B' ? '20' : departement
    return this.#departements.includes(code)
  }

  correspond (recherche) {
    return contientTousLesMots([this.#mention, this.#parcours, this.#etablissement, this.#lieux], recherche)
  }
}
