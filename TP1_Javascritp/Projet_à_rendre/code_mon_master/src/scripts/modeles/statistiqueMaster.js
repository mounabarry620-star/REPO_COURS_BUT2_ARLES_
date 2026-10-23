import { pourcentage } from '../outils.js'

export class StatistiqueMaster {
  #annee
  #places
  #candidats
  #propositions
  #candidatsBut3
  #propositionsBut3

  constructor ({ annee, places, candidats, propositions, candidatsBut3, propositionsBut3 }) {
    this.#annee = annee
    this.#places = places
    this.#candidats = candidats
    this.#propositions = propositions
    this.#candidatsBut3 = candidatsBut3
    this.#propositionsBut3 = propositionsBut3
  }

  get annee () {
    return this.#annee
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

  get tauxProposition () {
    return pourcentage(this.#propositions, this.#candidats)
  }

  get tauxPropositionBut3 () {
    return pourcentage(this.#propositionsBut3, this.#candidatsBut3)
  }

  get connue () {
    return this.#candidats !== null
  }
}
