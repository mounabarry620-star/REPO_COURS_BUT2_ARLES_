// Clé sous laquelle le choix de l'utilisateur est retenu dans le navigateur
const CLE = 'theme'

// Mode clair ou sombre : l'attribut data-theme de <html> choisit les couleurs de styles.scss
export class VueTheme {
  #bouton
  #racine = document.documentElement

  constructor (bouton) {
    this.#bouton = bouton
  }

  demarrer () {
    const systemeSombre = window.matchMedia('(prefers-color-scheme: dark)')
    const choix = this.#lireChoix()
    if (choix !== null) {
      this.#appliquer(choix)
    } else {
      this.#appliquer(systemeSombre.matches ? 'sombre' : 'clair')
    }
    // Sans choix de l'utilisateur, on suit le réglage de son système, même s'il change
    systemeSombre.addEventListener('change', (evenement) => {
      if (this.#lireChoix() === null) {
        this.#appliquer(evenement.matches ? 'sombre' : 'clair')
      }
    })
    this.#bouton.addEventListener('click', () => this.basculer())
  }

  basculer () {
    const theme = this.#racine.dataset.theme === 'sombre' ? 'clair' : 'sombre'
    this.#appliquer(theme)
    try {
      localStorage.setItem(CLE, theme)
    } catch (erreur) {
      // Stockage bloqué (navigation privée…) : le thème change quand même, il ne sera juste pas retenu
      console.log(erreur)
    }
  }

  #lireChoix () {
    try {
      const choix = localStorage.getItem(CLE)
      return choix === 'clair' || choix === 'sombre' ? choix : null
    } catch (erreur) {
      console.log(erreur)
      return null
    }
  }

  #appliquer (theme) {
    this.#racine.dataset.theme = theme
    this.#bouton.setAttribute('aria-pressed', String(theme === 'sombre'))
  }
}
