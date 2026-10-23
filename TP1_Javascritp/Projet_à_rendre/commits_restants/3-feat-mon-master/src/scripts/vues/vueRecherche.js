import modeleRecherche from '../tpl/recherche.tpl.html'

export class VueRecherche {
  #formulaire
  #suggestions = new Map()

  constructor (conteneur) {
    conteneur.innerHTML = modeleRecherche
    this.#formulaire = conteneur.querySelector('form')
    this.#formulaire.addEventListener('change', (evenement) => {
      if (evenement.target.name === 'parcours') {
        this.#basculer(evenement.target.value)
      }
    })
  }

  quandRecherche (callback) {
    this.#formulaire.addEventListener('submit', (evenement) => {
      evenement.preventDefault()
      const champs = this.#formulaire.elements
      const saisie = champs.ville.value.trim()
      const suggestion = this.#suggestions.get(saisie)
      const criteres = {
        parcours: champs.parcours.value,
        nomVille: suggestion ? suggestion.nom : saisie,
        codePostal: suggestion ? suggestion.codePostal : null,
        rayonKm: Number(champs.rayon.value),
        filiere: champs.filiere.value,
        discipline: champs.discipline.value
      }
      callback(criteres)
    })
  }

  quandSaisie (callback) {
    const champ = this.#formulaire.elements.ville
    let minuteur = null
    champ.addEventListener('input', () => {
      clearTimeout(minuteur)
      minuteur = setTimeout(() => {
        const debut = champ.value.trim()
        if (debut.length >= 3 && !this.#suggestions.has(debut)) {
          callback(debut)
        }
      }, 300)
    })
  }

  proposerVilles (suggestions) {
    const liste = this.#formulaire.querySelector('datalist')
    liste.innerHTML = ''
    this.#suggestions.clear()
    for (const suggestion of suggestions) {
      const option = document.createElement('option')
      option.value = suggestion.libelle
      liste.appendChild(option)
      this.#suggestions.set(suggestion.libelle, suggestion)
    }
  }

  // Montre les champs du parcours choisi. Un champ désactivé n'est ni vérifié (required) ni utilisé
  #basculer (parcours) {
    for (const zone of this.#formulaire.querySelectorAll('.champ-formations')) {
      zone.hidden = parcours !== 'formations'
      zone.querySelector('input, select').disabled = parcours !== 'formations'
    }
    for (const zone of this.#formulaire.querySelectorAll('.champ-masters')) {
      zone.hidden = parcours !== 'masters'
      zone.querySelector('select').disabled = parcours !== 'masters'
    }
  }
}
