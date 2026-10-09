// R3.L01 - Représentations et codages des images : implantation (TP1 à TP5)
#include "Image.hpp"

#include <cstdio>  // FILE*, fopen, fclose (nécessaire AVANT jpeglib.h)
#include <string>
#include <vector>

extern "C" {
#include <jpeglib.h> /* Ce sont des déclarations relatives à des fonctions C ! */
}

// Nom écrit dans le commentaire des fichiers PGM/PPM (TD1 question 2, TD2 question 2).
static const char* const AUTEUR = "Mamadou Bailo BARRY";

// On écrit/lit le tableau de Color en un seul bloc (CM diapos 20-21) : cela
// suppose qu'une Color occupe exactement 3 octets, sans remplissage (CM diapo 14).
static_assert(sizeof(Color) == 3, "Color doit faire exactement 3 octets (r,g,b)");

// ===========================================================================
// TD1 : fonctions de lecture d'en-tête communes à PGM et PPM
// ===========================================================================

// Lit des caractères jusqu'au « Line Feed » (inclus).
void skip_line(std::istream& is)
{
  char c;
  while (is.get(c) && c != '\n') {}
}

// Lit un caractère : si c'est '#', on saute la ligne et on recommence ;
// sinon on le remet sur le flux avec putback() comme s'il n'avait jamais été lu.
void skip_comments(std::istream& is)
{
  char c;
  while (is.get(c) && c == '#')
    skip_line(is);
  if (is)
    is.putback(c);
}

// ===========================================================================
// GrayImage : constructeurs et destructeur (CM diapo 27)
// ===========================================================================

GrayImage::GrayImage(uint16_t w, uint16_t h) // Construction à partir des dimensions
  : width(w), height(h), array(nullptr)      // Liste d'initialisation
{
  if (w == 0 || h == 0)
    throw std::invalid_argument("GrayImage : largeur et hauteur doivent être > 0");
  array = new uint8_t[size_t(width) * height]; // size_t : pas de débordement de int
}

GrayImage::GrayImage(const GrayImage& o) // Construction de copie
  : width(o.width), height(o.height), array(nullptr)
{
  array = new uint8_t[size_t(width) * height];
  for (size_t t = 0; t < size_t(width) * height; t++)
    array[t] = o.array[t];
}

GrayImage::~GrayImage()
{ delete[] array; }

// ===========================================================================
// GrayImage : dessin (TP1)
// ===========================================================================

void GrayImage::clear(uint8_t gray)
{
  for (size_t t = 0; t < size_t(width) * height; t++)
    array[t] = gray;
}

// Cadre d'un pixel d'épaisseur : colonnes x à x+w-1, lignes y à y+h-1.
void GrayImage::rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray)
{
  if (w == 0 || h == 0)
    return; // Rien à dessiner.
  if (x + w > width || y + h > height) // x+w est calculé en int : pas de débordement
    throw std::out_of_range("GrayImage::rectangle : le rectangle sort de l'image");
  for (uint16_t i = 0; i < w; i++) {
    pixel(x + i, y)         = gray; // bord haut
    pixel(x + i, y + h - 1) = gray; // bord bas
  }
  for (uint16_t j = 0; j < h; j++) {
    pixel(x,         y + j) = gray; // bord gauche
    pixel(x + w - 1, y + j) = gray; // bord droit
  }
}

void GrayImage::fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray)
{
  if (w == 0 || h == 0)
    return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("GrayImage::fillRectangle : le rectangle sort de l'image");
  for (uint16_t j = 0; j < h; j++)
    for (uint16_t i = 0; i < w; i++)
      pixel(x + i, y + j) = gray;
}

// ===========================================================================
// GrayImage : format PGM (TD1)
// ===========================================================================

void GrayImage::writePGM(std::ostream& os) const
{
  // En-tête en texte ASCII (opérateur <<)...
  os << "P5\n"
     << "# Image sauvegardée par " << AUTEUR << " pour les TP de RepCod.\n"
     << width << " " << height << "\n"
     << 255 << "\n";
  // ... puis les pixels en binaire, d'un seul bloc (CM diapo 20).
  os.write((const char*)array, size_t(width) * height);
  if (!os)
    throw std::runtime_error("writePGM : erreur d'écriture");
}

