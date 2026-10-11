/*
 * TOC : module de génération automatique de sommaires.
 *
 * - Au chargement de la page, un sommaire est construit dans #toc
 *   et dans chaque bloc portant l'attribut data-toc.
 * - Chaque bloc peut être réglé avec data-title (titre) et data-depth
 *   (profondeur : 1 = h1, 2 = h1 et h2, etc.).
 * - TOC.add(selecteur, options) ajoute un sommaire dans les blocs choisis.
 *
 * Module « ad-hoc » (revealing module pattern, cf. chapitre 4) : seule la
 * méthode add est exposée, le reste est privé.
 */
// TOC est utilisé par les autres scripts de la page (TOC.add), pas dans ce fichier
// eslint-disable-next-line no-unused-vars
const TOC = (() => {
  const SELECTEUR_DEFAUT = '#toc, [data-toc]'
  const TITRE_DEFAUT = 'Sommaire'
  const PROFONDEUR_DEFAUT = 1
  const PROFONDEUR_MAX = 6

  let compteurId = 0

  // Garantit qu'un titre possède un id, pour pouvoir créer un lien vers lui.
  // Un id déjà présent est conservé : plusieurs sommaires pointent vers le même titre.
  const identifier = (titre) => {
    if (titre.id === '') {
      compteurId++
      titre.id = `titre-${compteurId}`
    }
    return titre.id
  }

  // Lit la profondeur demandée et la ramène entre 1 et 6
  const lireProfondeur = (valeur) => {
    const profondeur = parseInt(valeur, 10)
    if (isNaN(profondeur)) {
      return PROFONDEUR_DEFAUT
    }
    return Math.min(Math.max(profondeur, 1), PROFONDEUR_MAX)
  }

  // h1, h2, …, hN
  const selecteurTitres = (profondeur) => {
    const balises = []
    for (let niveau = 1; niveau <= profondeur; niveau++) {
      balises.push(`h${niveau}`)
    }
    return balises.join(', ')
  }

  const creerEntree = (titre) => {
    const lien = document.createElement('a')
    lien.href = `#${identifier(titre)}`
    lien.textContent = titre.textContent

    const item = document.createElement('li')
    item.appendChild(lien)
    return item
  }

  // Construit les listes imbriquées. listes[i] est la liste du niveau i + 1 :
  // un h2 va dans une sous-liste du dernier h1, un h3 dans celle du dernier h2…
  const creerListe = (profondeur) => {
    const racine = document.createElement('ul')
    const listes = [racine]

    for (const titre of document.querySelectorAll(selecteurTitres(profondeur))) {
      const niveau = Number(titre.tagName.charAt(1))

      // On remonte si le titre est moins profond que le précédent
      while (listes.length > niveau) {
        listes.pop()
      }

      // On descend si le titre est plus profond (même si un niveau est sauté)
      while (listes.length < niveau) {
        const parent = listes[listes.length - 1]
        if (parent.lastChild === null) {
          parent.appendChild(document.createElement('li'))
        }
        const sousListe = document.createElement('ul')
        parent.lastChild.appendChild(sousListe)
        listes.push(sousListe)
      }

      listes[listes.length - 1].appendChild(creerEntree(titre))
    }

    return racine
  }

  // Les data-* du bloc sont prioritaires sur les options passées à add
  const construire = (bloc, { titre = TITRE_DEFAUT, profondeur = PROFONDEUR_DEFAUT } = {}) => {
    const entete = document.createElement('p')
    entete.classList.add('toc-titre')
    entete.textContent = bloc.dataset.title || titre

    bloc.textContent = ''
    bloc.classList.add('toc')
    bloc.appendChild(entete)
    bloc.appendChild(creerListe(lireProfondeur(bloc.dataset.depth || profondeur)))
  }

  const add = (selecteur, options = {}) => {
    for (const bloc of document.querySelectorAll(selecteur)) {
      construire(bloc, options)
    }
  }

  // Inclure le script suffit : les sommaires par défaut sont créés une fois la page chargée
  window.addEventListener('load', () => {
    add(SELECTEUR_DEFAUT)
  })

  return {
    add
  }
})()
