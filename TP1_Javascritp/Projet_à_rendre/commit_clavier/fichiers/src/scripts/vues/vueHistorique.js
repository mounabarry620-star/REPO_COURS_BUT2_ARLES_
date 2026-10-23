import Handlebars from 'handlebars/dist/handlebars.js'
import modeleFenetre from '../tpl/historique.tpl.html'
import modeleContenu from '../tpl/historique-contenu.tpl.html'

// Les couleurs sont les variables CSS de styles.scss : elles changent avec le mode clair ou sombre
// Chaque courbe a aussi son trait et sa forme de point : le graphique reste lisible sans les couleurs
const STYLES_COURBES = {
  bleu: { variable: '--action', point: 'circle', pointilles: [] },
  menthe: { variable: '--vert-menthe', point: 'rect', pointilles: [6, 4] },
  violet: { variable: '--violet', point: 'triangle', pointilles: [2, 3] }
}

// Ce qu'on affiche pour chaque sorte d'historique : la même fenêtre sert à Parcoursup et à Mon Master
const PRESENTATIONS = {
  formations: {
    source: 'Parcoursup',
    description: 'Graphique de l\'évolution du taux d\'accès et du rang du dernier appelé',
    colonnes: [
      { titre: 'Places', champ: 'places', unite: '' },
      { titre: 'Candidats', champ: 'candidats', unite: '' },
      { titre: 'Taux d\'accès', champ: 'tauxAcces', unite: '\u00a0%' },
      { titre: 'Rang du dernier appelé', champ: 'rangDernierAppele', unite: '' }
    ],
    courbes: [
      { titre: 'Taux d\'accès (%)', champ: 'tauxAcces', axe: 'gauche', style: 'bleu' },
      { titre: 'Rang du dernier appelé', champ: 'rangDernierAppele', axe: 'droite', style: 'menthe' }
    ],
    axes: { gauche: 'Taux d\'accès (%)', droite: 'Rang du dernier appelé' },
    explications: [
      { terme: 'Taux d\'accès', definition: 'part des candidats classés par la formation qui ont reçu une proposition d\'admission.' },
      { terme: 'Rang du dernier appelé', definition: 'rang du dernier candidat du premier groupe à avoir reçu une proposition. Plus il baisse, plus la formation devient sélective.' }
    ]
  },
  masters: {
    source: 'Mon Master',
    description: 'Graphique de l\'évolution du taux de proposition, pour tous les candidats, pour les licences 3 et pour les BUT 3',
    colonnes: [
      { titre: 'Places', champ: 'places', unite: '' },
      { titre: 'Candidats', champ: 'candidats', unite: '' },
      { titre: 'Propositions', champ: 'propositions', unite: '' },
      { titre: 'Taux de proposition', champ: 'tauxProposition', unite: '\u00a0%' },
      { titre: 'Taux pour les licences 3', champ: 'tauxPropositionLicence3', unite: '\u00a0%' },
      { titre: 'Taux pour les BUT 3', champ: 'tauxPropositionBut3', unite: '\u00a0%' }
    ],
    courbes: [
      { titre: 'Taux de proposition (%)', champ: 'tauxProposition', axe: 'gauche', style: 'bleu' },
      { titre: 'Taux pour les licences 3 (%)', champ: 'tauxPropositionLicence3', axe: 'gauche', style: 'violet' },
      { titre: 'Taux pour les BUT 3 (%)', champ: 'tauxPropositionBut3', axe: 'gauche', style: 'menthe' }
    ],
    axes: { gauche: 'Part des candidats (%)', droite: null },
    explications: [
      { terme: 'Taux de proposition', definition: 'part des candidats qui ont reçu une proposition d\'admission (en phase principale à partir de 2024).' },
      { terme: 'Taux pour les licences 3', definition: 'la même part, pour les seuls candidats inscrits en 3e année de licence générale. Utile pour comparer avec les BUT 3 : un master peut accepter des licences 3 et presque aucun BUT 3.' },
      { terme: 'Taux pour les BUT 3', definition: 'la même part, pour les seuls candidats inscrits en 3e année de BUT. Pas de chiffre en 2023 : le BUT est né en 2021, les premiers BUT 3 ont demandé un master en 2024.' }
    ]
  }
}

export class VueHistorique {
  #fenetre
  #titre
  #sousTitre
  #contenu
  #template
  #Chart = null
  #graphique = null