GrayImage* GrayImage::readPGM(std::istream& is)
{
  std::string magic;
  is >> magic;             // Lit "P5" (s'arrête au blanc qui suit).
  if (magic != "P5" && magic != "P2")
    throw std::runtime_error("readPGM : ce n'est pas un fichier PGM (P5 ou P2 attendu)");

  is >> std::ws;           // Saute les blancs (LF, CR, espaces...) jusqu'à la ligne suivante,
  skip_comments(is);       // puis les éventuelles lignes de commentaires.
  unsigned int w = 0, h = 0;
  if (!(is >> w >> h))
    throw std::runtime_error("readPGM : largeur et hauteur illisibles");
  if (w == 0 || h == 0 || w > 65535 || h > 65535)
    throw std::runtime_error("readPGM : dimensions invalides");
  is >> std::ws;           // >> s'arrête AVANT le '\n' : sans cette ligne, skip_comments
  skip_comments(is);       // lirait ce '\n' et ne verrait pas les commentaires de chat.pgm.
  unsigned int maxval = 0;
  if (!(is >> maxval))
    throw std::runtime_error("readPGM : valeur maximale illisible");
  if (maxval != 255)
    throw std::runtime_error("readPGM : seule la valeur maximale 255 est gérée");

  GrayImage* res = new GrayImage(uint16_t(w), uint16_t(h));
  if (magic == "P5") {
    is.get(); // UN SEUL caractère blanc après 255, puis les octets des pixels.
    is.read((char*)res->array, size_t(w) * h);
  } else { // "P2" (bonus) : les pixels sont écrits en décimal, séparés par des blancs.
    for (size_t t = 0; t < size_t(w) * h && is; t++) {
      unsigned int v = 0;
      if (is >> v && v > 255)
        is.setstate(std::ios::failbit);
      res->array[t] = uint8_t(v);
    }
  }
  if (!is) { // Fichier tronqué ou corrompu : on libère l'image avant de signaler l'erreur.
    delete res;
    throw std::runtime_error("readPGM : données des pixels incomplètes ou invalides");
  }
  return res;
}

// ===========================================================================
// GrayImage : rééchantillonnage (TD3)
// ===========================================================================

// Plus proche voisin : pour chaque pixel (x',y') de l'image d'arrivée I',
// on recopie le pixel (x,y) = (x'.width/w , y'.height/h) de l'image de départ.
GrayImage* GrayImage::simpleScale(uint16_t w, uint16_t h) const
{
  GrayImage* res = new GrayImage(w, h);
  for (uint16_t y_prime = 0; y_prime < h; y_prime++) {
    uint16_t y = uint16_t(uint32_t(y_prime) * height / h); // uint32_t : pas de débordement
    for (uint16_t x_prime = 0; x_prime < w; x_prime++) {
      uint16_t x = uint16_t(uint32_t(x_prime) * width / w);
      res->pixel(x_prime, y_prime) = pixel(x, y);
    }
  }
  return res;
}

// Calcule la position réelle dans l'image de départ (taille src) du centre du
// pixel p de l'image d'arrivée (taille dst), en tenant compte du demi-pixel :
// -0,5 / +0,5 avant et après le changement de repère (sujet du TP2).
// Renvoie la colonne (ou ligne) de gauche p0, celle de droite p1 et la proportion a.
static void bilinear_coord(uint16_t p, uint16_t dst, uint16_t src,
                           uint16_t& p0, uint16_t& p1, double& a)
{
  double s = (p + 0.5) * src / dst - 0.5;
  if (s < 0)       s = 0;       // Bords : on reste dans l'image de départ.
  if (s > src - 1) s = src - 1;
  p0 = uint16_t(s);
  p1 = (p0 + 1 < src) ? uint16_t(p0 + 1) : p0;
  a  = s - p0; // Dans [0;1[ : 0 -> tout p0, presque 1 -> presque tout p1.
}

GrayImage* GrayImage::bilinearScale(uint16_t w, uint16_t h) const
{
  GrayImage* res = new GrayImage(w, h);
  for (uint16_t y_prime = 0; y_prime < h; y_prime++) {
    uint16_t y0, y1; double ay;
    bilinear_coord(y_prime, h, height, y0, y1, ay);
    for (uint16_t x_prime = 0; x_prime < w; x_prime++) {
      uint16_t x0, x1; double ax;
      bilinear_coord(x_prime, w, width, x0, x1, ax);
      double haut = (1 - ax) * pixel(x0, y0) + ax * pixel(x1, y0); // ligne y0
      double bas  = (1 - ax) * pixel(x0, y1) + ax * pixel(x1, y1); // ligne y1
      double v    = (1 - ay) * haut + ay * bas;
      res->pixel(x_prime, y_prime) = uint8_t(v + 0.5); // Arrondi au plus proche
    }
  }
  return res;
}

// ===========================================================================
// Color : opérateurs (CM diapo 38)
// ===========================================================================

bool operator==(const Color& c1, const Color& c2)
{ return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b; }

bool operator!=(const Color& c1, const Color& c2)
{ return !(c1 == c2); }

// Ramène un réel dans [0;255] puis l'arrondit à l'entier le plus proche.
static uint8_t to_byte(double v)
{
  if (v <= 0)   return 0;
  if (v >= 255) return 255;
  return uint8_t(v + 0.5);
}

Color operator*(double alpha, const Color& color)
{ return Color(to_byte(alpha * color.r), to_byte(alpha * color.g), to_byte(alpha * color.b)); }

