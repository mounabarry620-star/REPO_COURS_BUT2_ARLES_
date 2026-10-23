// Petites fonctions partagées par les modèles

// Met un texte en minuscules et sans accents : "Nîmes" devient "nimes"
// (NFD sépare chaque lettre de son accent, puis la regex enlève les accents, de U+0300 à U+036F)
export const normaliser = (texte) => texte.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()

// Vrai si chaque mot de la recherche apparaît dans au moins un des textes
export const contientTousLesMots = (textes, recherche) => {
  const texte = normaliser(textes.join(' '))
  for (const mot of normaliser(recherche).split(' ')) {
    if (!texte.includes(mot)) {
      return false
    }
  }
  return true
}

// Pourcentage arrondi, ou null s'il n'y a rien à diviser
export const pourcentage = (partie, total) => {
  if (partie === null || !total) {
    return null
  }
  return Math.round(partie / total * 100)
}

// Convertit une valeur d'API en nombre : 44, "52" ou 59.0 donnent un nombre ; vide ou illisible donne null
export const versNombre = (valeur) => {
  if (valeur === null || valeur === undefined || valeur === '') {
    return null
  }
  const nombre = Number(valeur)
  return isNaN(nombre) ? null : nombre
}
