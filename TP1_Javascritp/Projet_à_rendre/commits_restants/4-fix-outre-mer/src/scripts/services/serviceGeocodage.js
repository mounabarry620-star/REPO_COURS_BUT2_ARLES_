import { ServiceApi } from './serviceApi.js'
import { Ville } from '../modeles/ville.js'
import { Suggestion } from '../modeles/suggestion.js'

const URL_IGN = process.env.API_IGN_URL
const URL_COMPLETION = process.env.API_IGN_COMPLETION_URL

export class ServiceGeocodage extends ServiceApi {
  async chercherVilles (nom, codePostal) {
    let url = `${URL_IGN}?q=${encodeURIComponent(nom)}&type=municipality&limit=5`
    if (codePostal) {
      url += `&postcode=${codePostal}`
    }
    const json = await this.getJson(url)

    const villes = []
    for (const feature of json.features) {
      villes.push(this.#versVille(feature))
    }
    return villes
  }

  async suggererVilles (debut) {
    const url = `${URL_COMPLETION}?text=${encodeURIComponent(debut)}&type=PositionOfInterest&poiType=commune&maximumResponses=5`
    const json = await this.getJson(url)

    const suggestions = []
    for (const resultat of json.results) {
      suggestions.push(new Suggestion({
        nom: resultat.names[0],
        codePostal: resultat.zipcode ? resultat.zipcode : null
      }))
    }
    return suggestions
  }

  #versVille (feature) {
    const proprietes = feature.properties
    const morceaux = proprietes.context.split(', ')
    return new Ville({
      nom: proprietes.name,
      departement: proprietes.depcode,
      region: this.#region(morceaux),
      lon: feature.geometry.coordinates[0],
      lat: feature.geometry.coordinates[1]
    })
  }

  // Le contexte vaut « 13, Bouches-du-Rhône, Provence-Alpes-Côte d'Azur » en métropole,
  // mais « 971, Guadeloupe » outre-mer : la Guadeloupe est à la fois un département et une région
  #region (morceaux) {
    if (morceaux.length >= 3) {
      return morceaux[2]
    }
    if (morceaux.length === 2) {
      return morceaux[1]
    }
    return null
  }
}