// Addition « saturée » : 200 + 100 donne 255 et non 44 (débordement d'un uint8_t).
Color operator+(const Color& c1, const Color& c2)
{ return Color(to_byte(c1.r + c2.r), to_byte(c1.g + c2.g), to_byte(c1.b + c2.b)); }

// ===========================================================================
// ColorImage : constructeurs, destructeur et dessin (même code que GrayImage)
// ===========================================================================

ColorImage::ColorImage(uint16_t w, uint16_t h)
  : width(w), height(h), array(nullptr)
{
  if (w == 0 || h == 0)
    throw std::invalid_argument("ColorImage : largeur et hauteur doivent être > 0");
  array = new Color[size_t(width) * height];
}

ColorImage::ColorImage(const ColorImage& o)
  : width(o.width), height(o.height), array(nullptr)
{
  array = new Color[size_t(width) * height];
  for (size_t t = 0; t < size_t(width) * height; t++)
    array[t] = o.array[t];
}

ColorImage::~ColorImage()
{ delete[] array; }

void ColorImage::clear(Color color)
{
  for (size_t t = 0; t < size_t(width) * height; t++)
    array[t] = color;
}

void ColorImage::rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, Color color)
{
  if (w == 0 || h == 0)
    return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("ColorImage::rectangle : le rectangle sort de l'image");
  for (uint16_t i = 0; i < w; i++) {
    pixel(x + i, y)         = color;
    pixel(x + i, y + h - 1) = color;
  }
  for (uint16_t j = 0; j < h; j++) {
    pixel(x,         y + j) = color;
    pixel(x + w - 1, y + j) = color;
  }
}

void ColorImage::fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, Color color)
{
  if (w == 0 || h == 0)
    return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("ColorImage::fillRectangle : le rectangle sort de l'image");
  for (uint16_t j = 0; j < h; j++)
    for (uint16_t i = 0; i < w; i++)
      pixel(x + i, y + j) = color;
}

// ===========================================================================
// ColorImage : format PPM (TD2 exercice 1, TP2)
// ===========================================================================

void ColorImage::writePPM(std::ostream& os) const
{
  os << "P6\n"
     << "# Image sauvegardée par " << AUTEUR << " pour les TP de RepCod.\n"
     << width << " " << height << "\n"
     << 255 << "\n";
  // 3 octets par pixel, dans l'ordre r, g, b : c'est exactement l'ordre en mémoire.
  os.write((const char*)array, size_t(width) * height * 3);
  if (!os)
    throw std::runtime_error("writePPM : erreur d'écriture");
}

ColorImage* ColorImage::readPPM(std::istream& is)
{
  std::string magic;
  is >> magic;
  if (magic != "P6" && magic != "P3")
    throw std::runtime_error("readPPM : ce n'est pas un fichier PPM (P6 ou P3 attendu)");

  is >> std::ws;
  skip_comments(is);
  unsigned int w = 0, h = 0;
  if (!(is >> w >> h))
    throw std::runtime_error("readPPM : largeur et hauteur illisibles");
  if (w == 0 || h == 0 || w > 65535 || h > 65535)
    throw std::runtime_error("readPPM : dimensions invalides");
  is >> std::ws;
  skip_comments(is);
  unsigned int maxval = 0;
  if (!(is >> maxval))
    throw std::runtime_error("readPPM : valeur maximale illisible");
  if (maxval != 255)
    throw std::runtime_error("readPPM : seule la valeur maximale 255 est gérée");

  ColorImage* res = new ColorImage(uint16_t(w), uint16_t(h));
  if (magic == "P6") {
    is.get(); // Un seul caractère blanc après 255.
    is.read((char*)res->array, size_t(w) * h * 3);
  } else { // "P3" (bonus) : 3 valeurs décimales (r g b) par pixel.
    for (size_t t = 0; t < size_t(w) * h && is; t++) {
      unsigned int r = 0, g = 0, b = 0;
      if (is >> r >> g >> b && (r > 255 || g > 255 || b > 255))
        is.setstate(std::ios::failbit);
      res->array[t] = Color(uint8_t(r), uint8_t(g), uint8_t(b));
    }
  }
  if (!is) {
    delete res;
    throw std::runtime_error("readPPM : données des pixels incomplètes ou invalides");
  }
  return res;
}

// ===========================================================================
// ColorImage : rééchantillonnage (TD3, TP2)
// ===========================================================================

ColorImage* ColorImage::simpleScale(uint16_t w, uint16_t h) const
{
  ColorImage* res = new ColorImage(w, h);
  for (uint16_t y_prime = 0; y_prime < h; y_prime++) {
    uint16_t y = uint16_t(uint32_t(y_prime) * height / h);
    for (uint16_t x_prime = 0; x_prime < w; x_prime++) {
      uint16_t x = uint16_t(uint32_t(x_prime) * width / w);
      res->pixel(x_prime, y_prime) = pixel(x, y);
    }
  }
  return res;
}

