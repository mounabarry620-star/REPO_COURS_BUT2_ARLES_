#include "ColorImage.hpp"

// =============================================================================
// Constructeurs et Destructeur
// =============================================================================
ColorImage::ColorImage(uint16_t w, uint16_t h)
    : width(w), height(h), array(nullptr) {
  if (w == 0 || h == 0)
    throw std::invalid_argument(
        "Les dimensions doivent etre strictement positives");
  array = new Color[width * height];
}

ColorImage::ColorImage(const ColorImage &orig)
    : width(orig.width), height(orig.height), array(nullptr) {
  array = new Color[orig.width * orig.height];
  for (size_t i = 0; i < size_t(width * height); ++i) {
    array[i] = orig.array[i];
  }
}

ColorImage::~ColorImage() { delete[] array; }

// =============================================================================
// Méthodes élémentaires de dessin
// =============================================================================
void ColorImage::clear(Color color) {
  for (size_t i = 0; i < size_t(width * height); ++i) {
    array[i] = color;
  }
}

void ColorImage::rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                           Color color) {
  if (w == 0 || h == 0)
    return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("Rectangle hors limites");

  // Lignes horizontales supérieure et inférieure
  for (uint16_t i = 0; i < w; ++i) {
    pixel(x + i, y) = color;
    pixel(x + i, y + h - 1) = color;
  }
  // Lignes verticales gauche et droite
  for (uint16_t j = 0; j < h; ++j) {
    pixel(x, y + j) = color;
    pixel(x + w - 1, y + j) = color;
  }
}

void ColorImage::fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                               Color color) {
  if (w == 0 || h == 0)
    return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("Rectangle plein hors limites");

  for (uint16_t j = 0; j < h; ++j) {
    for (uint16_t i = 0; i < w; ++i) {
      pixel(x + i, y + j) = color;
    }
  }
}

// =============================================================================
// Entrées / Sorties au format PPM (P6 binaire et P3 texte ASCII)
// =============================================================================
void ColorImage::writePPM(std::ostream &os) const {
  os << "P6\n# Image sauvegardee pour les TP de RepCod.\n"
     << width << " " << height << "\n255\n";
  // Écriture directe des pixels (3 octets consécutifs par Color en mémoire)
  os.write(reinterpret_cast<const char *>(array), width * height * 3);
}

void ColorImage::skip_line(std::istream &is) {
  char c;
  while (is.get(c) && c != '\n') {
  }
}

void ColorImage::skip_comments(std::istream &is) {
  char c;
  while (is.get(c)) {
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r')
      continue;
    if (c == '#') {
      skip_line(is);
    } else {
      is.putback(c);
      break;
    }
  }
}

ColorImage *ColorImage::readPPM(std::istream &is) {
  std::string magic = "";
  if (!(is >> magic))
    throw std::runtime_error("Impossible de lire le magic number PPM");

  if (magic != "P6" && magic != "P3")
    throw std::runtime_error("Format non supporte (P6 ou P3 attendu) : " +
                             magic);

  skip_comments(is);
  uint16_t w = 0, h = 0;
  if (!(is >> w >> h))
    throw std::runtime_error("Dimensions d'image invalides ou absentes");

  skip_comments(is);
  int maxval = 0;
  if (!(is >> maxval) || maxval != 255)
    throw std::runtime_error("Dynamique non supportee (255 attendu)");

  ColorImage *res = new ColorImage(w, h);

  if (magic == "P6") {
    // La norme Netpbm stipule strictement un caractere blanc apres maxval
    char sep;
    is.get(sep);
    is.read(reinterpret_cast<char *>(res->array), w * h * 3);
    if (!is) {
      delete res;
      throw std::runtime_error(
          "Erreur lors de la lecture des donnees binaires PPM");
    }
  } else {
    // Format P3 ASCII (Bonus)
    for (size_t i = 0; i < size_t(w * h); ++i) {
      int r, g, b;
      if (!(is >> r >> g >> b)) {
        delete res;
        throw std::runtime_error("Erreur de lecture des pixels ASCII P3");
      }
      res->array[i] = Color(static_cast<uint8_t>(r), static_cast<uint8_t>(g),
                            static_cast<uint8_t>(b));
    }
  }

  return res;
}

// =============================================================================
// Rééchantillonnage Simpliste (Plus Proche Voisin)
// =============================================================================
ColorImage *ColorImage::simpleScale(uint16_t w, uint16_t h) const {
  if (w == 0 || h == 0)
    throw std::invalid_argument(
        "Les dimensions de redimensionnement doivent etre > 0");

  ColorImage *res = new ColorImage(w, h);

  // Règle d'or : On parcourt TOUJOURS la grille de destination (x', y')
  for (uint16_t y_prime = 0; y_prime < h; ++y_prime) {
    // Cast en uint32_t pour eviter le debordement 16 bits (65535)
    uint16_t y = static_cast<uint16_t>((uint32_t(y_prime) * height) / h);
    for (uint16_t x_prime = 0; x_prime < w; ++x_prime) {
      uint16_t x = static_cast<uint16_t>((uint32_t(x_prime) * width) / w);
      res->pixel(x_prime, y_prime) = pixel(x, y);
    }
  }

  return res;
}

// =============================================================================
// Rééchantillonnage Bilinéaire
// =============================================================================
ColorImage *ColorImage::bilinearScale(uint16_t w, uint16_t h) const {
  if (w == 0 || h == 0)
    throw std::invalid_argument(
        "Les dimensions de redimensionnement doivent etre > 0");

  ColorImage *res = new ColorImage(w, h);

  for (uint16_t y_prime = 0; y_prime < h; ++y_prime) {
    // Coordonnée réelle continue dans l'image source
    double y = (static_cast<double>(y_prime) * height) / h;
    uint16_t y0 = static_cast<uint16_t>(y);
    // Clamping aux bords pour empêcher tout débordement mémoire out_of_range
    uint16_t y1 = (y0 + 1 < height) ? y0 + 1 : y0;
    double dy = y - y0;

    for (uint16_t x_prime = 0; x_prime < w; ++x_prime) {
      double x = (static_cast<double>(x_prime) * width) / w;
      uint16_t x0 = static_cast<uint16_t>(x);
      uint16_t x1 = (x0 + 1 < width) ? x0 + 1 : x0;
      double dx = x - x0;

      // Récupération des 4 pixels voisins
      const Color &c00 = pixel(x0, y0);
      const Color &c10 = pixel(x1, y0);
      const Color &c01 = pixel(x0, y1);
      const Color &c11 = pixel(x1, y1);

      // Interpolations horizontales
      Color c_top = (1.0 - dx) * c00 + dx * c10;
      Color c_bot = (1.0 - dx) * c01 + dx * c11;

      // Interpolation verticale finale
      res->pixel(x_prime, y_prime) = (1.0 - dy) * c_top + dy * c_bot;
    }
  }

  return res;
}