  constructor (conteneur) {
    conteneur.innerHTML = modeleFenetre
    this.#fenetre = conteneur.querySelector('dialog')
    this.#titre = conteneur.querySelector('h2')
    this.#sousTitre = conteneur.querySelector('.fenetre-sous-titre')
    this.#contenu = conteneur.querySelector('.fenetre-contenu')
    this.#template = Handlebars.compile(modeleContenu)
    this.#fenetre.querySelector('.fermer').addEventListener('click', () => this.#fenetre.close())
  }

  ouvrir (element, type) {
    this.#titre.textContent = element.intitule
    this.#sousTitre.textContent = type === 'masters' ? element.lieux : `${element.etablissement} (${element.commune})`
    this.#afficherTexte('Chargement de l\'historique...', 'chargement')
    if (!this.#fenetre.open) {
      this.#fenetre.showModal()
    }
  }

  // Chart.js n'est téléchargé qu'au premier historique ouvert (import dynamique)
  async preparerGraphique () {
    if (this.#Chart !== null) {
      return
    }
    const { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Legend } = await import('chart.js')
    Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Legend)
    Chart.defaults.font.family = "'Source Sans 3', arial, sans-serif"
    this.#Chart = Chart
  }

  afficherHistorique (historique, type) {
    const presentation = PRESENTATIONS[type]
    if (historique.nombreAnneesConnues <= 1) {
      this.#afficherTexte(`Pas encore d'historique : ${presentation.source} ne publie des chiffres que pour une seule session de cette formation.`, 'message')
      return
    }
    const annees = []
    const lignes = []
    for (const statistique of historique.statistiques) {
      annees.push(String(statistique.annee))
      const valeurs = []
      for (const { champ, unite } of presentation.colonnes) {
        valeurs.push(this.#formater(statistique[champ], unite))
      }
      lignes.push({ annee: statistique.annee, valeurs })
    }
    const titres = []
    for (const { titre } of presentation.colonnes) {
      titres.push(titre)
    }

    this.#detruireGraphique()
    // Textes et quadrillage du graphique aux couleurs du thème du moment
    this.#Chart.defaults.color = this.#couleur('--texte')
    this.#Chart.defaults.borderColor = this.#couleur('--bordure')
    this.#contenu.innerHTML = this.#template({
      source: presentation.source,
      description: presentation.description,
      colonnes: titres,
      annees: lignes,
      explications: presentation.explications
    })
    this.#graphique = new this.#Chart(this.#contenu.querySelector('canvas'), {
      type: 'line',
      data: { labels: annees, datasets: this.#courbes(historique, presentation) },
      options: {
        maintainAspectRatio: false,
        plugins: {
          legend: { labels: { usePointStyle: true } }
        },
        scales: this.#axes(presentation)
      }
    })
  }

  afficherErreur (texte) {
    this.#afficherTexte(texte, 'erreur')
  }

  #courbes (historique, presentation) {
    const courbes = []
    for (const courbe of presentation.courbes) {
      const donnees = []
      for (const statistique of historique.statistiques) {
        donnees.push(statistique[courbe.champ])
      }
      const style = STYLES_COURBES[courbe.style]
      const couleur = this.#couleur(style.variable)
      courbes.push({
        label: courbe.titre,
        data: donnees,
        yAxisID: courbe.axe,
        borderColor: couleur,
        backgroundColor: couleur,
        pointStyle: style.point,
        pointRadius: 5,
        borderDash: style.pointilles
      })
    }
    return courbes
  }

  #axes (presentation) {
    const axes = {
      gauche: { type: 'linear', position: 'left', min: 0, max: 100, title: { display: true, text: presentation.axes.gauche } }
    }
    if (presentation.axes.droite !== null) {
      axes.droite = { type: 'linear', position: 'right', beginAtZero: true, title: { display: true, text: presentation.axes.droite }, grid: { drawOnChartArea: false } }
    }
    return axes
  }

  // Lit la valeur d'une variable CSS définie sur <html> (voir styles.scss)
  #couleur (variable) {
    return getComputedStyle(document.documentElement).getPropertyValue(variable).trim()
  }

  #afficherTexte (texte, classe) {
    this.#detruireGraphique()
    const paragraphe = document.createElement('p')
    paragraphe.className = classe
    paragraphe.textContent = texte
    this.#contenu.innerHTML = ''
    this.#contenu.appendChild(paragraphe)
  }

  #detruireGraphique () {
    if (this.#graphique !== null) {
      this.#graphique.destroy()
      this.#graphique = null
    }
  }

  #formater (valeur, unite) {
    return valeur === null ? 'non communiqué' : `${valeur.toLocaleString('fr-FR')}${unite}`
  }
}