// Même formule que pour GrayImage : c'est pour cela que Color a besoin de
// « double * Color » et de « Color + Color ».
ColorImage* ColorImage::bilinearScale(uint16_t w, uint16_t h) const
{
  ColorImage* res = new ColorImage(w, h);
  for (uint16_t y_prime = 0; y_prime < h; y_prime++) {
    uint16_t y0, y1; double ay;
    bilinear_coord(y_prime, h, height, y0, y1, ay);
    for (uint16_t x_prime = 0; x_prime < w; x_prime++) {
      uint16_t x0, x1; double ax;
      bilinear_coord(x_prime, w, width, x0, x1, ax);
      Color haut = (1 - ax) * pixel(x0, y0) + ax * pixel(x1, y0);
      Color bas  = (1 - ax) * pixel(x0, y1) + ax * pixel(x1, y1);
      res->pixel(x_prime, y_prime) = (1 - ay) * haut + ay * bas;
    }
  }
  return res;
}

// ===========================================================================
// ColorImage : format JPEG avec libjpeg (TP3)
// ===========================================================================

// Par défaut, libjpeg affiche l'erreur puis appelle exit() : le programme
// s'arrête net. On remplace ce comportement par une exception C++ (sujet du TP3).
static void jpeg_error_to_exception(j_common_ptr cinfo)
{
  char message[JMSG_LENGTH_MAX];
  (*cinfo->err->format_message)(cinfo, message);
  throw std::runtime_error(std::string("libjpeg : ") + message);
}

void ColorImage::writeJPEG(const char* fname, unsigned int quality) const
{
  if (quality > 100)
    throw std::invalid_argument("writeJPEG : la qualité doit être dans [0;100]");
  FILE* outfile = std::fopen(fname, "wb"); // "b" : fichier binaire !
  if (outfile == nullptr)
    throw std::runtime_error(std::string("writeJPEG : impossible de créer ") + fname);

  // 1. Allocation et initialisation de l'objet de compression
  jpeg_compress_struct cinfo;
  jpeg_error_mgr       jerr;
  cinfo.err = jpeg_std_error(&jerr);
  jerr.error_exit = jpeg_error_to_exception;
  jpeg_create_compress(&cinfo);
  try {
    // 2. Destination des données compressées
    jpeg_stdio_dest(&cinfo, outfile);
    // 3. Description de l'image source et paramètres de compression
    cinfo.image_width      = width;
    cinfo.image_height     = height;
    cinfo.input_components = 3;       // r, g, b
    cinfo.in_color_space   = JCS_RGB;
    jpeg_set_defaults(&cinfo);        // Après in_color_space !
    jpeg_set_quality(&cinfo, int(quality), TRUE);
    // 4. Compression, une ligne (scanline) à la fois, de haut en bas
    jpeg_start_compress(&cinfo, TRUE);
    while (cinfo.next_scanline < cinfo.image_height) {
      JSAMPROW row_pointer[1]; // Pointeur vers une ligne de 3*width octets
      row_pointer[0] = (JSAMPROW)(array + size_t(cinfo.next_scanline) * width);
      jpeg_write_scanlines(&cinfo, row_pointer, 1);
    }
    // 5. Fin de la compression
    jpeg_finish_compress(&cinfo);
  } catch (...) { // Erreur libjpeg : on libère tout puis on relance l'exception.
    jpeg_destroy_compress(&cinfo);
    std::fclose(outfile);
    throw;
  }
  // 6. Libération de l'objet de compression et fermeture du fichier
  jpeg_destroy_compress(&cinfo);
  std::fclose(outfile);
}

ColorImage* ColorImage::readJPEG(const char* fname)
{
  FILE* infile = std::fopen(fname, "rb");
  if (infile == nullptr)
    throw std::runtime_error(std::string("readJPEG : impossible d'ouvrir ") + fname);

  jpeg_decompress_struct cinfo;
  jpeg_error_mgr         jerr;
  cinfo.err = jpeg_std_error(&jerr);
  jerr.error_exit = jpeg_error_to_exception;
  jpeg_create_decompress(&cinfo);
  ColorImage* res = nullptr;
  try {
    jpeg_stdio_src(&cinfo, infile);
    jpeg_read_header(&cinfo, TRUE);
    cinfo.out_color_space = JCS_RGB; // On veut toujours du r, g, b en sortie.
    jpeg_start_decompress(&cinfo);
    if (cinfo.output_width > 65535 || cinfo.output_height > 65535)
      throw std::runtime_error("readJPEG : image trop grande pour notre classe");
    res = new ColorImage(uint16_t(cinfo.output_width), uint16_t(cinfo.output_height));
    while (cinfo.output_scanline < cinfo.output_height) {
      JSAMPROW row_pointer[1];
      row_pointer[0] = (JSAMPROW)(res->array + size_t(cinfo.output_scanline) * res->width);
      jpeg_read_scanlines(&cinfo, row_pointer, 1);
    }
    jpeg_finish_decompress(&cinfo);
  } catch (...) {
    delete res;
    jpeg_destroy_decompress(&cinfo);
    std::fclose(infile);
    throw;
  }
  jpeg_destroy_decompress(&cinfo);
  std::fclose(infile);
  return res;
}

