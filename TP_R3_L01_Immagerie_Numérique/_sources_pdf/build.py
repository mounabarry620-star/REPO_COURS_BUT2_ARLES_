#!/usr/bin/env python3
"""Fabrique les PDF de révision à partir des fichiers .html de ce dossier.

Usage : python3 build.py            (tous les documents)
        python3 build.py tp1 revision  (seulement ceux-là)

Chaque fichier source contient des <section class="slide">. Le script :
  - colore le C++ placé dans <pre class="cpp"> ... </pre> (code brut, non échappé) ;
  - ajoute le pied de page (titre du document + numéro de page) ;
  - imprime le résultat en PDF avec Chromium (format 160 x 90 mm, comme Beamer 16:9).
"""
import html, os, re, subprocess, sys, tempfile

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(ICI)

DOCS = {  # source -> (PDF produit, titre court pour le pied de page)
    "revision": ("REVISION_CONTROLE_TD_R3L01.pdf", "Révisions du contrôle de TD"),
    "tp1": ("TP1_TD1/TP1_explications.pdf", "TP1 : GrayImage et PGM"),
    "tp2": ("TP2_TD2/TP2_explications.pdf", "TP2 : ColorImage, PPM, rééchantillonnage"),
    "tp3": ("TP3_TD3/TP3_explications.pdf", "TP3 : JPEG avec libjpeg"),
    "tp4": ("TP4/TP4_explications.pdf", "TP4 : Targa (TGA) et RLE"),
    "tp5": ("TP5/TP5_explications.pdf", "TP5 : Bresenham"),
}

MOTS_CLES = (r"\b(?:class|struct|public|private|const|static|inline|void|return|if|else|"
             r"for|while|new|delete|throw|try|catch|template|typename|friend|operator|"
             r"true|false|nullptr|sizeof|unsigned|int|char|double|bool|size_t|auto|"
             r"extern|reinterpret_cast|static_assert|continue|break|this)\b")
TYPES = r"\b(?:u?int(?:8|16|32|64)_t|std::\w+|GrayImage|ColorImage|Color|FILE|J\w+|jpeg_\w+_struct)\b"


def colorer_cpp(code: str) -> str:
    """Coloration syntaxique minimale : commentaires, chaînes, directives, mots-clés."""
    jetons = re.compile(r'(//[^\n]*|/\*.*?\*/)|("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])\')|(^\s*#\w+[^\n]*)',
                        re.S | re.M)
    sortie, pos = [], 0
    for m in jetons.finditer(code):
        sortie.append(colorer_mots(code[pos:m.start()]))
        texte = html.escape(m.group(0), quote=False)
        classe = "com" if m.group(1) else ("str" if m.group(2) else "pp")
        sortie.append(f'<span class="{classe}">{texte}</span>')
        pos = m.end()
    sortie.append(colorer_mots(code[pos:]))
    return "".join(sortie)


def colorer_mots(t: str) -> str:
    t = html.escape(t, quote=False)
    motif = re.compile(f"({TYPES})|({MOTS_CLES})")  # un seul passage : pas de span dans un span
    return motif.sub(lambda m: f'<span class="{"ty" if m.group(1) else "kw"}">{m.group(0)}</span>', t)


def construire(nom: str) -> None:
    pdf, titre = DOCS[nom]
    with open(os.path.join(ICI, nom + ".html"), encoding="utf-8") as f:
        source = f.read()
    source = re.sub(r'<pre class="cpp( petit)?">\n?(.*?)</pre>',
                    lambda m: f'<pre class="cpp{m.group(1) or ""}">' + colorer_cpp(html.unescape(m.group(2).rstrip())) + "</pre>",
                    source, flags=re.S)
    source = source.replace("file://IMG/", f"file://{ICI}/img/")
    n = len(re.findall(r'<section class="slide', source))
    compteur = iter(range(1, n + 1))
    pied = ('<footer><span>R3.L01 — fiche de révision (d\'après le cours d\'E. Remy)</span>'
            '<span>{titre}</span><span>{i} / {n}</span></footer></section>')
    source = re.sub(r"</section>", lambda m: pied.format(titre=titre, i=next(compteur), n=n), source)
    page = ('<!doctype html><html lang="fr"><head><meta charset="utf-8">'
            f'<title>{titre}</title><link rel="stylesheet" href="file://{ICI}/style.css">'
            f'</head><body>{source}</body></html>')
    verifier_debordements(nom, page)
    with tempfile.NamedTemporaryFile("w", suffix=".html", dir=ICI, delete=False, encoding="utf-8") as tmp:
        tmp.write(page)
    sortie = os.path.join(RACINE, pdf)
    try:
        subprocess.run(["chromium", "--headless", "--no-sandbox", "--disable-gpu",
                        "--no-pdf-header-footer", "--virtual-time-budget=2000",
                        f"--print-to-pdf={sortie}", "file://" + tmp.name],
                       check=True, capture_output=True)
    finally:
        os.unlink(tmp.name)
    print(f"{sortie} ({n} pages)")


VERIF_JS = """<script>window.addEventListener('load', () => {
  const r = [];
  document.querySelectorAll('.slide').forEach((s, i) => {
    if (s.scrollHeight > s.clientHeight + 1) r.push('page ' + (i + 1) + ' : trop haute de ' + (s.scrollHeight - s.clientHeight) + ' px');
    s.querySelectorAll('pre, table, svg, img, p, li, .cols > *').forEach(e => {
      if (e.scrollWidth > e.clientWidth + 1 && e.clientWidth > 0)
        r.push('page ' + (i + 1) + ' : trop large (' + e.tagName + ') ' + (e.textContent || '').trim().slice(0, 50).replace(/\\s+/g, ' '));
    });
  });
  const d = document.createElement('pre'); d.id = 'rapport'; d.textContent = r.join('\\n'); document.body.appendChild(d);
});</script>"""


def verifier_debordements(nom: str, page: str) -> None:
    """Affiche les pages dont le contenu déborde (texte coupé ou caché par le pied de page)."""
    with tempfile.NamedTemporaryFile("w", suffix=".html", dir=ICI, delete=False, encoding="utf-8") as tmp:
        tmp.write(page.replace("</body>", VERIF_JS + "</body>"))
    try:
        dom = subprocess.run(["chromium", "--headless", "--no-sandbox", "--disable-gpu",
                              "--window-size=605,340", "--virtual-time-budget=2000", "--dump-dom",
                              "file://" + tmp.name], check=True, capture_output=True, text=True).stdout
    finally:
        os.unlink(tmp.name)
    m = re.search(r'<pre id="rapport">(.*?)</pre>', dom, re.S)
    if m and m.group(1).strip():
        print(f"[{nom}] débordements :\n" + html.unescape(m.group(1)))


if __name__ == "__main__":
    for nom in (sys.argv[1:] or DOCS):
        construire(nom)
