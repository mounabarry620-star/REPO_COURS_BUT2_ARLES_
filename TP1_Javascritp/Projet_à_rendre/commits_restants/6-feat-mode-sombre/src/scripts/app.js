import Handlebars from 'handlebars/dist/handlebars.js'
import modelePrincipal from './tpl/main.tpl.html'
import logo from '../images/logo.svg'
import { Cache } from './services/cache.js'
import { ServiceGeocodage } from './services/serviceGeocodage.js'
import { ServiceParcoursup } from './services/serviceParcoursup.js'
import { ServiceMonMaster } from './services/serviceMonMaster.js'
import { VueRecherche } from './vues/vueRecherche.js'
import { VueResultats } from './vues/vueResultats.js'
import { VueCarte } from './vues/vueCarte.js'
import { VueHistorique } from './vues/vueHistorique.js'
import { VueTheme } from './vues/vueTheme.js'
import { Application } from './application.js'

document.body.innerHTML = Handlebars.compile(modelePrincipal)({ logo })

// Le thème d'abord, pour que la page s'affiche tout de suite dans les bonnes couleurs
const vueTheme = new VueTheme(document.querySelector('.bouton-theme'))
vueTheme.demarrer()

const cache = new Cache()
const geocodage = new ServiceGeocodage(cache)
const parcoursup = new ServiceParcoursup(cache)
const monMaster = new ServiceMonMaster(cache)
const vueRecherche = new VueRecherche(document.querySelector('#recherche'))
const vueResultats = new VueResultats(document.querySelector('#resultats'))
const vueCarte = new VueCarte(document.querySelector('#carte'))
const vueHistorique = new VueHistorique(document.querySelector('#historique'))

const application = new Application(geocodage, parcoursup, monMaster, vueRecherche, vueResultats, vueCarte, vueHistorique)
application.demarrer()