// ===========================================================================
// ColorImage : format Targa / TGA (TP4)
// ===========================================================================
// Rappels (tga.pdf) : en-tête de 18 octets, entiers 16 bits en little endian
// (« lo-hi »), pixels 24 bits stockés dans l'ordre BLEU, VERT, ROUGE.

// Écrit un entier 16 bits en little endian, quel que soit le processeur (TD2 ex. 2).
static void write_uint16_le(std::ostream& os, uint16_t v)
{
  os.put(char(v & 0xFF)); // octet de poids faible d'abord
  os.put(char(v >> 8));   // puis octet de poids fort
}

// Relit un entier 16 bits little endian à partir de deux octets.
static uint16_t read_uint16_le(const uint8_t* p)
{ return uint16_t(p[0] | (p[1] << 8)); }

static void write_bgr(std::ostream& os, const Color& c)
{
  os.put(char(c.b));
  os.put(char(c.g));
  os.put(char(c.r));
}

void ColorImage::writeTGA(std::ostream& os, bool rle) const
{
  // --- En-tête de 18 octets ---
  os.put(0);                    // 0 : pas de champ d'identification
  os.put(0);                    // 1 : pas de palette
  os.put(char(rle ? 10 : 2));   // 2 : sous-format 10 (RGB + RLE) ou 2 (RGB brut)
  write_uint16_le(os, 0);       // 3-4 : origine de la palette (inutilisé)
  write_uint16_le(os, 0);       // 5-6 : longueur de la palette (inutilisé)
  os.put(0);                    // 7 : taille d'une entrée de palette (inutilisé)
  write_uint16_le(os, 0);       // 8-9 : X origine
  write_uint16_le(os, 0);       // 10-11 : Y origine
  write_uint16_le(os, width);   // 12-13 : largeur
  write_uint16_le(os, height);  // 14-15 : hauteur
  os.put(24);                   // 16 : 24 bits par pixel
  os.put(0x20);                 // 17 : bit 5 à 1 = première ligne écrite = ligne du HAUT

  // --- Pixels, ligne par ligne de haut en bas ---
  for (uint16_t y = 0; y < height; y++) {
    if (!rle) {
      for (uint16_t x = 0; x < width; x++)
        write_bgr(os, pixel(x, y));
      continue;
    }
    // RLE : les paquets ne débordent pas d'une ligne sur la suivante.
    uint16_t x = 0;
    while (x < width) {
      // Combien de pixels identiques à pixel(x,y) à partir de x ? (au plus 128)
      uint16_t run = 1;
      while (x + run < width && run < 128 && pixel(x + run, y) == pixel(x, y))
        run++;
      if (run >= 2) {
        // Paquet répété : bit 7 à 1, puis (nombre - 1) sur 7 bits, puis UNE couleur.
        os.put(char(0x80 | (run - 1)));
        write_bgr(os, pixel(x, y));
        x += run;
      } else {
        // Paquet brut : on prend les pixels tant qu'une répétition ne commence pas.
        uint16_t n = 1;
        while (x + n < width && n < 128 &&
               !(x + n + 1 < width && pixel(x + n, y) == pixel(x + n + 1, y)))
          n++;
        // Bit 7 à 0, puis (nombre - 1) sur 7 bits, puis les n couleurs.
        os.put(char(n - 1));
        for (uint16_t k = 0; k < n; k++)
          write_bgr(os, pixel(x + k, y));
        x += n;
      }
    }
  }
  if (!os)
    throw std::runtime_error("writeTGA : erreur d'écriture");
}

// Lit la couleur d'un pixel : 3 octets b,g,r (sous-formats 2 et 10)
// ou 1 octet d'indice dans la palette (sous-format 1).
static Color read_tga_color(std::istream& is, bool indexed,
                            const std::vector<Color>& palette, uint16_t origin)
{
  if (indexed) {
    int index = is.get();
    if (index == EOF)
      throw std::runtime_error("readTGA : fichier tronqué");
    if (index < origin || size_t(index - origin) >= palette.size())
      throw std::runtime_error("readTGA : indice de palette invalide");
    return palette[index - origin];
  }
  uint8_t bgr[3];
  if (!is.read((char*)bgr, 3))
    throw std::runtime_error("readTGA : fichier tronqué");
  return Color(bgr[2], bgr[1], bgr[0]);
}

