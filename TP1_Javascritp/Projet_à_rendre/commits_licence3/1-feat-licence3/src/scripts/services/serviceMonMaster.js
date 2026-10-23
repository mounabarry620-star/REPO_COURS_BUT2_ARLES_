import { ServiceApi } from './serviceApi.js'
import { versNombre } from '../outils.js'
import { Master } from '../modeles/master.js'
import { StatistiqueMaster } from '../modeles/statistiqueMaster.js'
import { Historique } from '../modeles/historique.js'

const URL_JEUX = process.env.API_MON_MASTER_URL
const SESSION = '2025'
const CHAMPS = 'ifc,eta_nom,mention,parcours,lieux,alternance,col,n_can_pp,n_prop_total,n_can_lg3_pp,n_prop_lg3_total,n_can_but3_pp,n_prop_but3_total'
// Chaque session a ses propres noms de champs : 2023 n'a pas les mêmes, ni de chiffres pour les BUT 3
// (le BUT est né en 2021 : les premiers BUT 3 ont demandé un master en 2024). Licence 3 = licence générale
const JEUX_HISTORIQUE = [
  { annee: 2023, jeu: 'fr-esr-mon_master_2023', champs: { candidats: 'n_can', propositions: 'n_prop', candidatsLicence3: 'n_can_lg3', propositionsLicence3: 'n_prop_lg3', candidatsBut3: null, propositionsBut3: null } },
  { annee: 2024, jeu: 'fr-esr-mon_master', champs: { candidats: 'n_can_pp', propositions: 'n_prop_total', candidatsLicence3: 'n_can_lg3_pp', propositionsLicence3: 'n_prop_lg3_total', candidatsBut3: 'n_can_but3_pp', propositionsBut3: 'n_prop_but3_total' } },
  { annee: 2025, jeu: 'fr-esr-mon_master', champs: { candidats: 'n_can_pp', propositions: 'n_prop_total', candidatsLicence3: 'n_can_lg3_pp', propositionsLicence3: 'n_prop_lg3_total', candidatsBut3: 'n_can_but3_pp', propositionsBut3: 'n_prop_but3_total' } }
]

export class ServiceMonMaster extends ServiceApi {
  async mastersDeLaRegion (region, discipline) {
    let where = `session="${SESSION}" and lieu_reg_acad_lib="${region}"`
    if (discipline) {
      where += ` and secteur_disci_lib="${discipline}"`
    }
    const url = `${URL_JEUX}/fr-esr-mon_master/exports/json?where=${encodeURIComponent(where)}&select=${CHAMPS}`
    const json = await this.getJson(url)

    const masters = []
    for (const record of json) {
      masters.push(this.#versMaster(record))
    }
    return masters
  }

  async historique (code) {
    const promesses = []
    for (const { annee, jeu, champs } of JEUX_HISTORIQUE) {
      promesses.push(this.#statistiqueAnnuelle(annee, jeu, champs, code))
    }
    const statistiques = await Promise.all(promesses)
    return new Historique(statistiques)
  }

  async #statistiqueAnnuelle (annee, jeu, champs, code) {
    const where = `ifc="${code}" and session="${annee}"`
    const select = ['col']
    for (const nom of [champs.candidats, champs.propositions, champs.candidatsLicence3, champs.propositionsLicence3, champs.candidatsBut3, champs.propositionsBut3]) {
      if (nom !== null) {
        select.push(nom)
      }
    }
    const url = `${URL_JEUX}/${jeu}/records?where=${encodeURIComponent(where)}&select=${select.join(',')}&limit=1`
    const json = await this.getJson(url)
    const record = json.results.length > 0 ? json.results[0] : {}
    return new StatistiqueMaster({
      annee,
      places: versNombre(record.col),
      candidats: versNombre(record[champs.candidats]),
      propositions: versNombre(record[champs.propositions]),
      candidatsLicence3: versNombre(record[champs.candidatsLicence3]),
      propositionsLicence3: versNombre(record[champs.propositionsLicence3]),
      candidatsBut3: champs.candidatsBut3 === null ? null : versNombre(record[champs.candidatsBut3]),
      propositionsBut3: champs.propositionsBut3 === null ? null : versNombre(record[champs.propositionsBut3])
    })
  }

  #versMaster (record) {
    // Plusieurs lieux sont séparés par « | » dans les données
    const lieux = record.lieux ? record.lieux.split('|') : []
    return new Master({
      code: record.ifc,
      etablissement: record.eta_nom,
      mention: record.mention,
      parcours: record.parcours,
      lieux: lieux.length > 0 ? lieux.join(' / ') : null,
      departements: this.#departements(lieux),
      alternance: record.alternance === '1',
      places: versNombre(record.col),
      candidats: versNombre(record.n_can_pp),
      propositions: versNombre(record.n_prop_total),
      candidatsLicence3: versNombre(record.n_can_lg3_pp),
      propositionsLicence3: versNombre(record.n_prop_lg3_total),
      candidatsBut3: versNombre(record.n_can_but3_pp),
      propositionsBut3: versNombre(record.n_prop_but3_total)
    })
  }

  // Chaque lieu finit par son département entre parenthèses : « IUT d'Arles - ARLES (13) »
  #departements (lieux) {
    const departements = []
    for (const lieu of lieux) {
      const debut = lieu.lastIndexOf('(')
      const fin = lieu.lastIndexOf(')')
      if (debut !== -1 && fin > debut) {
        departements.push(lieu.slice(debut + 1, fin).trim())
      }
    }
    return departements
  }
}
