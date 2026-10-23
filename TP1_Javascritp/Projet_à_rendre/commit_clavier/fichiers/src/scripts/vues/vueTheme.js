// Clé sous laquelle le choix de l'utilisateur est retenu dans le navigateur
const CLE = 'theme'

// Mode clair ou sombre : l'attribut data-theme de <html> choisit les couleurs de styles.scss
export class VueTheme {
  #bouton
  #racine = document.documentElement
  #systemeSombre = window.matchMedia('(prefers-color-scheme: dark)')

  constructor (bouton) {
    this.#bouton = bouton
  }

  demarrer () {
    const choix = this.#lireChoix()
    if (choix !== null) {
      this.#appliquer(choix)
    } else {
      this.#appliquer(this.#themeSysteme())
    }
    // Sans choix de l'utilisateur, on suit le réglage de son système, même s'il change
    this.#systemeSombre.addEventListener('change', () => {
      if (this.#lireChoix() === null) {
        this.#appliquer(this.#themeSysteme())
      }
    })
    this.#bouton.addEventListener('click', () => this.basculer())
  }

  basculer () {
    const theme = this.#racine.dataset.theme === 'sombre' ? 'clair' : 'sombre'
    this.#appliquer(theme)
    try {
      if (theme === this.#themeSysteme()) {
        // Revenu au thème du système : on oublie le choix, la page suivra de nouveau le système
        localStorage.removeItem(CLE)
      } else {
        localStorage.setItem(CLE, theme)
      }
    } catch (erreur) {
      // Stockage bloqué (navigation privée...) : le thème change quand même, il ne sera juste pas retenu
      console.log(erreur)
    }
  }

  #themeSysteme () {
    return this.#systemeSombre.matches ? 'sombre' : 'clair'
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