// Le n-ième pixel lu dans le fichier va en (n % w, ligne n / w), sachant que
// la première ligne du fichier est celle du bas si le bit 5 du descripteur est à 0.
static void store_tga_pixel(ColorImage& im, size_t n, bool topToBottom, const Color& c)
{
  uint16_t x   = uint16_t(n % im.getWidth());
  uint16_t row = uint16_t(n / im.getWidth());
  uint16_t y   = topToBottom ? row : uint16_t(im.getHeight() - 1 - row);
  im.pixel(x, y) = c;
}

ColorImage* ColorImage::readTGA(std::istream& is)
{
  uint8_t header[18];
  if (!is.read((char*)header, 18))
    throw std::runtime_error("readTGA : en-tête incomplet");

  const uint8_t  idLength   = header[0];
  const uint8_t  cmapType   = header[1];
  const uint8_t  imageType  = header[2];
  const uint16_t cmapOrigin = read_uint16_le(header + 3);
  const uint16_t cmapLength = read_uint16_le(header + 5);
  const uint8_t  cmapBits   = header[7];
  const uint16_t w          = read_uint16_le(header + 12);
  const uint16_t h          = read_uint16_le(header + 14);
  const uint8_t  pixelBits  = header[16];
  const uint8_t  descriptor = header[17];

  // Tous les cas que l'on ne sait pas traiter lèvent une exception (sujet du TP4).
  if (imageType != 1 && imageType != 2 && imageType != 10)
    throw std::runtime_error("readTGA : sous-format non géré (seuls 1, 2 et 10 le sont)");
  if (imageType == 1 && (cmapType != 1 || pixelBits != 8))
    throw std::runtime_error("readTGA : sous-format 1 attendu avec palette et indices 8 bits");
  if (imageType != 1 && pixelBits != 24)
    throw std::runtime_error("readTGA : seules les couleurs 24 bits sont gérées");
  if (cmapType > 1 || (cmapType == 1 && cmapBits != 24))
    throw std::runtime_error("readTGA : seules les palettes 24 bits sont gérées");
  if (descriptor & 0x10) // bit 4 : pixels de droite à gauche
    throw std::runtime_error("readTGA : ordre de droite à gauche non géré");
  if (descriptor & 0xC0) // bits 7-6 : entrelacement
    throw std::runtime_error("readTGA : images entrelacées non gérées");
  if (w == 0 || h == 0)
    throw std::runtime_error("readTGA : dimensions nulles");

  is.ignore(idLength); // Champ d'identification : on le saute.

  // Palette : cmapLength entrées de 3 octets b,g,r. Pour le sous-format 2,
  // une palette éventuelle est simplement lue puis ignorée.
  std::vector<Color> palette;
  for (uint16_t i = 0; cmapType == 1 && i < cmapLength; i++)
    palette.push_back(read_tga_color(is, false, palette, 0));

  const bool   indexed     = (imageType == 1);
  const bool   topToBottom = (descriptor & 0x20) != 0; // bit 5
  const size_t total       = size_t(w) * h;
  ColorImage*  res         = new ColorImage(w, h);
  try {
    size_t n = 0;
    if (imageType == 10) { // Données découpées en paquets RLE
      while (n < total) {
        int packet = is.get();
        if (packet == EOF)
          throw std::runtime_error("readTGA : fichier tronqué");
        size_t count = (packet & 0x7F) + 1; // 7 bits de poids faible + 1
        if (n + count > total)
          throw std::runtime_error("readTGA : paquet RLE qui dépasse de l'image");
        if (packet & 0x80) { // bit 7 à 1 : une couleur répétée count fois
          Color c = read_tga_color(is, false, palette, 0);
          for (size_t k = 0; k < count; k++)
            store_tga_pixel(*res, n++, topToBottom, c);
        } else {             // bit 7 à 0 : count couleurs différentes
          for (size_t k = 0; k < count; k++)
            store_tga_pixel(*res, n++, topToBottom, read_tga_color(is, false, palette, 0));
        }
      }
    } else { // Sous-formats 1 et 2 : pixels non compressés
      for (n = 0; n < total; n++)
        store_tga_pixel(*res, n, topToBottom, read_tga_color(is, indexed, palette, cmapOrigin));
    }
  } catch (...) {
    delete res;
    throw;
  }
  return res;
}

