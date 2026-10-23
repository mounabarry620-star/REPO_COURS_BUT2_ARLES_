export class Application {
  #geocodage
  #parcoursup
  #monMaster
  #vueRecherche
  #vueResultats
  #vueCarte
  #vueHistorique
  #numeroRecherche = 0
  #numeroSuggestion = 0
  #numeroHistorique = 0
  #resultat = null

  constructor (geocodage, parcoursup, monMaster, vueRecherche, vueResultats, vueCarte, vueHistorique) {
    this.#geocodage = geocodage
    this.#parcoursup = parcoursup
    this.#monMaster = monMaster
    this.#vueRecherche = vueRecherche
    this.#vueResultats = vueResultats
    this.#vueCarte = vueCarte
    this.#vueHistorique = vueHistorique
  }

  demarrer () {
    this.#vueRecherche.quandRecherche((criteres) => this.rechercher(criteres))
    this.#vueRecherche.quandSaisie((debut) => this.suggerer(debut))
    this.#vueResultats.quandFiltre((recherche) => this.filtrer(recherche))
    this.#vueResultats.quandHistorique((code) => this.afficherHistorique(code))
  }

  async afficherHistorique (code) {
    if (this.#resultat === null) {
      return
    }
    let element = null
    for (const candidat of this.#resultat.elements) {
      if (candidat.code === code) {
        element = candidat
      }
    }
    if (element === null) {
      return
    }
    const { type, service } = this.#resultat
    this.#numeroHistorique += 1
    const numero = this.#numeroHistorique
    this.#vueHistorique.ouvrir(element, type)
    try {
      // Polymorphisme : ServiceParcoursup et ServiceMonMaster ont chacun leur méthode historique
      const [historique] = await Promise.all([
        service.historique(code),
        this.#vueHistorique.preparerGraphique()
      ])
      if (numero === this.#numeroHistorique) {
        this.#vueHistorique.afficherHistorique(historique, type)
      }
    } catch (erreur) {
      console.log(erreur)
      if (numero === this.#numeroHistorique) {
        this.#vueHistorique.afficherErreur('L\'historique n\'a pas pu être chargé : pas de connexion internet, ou le service de données ne répond pas. Réessayez dans quelques instants.')
      }
    }
  }

  filtrer (recherche) {
    if (this.#resultat === null) {
      return
    }
    const { type, ville, elements, rayonKm } = this.#resultat
    const selection = []
    for (const element of elements) {
      // Polymorphisme : Formation et Master ont chacun leur méthode correspond
      if (element.correspond(recherche)) {
        selection.push(element)
      }
    }
    this.#vueResultats.afficherSelection(selection, elements.length)
    if (type === 'formations') {
      this.#vueCarte.afficherFormations(ville, selection, rayonKm)
    }
  }

  async suggerer (debut) {
    this.#numeroSuggestion += 1
    const numero = this.#numeroSuggestion
    try {
      const suggestions = await this.#geocodage.suggererVilles(debut)
      if (numero === this.#numeroSuggestion) {
        this.#vueRecherche.proposerVilles(suggestions)
      }
    } catch (erreur) {
      console.log(erreur)
      this.#vueRecherche.proposerVilles([])
    }
  }

  async rechercher ({ parcours, nomVille, codePostal, rayonKm, filiere, zone, discipline }) {
    this.#numeroRecherche += 1
    const numero = this.#numeroRecherche
    this.#resultat = null
    this.#vueResultats.afficherChargement()
    this.#vueCarte.effacer()
    try {
      const villes = await this.#geocodage.chercherVilles(nomVille, codePostal)
      if (numero !== this.#numeroRecherche) {
        return
      }
      if (villes.length === 0) {
        this.#vueResultats.afficherMessage(`Aucune commune ne s'appelle « ${nomVille} ».`)
        return
      }
      const ville = villes[0]
      if (parcours === 'masters') {
        await this.#rechercherMasters(numero, ville, zone, discipline)
      } else {
        await this.#rechercherFormations(numero, ville, rayonKm, filiere)
      }
    } catch (erreur) {
      console.log(erreur)
      if (numero === this.#numeroRecherche) {
        this.#vueResultats.afficherErreur('La recherche a échoué : pas de connexion internet, ou le service de données ne répond pas. Réessayez dans quelques instants.')
      }
    }
  }

  async #rechercherFormations (numero, ville, rayonKm, filiere) {
    const formations = await this.#parcoursup.formationsAutour(ville, rayonKm, filiere)
    if (numero !== this.#numeroRecherche) {
      return
    }
    if (formations.length === 0) {
      this.#vueResultats.afficherMessage(`Aucune formation à moins de ${rayonKm} km de ${ville.libelle}.`)
      return
    }
    this.#resultat = { type: 'formations', service: this.#parcoursup, ville, elements: formations, rayonKm }
    this.#vueResultats.afficherFormations(ville, formations)
    this.#vueCarte.afficherFormations(ville, formations, rayonKm)
  }

  // Requête 2 du parcours étudiant : elle dépend de la région trouvée par la requête 1
  async #rechercherMasters (numero, ville, zone, discipline) {
    if (ville.region === null) {
      this.#vueResultats.afficherMessage(`La région de ${ville.libelle} est inconnue : impossible de chercher ses masters.`)
      return
    }
    let masters = await this.#monMaster.mastersDeLaRegion(ville.region, discipline)
    if (numero !== this.#numeroRecherche) {
      return
    }
    // Mon Master ne sait pas chercher par département : on garde ceux du département parmi ceux de la région
    let perimetre = `en ${ville.region}`
    if (zone === 'departement') {
      perimetre = `dans le département ${ville.departement}`
      const duDepartement = []
      for (const master of masters) {
        if (master.estDansLeDepartement(ville.departement)) {
          duDepartement.push(master)
        }
      }
      masters = duDepartement
    }
    if (masters.length === 0) {
      const domaine = discipline ? ` en ${discipline}` : ''
      this.#vueResultats.afficherMessage(`Aucun master${domaine} ${perimetre}.`)
      return
    }
    this.#resultat = { type: 'masters', service: this.#monMaster, ville, elements: masters, rayonKm: null }
    this.#vueResultats.afficherMasters(perimetre, masters, discipline)
    this.#vueCarte.masquer()
  }
}
