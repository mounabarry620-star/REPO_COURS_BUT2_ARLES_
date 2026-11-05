#!/bin/bash
# Recopie les images du professeur depuis PROJET_FINAL sans les modifier.
# À lancer depuis ce dossier, ou avec bash chemin/copier_images.sh.
set -euo pipefail
ICI="$(cd "$(dirname "$0")" && pwd)"
SRC="$(cd "$ICI/../../PROJET_FINAL/images" && pwd)"
DEST="$ICI/images"
if [ -d "$DEST/." ] && [ -n "$(ls -A "$DEST" 2>/dev/null || true)" ]; then
  echo "images/ existe déjà dans $ICI — rien copié."
  exit 0
fi
mkdir -p "$DEST"
cp -a "$SRC/." "$DEST/"
echo "Images copiées depuis $SRC"