// ===========================================================================
// ColorImage : tracé de segment, algorithme de Bresenham entier (TP5)
// ===========================================================================
// Version généralisée aux 8 octants : on avance de incX = +1 ou -1 en x et de
// incY = +1 ou -1 en y ; longX et longY restent positives ; la boucle compte
// les points au lieu de comparer x à x2.
void ColorImage::line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, const Color pixel_value)
{
  if (x1 >= width || x2 >= width || y1 >= height || y2 >= height)
    throw std::out_of_range("ColorImage::line : une extrémité est hors de l'image");

  int x = x1, y = y1;   // int : x peut décroître, et uint16_t ne sait pas faire -1.
  int longX = x2 - x1;
  int longY = y2 - y1;
  const int incX = (longX >= 0) ? 1 : -1;
  const int incY = (longY >= 0) ? 1 : -1;
  if (longX < 0) longX = -longX;
  if (longY < 0) longY = -longY;

  if (longY < longX) { // Octants « plutôt horizontaux » : un point par colonne
    const int c1 = 2 * (longY - longX);
    const int c2 = 2 * longY;
    int critere  = c2 - longX;
    for (int i = 0; i <= longX; i++) {
      pixel(uint16_t(x), uint16_t(y)) = pixel_value;
      if (critere >= 0) { // changement de ligne horizontale
        y += incY;
        critere += c1;
      } else              // toujours la même ligne horizontale
        critere += c2;
      x += incX;
    }
  } else {             // Octants « plutôt verticaux » : un point par ligne
    const int c1 = 2 * (longX - longY);
    const int c2 = 2 * longX;
    int critere  = c2 - longY;
    for (int i = 0; i <= longY; i++) {
      pixel(uint16_t(x), uint16_t(y)) = pixel_value;
      if (critere >= 0) { // changement de colonne
        x += incX;
        critere += c1;
      } else
        critere += c2;
      y += incY;
    }
  }
}

// ===========================================================================
// GrayImage : JPEG et TGA en niveaux de gris (annoncés par le sujet du TP1)
// ===========================================================================
// Même code qu'en couleur, avec 1 composante (JCS_GRAYSCALE) au lieu de 3.

void GrayImage::writeJPEG(const char* fname, unsigned int quality) const
{
  if (quality > 100)
    throw std::invalid_argument("writeJPEG : la qualité doit être dans [0;100]");
  FILE* outfile = std::fopen(fname, "wb");
  if (outfile == nullptr)
    throw std::runtime_error(std::string("writeJPEG : impossible de créer ") + fname);
  jpeg_compress_struct cinfo;
  jpeg_error_mgr       jerr;
  cinfo.err = jpeg_std_error(&jerr);
  jerr.error_exit = jpeg_error_to_exception;
  jpeg_create_compress(&cinfo);
  try {
    jpeg_stdio_dest(&cinfo, outfile);
    cinfo.image_width      = width;
    cinfo.image_height     = height;
    cinfo.input_components = 1;             // un seul octet par pixel
    cinfo.in_color_space   = JCS_GRAYSCALE;
    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, int(quality), TRUE);
    jpeg_start_compress(&cinfo, TRUE);
    while (cinfo.next_scanline < cinfo.image_height) {
      JSAMPROW row_pointer[1];
      row_pointer[0] = (JSAMPROW)(array + size_t(cinfo.next_scanline) * width);
      jpeg_write_scanlines(&cinfo, row_pointer, 1);
    }
    jpeg_finish_compress(&cinfo);
  } catch (...) {
    jpeg_destroy_compress(&cinfo);
    std::fclose(outfile);
    throw;
  }
  jpeg_destroy_compress(&cinfo);
  std::fclose(outfile);
}

GrayImage* GrayImage::readJPEG(const char* fname)
{
  FILE* infile = std::fopen(fname, "rb");
  if (infile == nullptr)
    throw std::runtime_error(std::string("readJPEG : impossible d'ouvrir ") + fname);
  jpeg_decompress_struct cinfo;
  jpeg_error_mgr         jerr;
  cinfo.err = jpeg_std_error(&jerr);
  jerr.error_exit = jpeg_error_to_exception;
  jpeg_create_decompress(&cinfo);
  GrayImage* res = nullptr;
  try {
    jpeg_stdio_src(&cinfo, infile);
    jpeg_read_header(&cinfo, TRUE);
    cinfo.out_color_space = JCS_GRAYSCALE; // un JPEG couleur est converti en gris
    jpeg_start_decompress(&cinfo);
    if (cinfo.output_width > 65535 || cinfo.output_height > 65535)
      throw std::runtime_error("readJPEG : image trop grande pour notre classe");
    res = new GrayImage(uint16_t(cinfo.output_width), uint16_t(cinfo.output_height));
    while (cinfo.output_scanline < cinfo.output_height) {
      JSAMPROW row_pointer[1];
      row_pointer[0] = (JSAMPROW)(res->array + size_t(cinfo.output_scanline) * res->width);
      jpeg_read_scanlines(&cinfo, row_pointer, 1);
    }
    jpeg_finish_decompress(&cinfo);
  } catch (...) {
    delete res;
    jpeg_destroy_decompress(&cinfo);
    std::fclose(infile);
    throw;
  }
  jpeg_destroy_decompress(&cinfo);
  std::fclose(infile);
  return res;
}

