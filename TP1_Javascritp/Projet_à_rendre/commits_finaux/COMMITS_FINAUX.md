# Deux derniers commits

Lignes une par une, en utilisateur normal :

```bash
cd ~/Documents/parcoursup-explorer
git switch main
git switch -c fix/message-erreur
R=~/Documents/REPO_COURS_BUT2_ARLES_/TP1_Javascritp/Projet_à_rendre/commits_finaux
ls "$R"
```

## 1. Le diagramme oublié (étape 4 des corrections)

```bash
cp -r "$R/1-docs-diagramme/." .
git status
git add docs/diagramme-classes.drawio.pdf
git commit -m "docs: met à jour VueTheme dans le diagramme de classes" -m "Attribut systemeSombre et méthode themeSysteme."
```

## 2. Message d'erreur juste

```bash
cp -r "$R/2-fix-message-erreur/." .
git status
npx standard src/
git add src/scripts/application.js
git commit -m "fix: ne met plus seulement en cause la connexion quand une API échoue" -m "Si l'IGN ou l'open data répond 429 (trop de requêtes) ou 500, la connexion de l'utilisateur n'y est pour rien : le message dit maintenant que la connexion ou le service de données peut être en cause."
```

## Envoi et fusion

```bash
git push -u origin fix/message-erreur
git switch main
git merge fix/message-erreur
git push
git log --oneline -3
```
