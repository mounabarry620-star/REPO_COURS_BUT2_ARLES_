#include "ColorImage.hpp"
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

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

  for (uint16_t i = 0; i < w; ++i) {
    pixel(x + i, y) = color;
    pixel(x + i, y + h - 1) = color;
  }
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
// Helpers pour la lecture PPM
// =============================================================================
static void skip_line(std::istream &is) {
  char c;
  while (is.get(c) && c != '\n') {
  }
}

static void skip_comments(std::istream &is) {
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

// =============================================================================
// E/S Format PPM (P6 et P3)
// =============================================================================
void ColorImage::writePPM(std::ostream &os) const {
  os << "P6\n# TP5 Bresenham - Eric Remy\n"
     << width << " " << height << "\n255\n";
  os.write(reinterpret_cast<const char *>(array), width * height * 3);
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
    char sep;
    is.get(sep);
    is.read(reinterpret_cast<char *>(res->array), w * h * 3);
    if (!is) {
      delete res;
      throw std::runtime_error("Erreur lecture donnees binaires PPM");
    }
  } else {
    for (size_t i = 0; i < size_t(w * h); ++i) {
      int r, g, b;
      if (!(is >> r >> g >> b)) {
        delete res;
        throw std::runtime_error("Erreur lecture pixels P3");
      }
      res->array[i] = Color(static_cast<uint8_t>(r), static_cast<uint8_t>(g),
                            static_cast<uint8_t>(b));
    }
  }

  return res;
}

// =============================================================================
// TP5 - Algorithme de Bresenham
// =============================================================================

// 1. Premier octant : 0 <= (y2 - y1) <= (x2 - x1)
void ColorImage::lineOctant1(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2,
                             const Color pixel_value) {
  const int c2 = 2 * (y2 - y1);
  const int c1 = c2 - 2 * (x2 - x1);
  int critere = c2 - (x2 - x1);

  uint16_t x = x1;
  uint16_t y = y1;

  while (x <= x2) {
    if (x < width && y < height) {
      pixel(x, y) = pixel_value;
    }
    if (critere >= 0) {
      y++;
      critere += c1;
    } else {
      critere += c2;
    }
    x++;
  }
}

// 2. Deux premiers octants : 0 <= x1 <= x2 et 0 <= y1 <= y2
void ColorImage::lineOctant1Et2(uint16_t x1, uint16_t y1, uint16_t x2,
                                uint16_t y2, const Color pixel_value) {
  uint16_t x = x1;
  uint16_t y = y1;
  int longX = x2 - x1;
  int longY = y2 - y1;

  if (longY < longX) {
    // 1er Octant (pente entre 0 et 1)
    const int c1 = 2 * (longY - longX);
    const int c2 = 2 * longY;
    int critere = c2 - longX;

    while (x <= x2) {
      if (x < width && y < height) {
        pixel(x, y) = pixel_value;
      }
      if (critere >= 0) {
        y++;
        critere += c1;
      } else {
        critere += c2;
      }
      x++;
    }
  } else {
    // 2ème Octant (pente >= 1) : inversion des rôles de x et y
    const int c1 = 2 * (longX - longY);
    const int c2 = 2 * longX;
    int critere = c2 - longY;

    while (y <= y2) {
      if (x < width && y < height) {
        pixel(x, y) = pixel_value;
      }
      if (critere >= 0) {
        x++;
        critere += c1;
      } else {
        critere += c2;
      }
      y++;
    }
  }
}

// 3. Algorithme généralisé aux 8 octants du plan
void ColorImage::line(int16_t x1, int16_t y1, int16_t x2, int16_t y2,
                      const Color pixel_value) {
  int incX = (x2 >= x1) ? 1 : -1;
  int incY = (y2 >= y1) ? 1 : -1;
  int longX = std::abs(x2 - x1);
  int longY = std::abs(y2 - y1);

  int16_t x = x1;
  int16_t y = y1;

  if (longY <= longX) {
    // Déplacement prépondérant selon l'axe X (Octants 1, 4, 5, 8)
    const int c1 = 2 * (longY - longX);
    const int c2 = 2 * longY;
    int critere = c2 - longX;

    for (int count = 0; count <= longX; ++count) {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        pixel(x, y) = pixel_value;
      }
      if (critere >= 0) {
        y += incY;
        critere += c1;
      } else {
        critere += c2;
      }
      x += incX;
    }
  } else {
    // Déplacement prépondérant selon l'axe Y (Octants 2, 3, 6, 7)
    const int c1 = 2 * (longX - longY);
    const int c2 = 2 * longX;
    int critere = c2 - longY;

    for (int count = 0; count <= longY; ++count) {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        pixel(x, y) = pixel_value;
      }
      if (critere >= 0) {
        x += incX;
        critere += c1;
      } else {
        critere += c2;
      }
      y += incY;
    }
  }
}