// TGA en niveaux de gris : sous-format 3 (non compressé) ou 11 (RLE), 8 bits par
// pixel, sans palette. Les paquets RLE ont la même forme qu'en couleur, mais
// chaque « couleur » ne fait qu'un octet.
void GrayImage::writeTGA(std::ostream& os, bool rle) const
{
  os.put(0);                   // 0 : pas de champ d'identification
  os.put(0);                   // 1 : pas de palette
  os.put(char(rle ? 11 : 3));  // 2 : sous-format 11 (gris + RLE) ou 3 (gris brut)
  write_uint16_le(os, 0);      // 3-4 : origine de la palette (inutilisé)
  write_uint16_le(os, 0);      // 5-6 : longueur de la palette (inutilisé)
  os.put(0);                   // 7 : taille d'une entrée de palette (inutilisé)
  write_uint16_le(os, 0);      // 8-9 : X origine
  write_uint16_le(os, 0);      // 10-11 : Y origine
  write_uint16_le(os, width);  // 12-13 : largeur
  write_uint16_le(os, height); // 14-15 : hauteur
  os.put(8);                   // 16 : 8 bits par pixel
  os.put(0x20);                // 17 : bit 5 à 1 = ligne du HAUT d'abord

  for (uint16_t y = 0; y < height; y++) {
    if (!rle) {
      os.write((const char*)(array + size_t(y) * width), width); // 1 octet par pixel
      continue;
    }
    uint16_t x = 0;
    while (x < width) {
      uint16_t run = 1;
      while (x + run < width && run < 128 && pixel(x + run, y) == pixel(x, y))
        run++;
      if (run >= 2) {
        os.put(char(0x80 | (run - 1)));
        os.put(char(pixel(x, y)));
        x += run;
      } else {
        uint16_t n = 1;
        while (x + n < width && n < 128 &&
               !(x + n + 1 < width && pixel(x + n, y) == pixel(x + n + 1, y)))
          n++;
        os.put(char(n - 1));
        os.write((const char*)(array + size_t(y) * width + x), n);
        x += n;
      }
    }
  }
  if (!os)
    throw std::runtime_error("writeTGA : erreur d'écriture");
}

GrayImage* GrayImage::readTGA(std::istream& is)
{
  uint8_t header[18];
  if (!is.read((char*)header, 18))
    throw std::runtime_error("readTGA : en-tête incomplet");
  const uint8_t  idLength   = header[0];
  const uint8_t  cmapType   = header[1];
  const uint8_t  imageType  = header[2];
  const uint16_t cmapLength = read_uint16_le(header + 5);
  const uint8_t  cmapBits   = header[7];
  const uint16_t w          = read_uint16_le(header + 12);
  const uint16_t h          = read_uint16_le(header + 14);
  const uint8_t  pixelBits  = header[16];
  const uint8_t  descriptor = header[17];

  if (imageType != 3 && imageType != 11)
    throw std::runtime_error("readTGA (gris) : sous-format non géré (seuls 3 et 11 le sont)");
  if (pixelBits != 8)
    throw std::runtime_error("readTGA (gris) : seuls les gris sur 8 bits sont gérés");
  if (descriptor & 0x10)
    throw std::runtime_error("readTGA : ordre de droite à gauche non géré");
  if (descriptor & 0xC0)
    throw std::runtime_error("readTGA : images entrelacées non gérées");
  if (w == 0 || h == 0)
    throw std::runtime_error("readTGA : dimensions nulles");

  is.ignore(idLength);
  if (cmapType == 1) // Palette inutile pour du gris : on la saute.
    is.ignore(std::streamsize(cmapLength) * ((cmapBits + 7) / 8));

  const bool   topToBottom = (descriptor & 0x20) != 0;
  const size_t total       = size_t(w) * h;
  GrayImage*   res         = new GrayImage(w, h);
  try {
    size_t n = 0;
    while (n < total) {
      size_t count = total - n; // sous-format 3 : tout le reste, d'un coup
      bool repete = false;
      if (imageType == 11) {
        int packet = is.get();
        if (packet == EOF)
          throw std::runtime_error("readTGA : fichier tronqué");
        count  = (packet & 0x7F) + 1;
        repete = (packet & 0x80) != 0;
        if (n + count > total)
          throw std::runtime_error("readTGA : paquet RLE qui dépasse de l'image");
      }
      int gris = 0;
      for (size_t k = 0; k < count; k++, n++) {
        if (!repete || k == 0) {
          gris = is.get();
          if (gris == EOF)
            throw std::runtime_error("readTGA : fichier tronqué");
        }
        uint16_t x   = uint16_t(n % w);
        uint16_t row = uint16_t(n / w);
        res->pixel(x, topToBottom ? row : uint16_t(h - 1 - row)) = uint8_t(gris);
      }
    }
  } catch (...) {
    delete res;
    throw;
  }
  return res;
}
