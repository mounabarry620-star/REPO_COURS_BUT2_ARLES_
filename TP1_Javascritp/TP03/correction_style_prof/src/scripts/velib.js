// Accès à l'API Vélib' Métropole (format GBFS).
// Les URL commencent par /api : elles passent par le proxy de webpack (cf. webpack.dev.js),
// qui les redirige vers API_URL (fichier .env) et évite le blocage CORS.
const VELIB = (() => {
  const BASE = '/api/opendata/Velib_Metropole'

  // fetch ne rejette pas sur une erreur HTTP (404, 500…) : il faut tester response.ok
  const getJson = async (url) => {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`erreur HTTP ! statut : ${response.status}`)
    }
    return response.json()
  }

  // Caractéristiques fixes de chaque station : identifiant, nom, position, capacité
  const getStations = async () => {
    const donnees = await getJson(`${BASE}/station_information.json`)
    return donnees.data.stations
  }

  // État en temps réel de chaque station : vélos disponibles, bornes libres
  const getStatuts = async () => {
    const donnees = await getJson(`${BASE}/station_status.json`)
    return donnees.data.stations
  }

  return {
    getStations,
    getStatuts
  }
})()

export { VELIB }
