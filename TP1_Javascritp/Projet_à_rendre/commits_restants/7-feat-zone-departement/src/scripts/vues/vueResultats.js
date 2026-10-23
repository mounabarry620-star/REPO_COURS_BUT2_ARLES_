import Handlebars from 'handlebars/dist/handlebars.js'
import modeleResultats from '../tpl/resultats.tpl.html'
import modeleListe from '../tpl/liste.tpl.html'
import modeleMasters from '../tpl/liste-masters.tpl.html'

export class VueResultats {
  #conteneur
  #template
  #templateListe
  #templateMasters
  #type = 'formations'

  constructor (conteneur) {
    this.#conteneur = conteneur
    this.#template = Handlebars.compile(modeleResultats)
    this.#templateListe = Handlebars.compile(modeleListe)
    this.#templateMasters = Handlebars.compile(modeleMasters)
  }

  afficherChargement () {
    this.#afficherTexte('Recherche en cours…', 'chargement')
  }

  afficherMessage (texte) {
    this.#afficherTexte(texte, 'message')
  }

  afficherErreur (texte) {
    this.#afficherTexte(texte, 'erreur')
  }

  afficherFormations (ville, formations) {
    this.#type = 'formations'
    this.#conteneur.innerHTML = this.#template({
      resume: `${formations.length} formation(s) autour de ${ville.libelle}`,
      mots: 'formations'
    })
    this.afficherSelection(formations, formations.length)
  }

  afficherMasters (perimetre, masters, discipline) {
    this.#type = 'masters'
    const domaine = discipline ? ` en ${discipline}` : ''
    this.#conteneur.innerHTML = this.#template({
      resume: `${masters.length} master(s)${domaine} ${perimetre} (session 2025)`,
      remarque: 'Mon Master ne publie pas la localisation précise des masters : ils ne sont donc pas placés sur une carte.',
      mots: 'masters'
    })
    this.afficherSelection(masters, masters.length)
  }

  afficherSelection (elements, total) {
    const lignes = []
    for (const element of elements) {
      lignes.push(this.#type === 'masters' ? this.#ligneMaster(element) : this.#ligneFormation(element))
    }
    const liste = this.#conteneur.querySelector('.formations')
    if (this.#type === 'masters') {
      liste.innerHTML = this.#templateMasters({ masters: lignes })
    } else {
      liste.innerHTML = this.#templateListe({ formations: lignes })
    }

    const mot = this.#type === 'masters' ? 'master(s)' : 'formation(s)'
    const compteur = this.#conteneur.querySelector('.compteur')
    if (elements.length === 0) {
      compteur.textContent = this.#type === 'masters' ? 'Aucun master ne correspond à ce filtre.' : 'Aucune formation ne correspond à ce filtre.'
    } else if (elements.length < total) {
      compteur.textContent = `${elements.length} ${mot} sur ${total}`
    } else {
      compteur.textContent = ''
    }
  }

  quandFiltre (callback) {
    let minuteur = null
    this.#conteneur.addEventListener('input', (evenement) => {
      if (evenement.target.name !== 'filtre') {
        return
      }
      clearTimeout(minuteur)
      minuteur = setTimeout(() => {
        const recherche = evenement.target.value.trim()
        callback(recherche)
      }, 200)
    })
  }

  quandHistorique (callback) {
    this.#conteneur.addEventListener('click', (evenement) => {
      const bouton = evenement.target.closest('button[data-code]')
      if (bouton === null) {
        return
      }
      callback(bouton.dataset.code)
    })
  }

  #ligneFormation (formation) {
    return {
      code: formation.code,
      intitule: formation.intitule,
      etablissement: formation.etablissement,
      commune: formation.commune,
      lien: formation.lien,
      tauxAcces: this.#formater(formation.tauxAcces, ' %'),
      places: this.#formater(formation.places, ''),
      candidatsParPlace: this.#formater(formation.candidatsParPlace, '')
    }
  }

  #ligneMaster (master) {
    let but3 = 'non communiqué'
    if (master.candidatsBut3 === 0) {
      but3 = 'aucun candidat inscrit en BUT 3'
    } else if (master.candidatsBut3 !== null) {
      but3 = `${this.#formater(master.tauxPropositionBut3, ' %')} (${master.propositionsBut3} proposition(s) pour ${master.candidatsBut3} candidats)`
    }
    return {
      code: master.code,
      mention: master.mention,
      parcours: master.parcours,
      etablissement: master.etablissement,
      lieux: master.lieux,
      alternance: master.alternance,
      places: this.#formater(master.places, ''),
      candidats: this.#formater(master.candidats, ''),
      tauxProposition: this.#formater(master.tauxProposition, ' %'),
      but3
    }
  }

  #afficherTexte (texte, classe) {
    const paragraphe = document.createElement('p')
    paragraphe.className = classe
    paragraphe.textContent = texte
    this.#conteneur.innerHTML = ''
    this.#conteneur.appendChild(paragraphe)
  }

  #formater (valeur, unite) {
    return valeur === null ? 'non communiqué' : `${valeur}${unite}`
  }
}
