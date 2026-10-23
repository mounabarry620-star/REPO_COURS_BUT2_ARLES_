import { ServiceApi } from './serviceApi.js'
import { versNombre } from '../outils.js'
import { Formation } from '../modeles/formation.js'
import { StatistiqueAnnuelle } from '../modeles/statistiqueAnnuelle.js'
import { Historique } from '../modeles/historique.js'

const URL_PARCOURSUP = process.env.API_PARCOURSUP_URL
const URL_JEUX = process.env.API_PARCOURSUP_JEUX_URL
// Un jeu de données par session : pour ajouter 2026, il suffira d'ajouter une ligne
const JEUX_HISTORIQUE = [
  { annee: 2022, jeu: 'fr-esr-parcoursup_2022' },
  { annee: 2023, jeu: 'fr-esr-parcoursup_2023' },
  { annee: 2024, jeu: 'fr-esr-parcoursup_2024' },
  { annee: 2025, jeu: 'fr-esr-parcoursup' }
]
const CHAMPS_HISTORIQUE = 'capa_fin,voe_tot,taux_acces_ens,ran_grp1'
const CHAMPS = 'cod_aff_form,g_ea_lib_vx,lib_for_voe_ins,ville_etab,fili,capa_fin,voe_tot,taux_acces_ens,g_olocalisation_des_formations,lien_form_psup'

export class ServiceParcoursup extends ServiceApi {
  async formationsAutour (ville, rayonKm, filiere) {
    let where = `within_distance(g_olocalisation_des_formations, geom'POINT(${ville.lon} ${ville.lat})', ${rayonKm}km)`
    if (filiere) {
      where += ` and fili="${filiere}"`
    }
    const url = `${URL_PARCOURSUP}?where=${encodeURIComponent(where)}&select=${CHAMPS}`
    const json = await this.getJson(url)

    const formations = []
    for (const record of json) {
      formations.push(this.#versFormation(record))
    }
    return formations
  }

  async historique (code) {
    const promesses = []
    for (const { annee, jeu } of JEUX_HISTORIQUE) {
      promesses.push(this.#statistiqueAnnuelle(annee, jeu, code))
    }
    const statistiques = await Promise.all(promesses)
    return new Historique(statistiques)
  }

  async #statistiqueAnnuelle (annee, jeu, code) {
    const where = `cod_aff_form="${code}"`
    const url = `${URL_JEUX}/${jeu}/records?where=${encodeURIComponent(where)}&select=${CHAMPS_HISTORIQUE}&limit=1`
    const json = await this.getJson(url)
    const record = json.results.length > 0 ? json.results[0] : {}
    return new StatistiqueAnnuelle({
      annee,
      places: versNombre(record.capa_fin),
      candidats: versNombre(record.voe_tot),
      tauxAcces: versNombre(record.taux_acces_ens),
      rangDernierAppele: versNombre(record.ran_grp1)
    })
  }

  #versFormation (record) {
    return new Formation({
      code: record.cod_aff_form,
      etablissement: record.g_ea_lib_vx,
      intitule: record.lib_for_voe_ins,
      commune: record.ville_etab,
      filiere: record.fili,
      places: versNombre(record.capa_fin),
      candidats: versNombre(record.voe_tot),
      tauxAcces: versNombre(record.taux_acces_ens),
      lon: record.g_olocalisation_des_formations.lon,
      lat: record.g_olocalisation_des_formations.lat,
      lien: this.#versLien(record.lien_form_psup)
    })
  }

  #versLien (valeur) {
    return typeof valeur === 'string' && valeur.startsWith('https://') ? valeur : null
  }
}
