#include "ColorImage.hpp"
#include <vector>

// =============================================================================
// Constructeurs et Destructeur
// =============================================================================
ColorImage::ColorImage(uint16_t w, uint16_t h)
    : width(w), height(h), array(nullptr) {
  if (w == 0 || h == 0)
    throw std::invalid_argument("Dimensions strictement positives requises");
  array = new Color[width * height];
}

ColorImage::ColorImage(const ColorImage &orig)
    : width(orig.width), height(orig.height), array(nullptr) {
  array = new Color[orig.width * orig.height];
  for (size_t i = 0; i < size_t(width * height); ++i) {
    array[i] = orig.array[i];
  }
}

ColorImage::~ColorImage() {
  delete[] array;
}

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
  if (w == 0 || h == 0) return;
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
  if (w == 0 || h == 0) return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("Rectangle plein hors limites");

  for (uint16_t j = 0; j < h; ++j) {
    for (uint16_t i = 0; i < w; ++i) {
      pixel(x + i, y + j) = color;
    }
  }
}

// =============================================================================
// E/S Format PPM
// =============================================================================
void ColorImage::writePPM(std::ostream &os) const {
  os << "P6\n# Image sauvegardee pour RepCod.\n"
     << width << " " << height << "\n255\n";
  os.write(reinterpret_cast<const char *>(array), width * height * 3);
}

ColorImage *ColorImage::readPPM(std::istream &is) {
  std::string magic = "";
  if (!(is >> magic) || (magic != "P6" && magic != "P3"))
    throw std::runtime_error("Format non supporte");

  char c;
  while (is.get(c)) {
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r') continue;
    if (c == '#') { while (is.get(c) && c != '\n') {} }
    else { is.putback(c); break; }
  }

  uint16_t w = 0, h = 0;
  is >> w >> h;
  while (is.get(c)) {
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r') continue;
    if (c == '#') { while (is.get(c) && c != '\n') {} }
    else { is.putback(c); break; }
  }
  int maxval = 0;
  is >> maxval;
  char sep;
  is.get(sep);

  ColorImage *res = new ColorImage(w, h);
  if (magic == "P6") {
    is.read(reinterpret_cast<char *>(res->array), w * h * 3);
  } else {
    for (size_t i = 0; i < size_t(w * h); ++i) {
      int r, g, b;
      is >> r >> g >> b;
      res->array[i] = Color(r, g, b);
    }
  }
  return res;
}

// =============================================================================
// NOUVEAUTÉ TP4 : Écriture TGA (Sous-format 2 non-compressé ou 10 RLE)
// =============================================================================
void ColorImage::writeTGA(std::ostream &f, bool rle) const {
  uint8_t header[18] = {0};

  header[2] = rle ? 10 : 2; // Type 2 = RGB brut, Type 10 = RGB RLE
  // Dimensions en Little-Endian (2 octets)
  header[12] = static_cast<uint8_t>(width & 0xFF);
  header[13] = static_cast<uint8_t>((width >> 8) & 0xFF);
  header[14] = static_cast<uint8_t>(height & 0xFF);
  header[15] = static_cast<uint8_t>((height >> 8) & 0xFF);
  header[16] = 24;   // 24 bits par pixel
  header[17] = 0x20; // Bit 5 = 1 -> Origine en haut à gauche (Top-Left)

  f.write(reinterpret_cast<const char *>(header), 18);

  if (!rle) {
    // Écriture brute : TGA stocke en BGR (Bleu, Vert, Rouge) !
    for (uint16_t y = 0; y < height; ++y) {
      for (uint16_t x = 0; x < width; ++x) {
        const Color &c = pixel(x, y);
        uint8_t bgr[3] = {c.b, c.g, c.r};
        f.write(reinterpret_cast<const char *>(bgr), 3);
      }
    }
  } else {
    // Écriture compressée RLE (Type 10) par ligne
    for (uint16_t y = 0; y < height; ++y) {
      uint16_t x = 0;
      while (x < width) {
        // Détecter un run de pixels identiques
        uint16_t run_len = 1;
        while (x + run_len < width && run_len < 128 &&
               pixel(x + run_len, y) == pixel(x, y)) {
          ++run_len;
        }

        if (run_len > 1) {
          // Paquet RLE : bit 7 à 1, suivi du count-1
          uint8_t pkt = 0x80 | (run_len - 1);
          f.put(static_cast<char>(pkt));
          const Color &c = pixel(x, y);
          uint8_t bgr[3] = {c.b, c.g, c.r};
          f.write(reinterpret_cast<const char *>(bgr), 3);
          x += run_len;
        } else {
          // Paquet Raw : chercher les pixels non répétitifs
          uint16_t raw_len = 1;
          while (x + raw_len < width && raw_len < 128) {
            // Si on rencontre une répétition de 2 pixels identiques, on s'arrête
            if (x + raw_len + 1 < width &&
                pixel(x + raw_len, y) == pixel(x + raw_len + 1, y)) {
              break;
            }
            ++raw_len;
          }

          uint8_t pkt = (raw_len - 1);
          f.put(static_cast<char>(pkt));
          for (uint16_t i = 0; i < raw_len; ++i) {
            const Color &c = pixel(x + i, y);
            uint8_t bgr[3] = {c.b, c.g, c.r};
            f.write(reinterpret_cast<const char *>(bgr), 3);
          }
          x += raw_len;
        }
      }
    }
  }
}

// =============================================================================
// NOUVEAUTÉ TP4 : Lecture TGA (Sous-formats 1 Palette, 2 RGB brut, 10 RLE)
// =============================================================================
ColorImage *ColorImage::readTGA(std::istream &f) {
  uint8_t header[18];
  if (!f.read(reinterpret_cast<char *>(header), 18))
    throw std::runtime_error("En-tete TGA manquant ou corrompu");

  uint8_t id_length = header[0];
  uint8_t color_map_type = header[1];
  uint8_t image_type = header[2];

  uint16_t color_map_origin = header[3] | (header[4] << 8);
  uint16_t color_map_length = header[5] | (header[6] << 8);
  uint8_t color_map_depth = header[7];

  uint16_t w = header[12] | (header[13] << 8);
  uint16_t h = header[14] | (header[15] << 8);
  uint8_t bpp = header[16];
  uint8_t descriptor = header[17];

  // Ignorer l'ID de l'image s'il existe
  if (id_length > 0) {
    f.ignore(id_length);
  }

  // Vérification de la compatibilité demandée par l'énoncé
  if (image_type != 1 && image_type != 2 && image_type != 10)
    throw std::runtime_error("Sous-format TGA non supporte (types 1, 2 ou 10 attendus)");

  // Sens vertical : bit 5 = 1 => Top-to-Bottom, bit 5 = 0 => Bottom-to-Top
  bool top_to_bottom = (descriptor & 0x20) != 0;

  // Lecture de la Palette pour le type 1 (Color-Mapped)
  std::vector<Color> palette;
  if (image_type == 1) {
    if (color_map_type != 1)
      throw std::runtime_error("Image type 1 sans palette specifiee");
    if (color_map_depth != 24)
      throw std::runtime_error("Profondeur de palette non supportee (24 bits requis)");

    palette.resize(color_map_origin + color_map_length);
    for (uint16_t i = 0; i < color_map_length; ++i) {
      uint8_t b, g, r;
      f.get(reinterpret_cast<char &>(b));
      f.get(reinterpret_cast<char &>(g));
      f.get(reinterpret_cast<char &>(r));
      palette[color_map_origin + i] = Color(r, g, b);
    }
    if (bpp != 8)
      throw std::runtime_error("Indices de palette sur 8 bits attendus");
  } else {
    if (bpp != 24)
      throw std::runtime_error("Seules les images 24 bits RGB sont supportees");
  }

  ColorImage *res = new ColorImage(w, h);

  if (image_type == 2) {
    // -------------------------------------------------------------------------
    // Type 2 : RGB 24 bits non-compressé
    // -------------------------------------------------------------------------
    for (uint16_t y = 0; y < h; ++y) {
      uint16_t target_y = top_to_bottom ? y : (h - 1 - y);
      for (uint16_t x = 0; x < w; ++x) {
        uint8_t b, g, r;
        f.get(reinterpret_cast<char &>(b));
        f.get(reinterpret_cast<char &>(g));
        f.get(reinterpret_cast<char &>(r));
        res->pixel(x, target_y) = Color(r, g, b);
      }
    }
  } else if (image_type == 1) {
    // -------------------------------------------------------------------------
    // Type 1 : Palette 24 bits non-compressée (Indices 8 bits)
    // -------------------------------------------------------------------------
    for (uint16_t y = 0; y < h; ++y) {
      uint16_t target_y = top_to_bottom ? y : (h - 1 - y);
      for (uint16_t x = 0; x < w; ++x) {
        uint8_t index;
        f.get(reinterpret_cast<char &>(index));
        if (index >= palette.size())
          throw std::out_of_range("Index de palette hors limites");
        res->pixel(x, target_y) = palette[index];
      }
    }
  } else if (image_type == 10) {
    // -------------------------------------------------------------------------
    // Type 10 : RGB 24 bits compressé RLE
    // -------------------------------------------------------------------------
    size_t total_pixels = size_t(w) * size_t(h);
    size_t pixel_idx = 0;

    while (pixel_idx < total_pixels) {
      uint8_t packet_header;
      f.get(reinterpret_cast<char &>(packet_header));
      bool is_rle = (packet_header & 0x80) != 0;
      int count = (packet_header & 0x7F) + 1;

      if (is_rle) {
        // Paquet RLE : 1 pixel répété count fois
        uint8_t b, g, r;
        f.get(reinterpret_cast<char &>(b));
        f.get(reinterpret_cast<char &>(g));
        f.get(reinterpret_cast<char &>(r));
        Color c(r, g, b);

        for (int k = 0; k < count; ++k) {
          uint16_t cur_x = pixel_idx % w;
          uint16_t cur_y = pixel_idx / w;
          uint16_t target_y = top_to_bottom ? cur_y : (h - 1 - cur_y);
          res->pixel(cur_x, target_y) = c;
          ++pixel_idx;
        }
      } else {
        // Paquet Raw : count pixels différents
        for (int k = 0; k < count; ++k) {
          uint8_t b, g, r;
          f.get(reinterpret_cast<char &>(b));
          f.get(reinterpret_cast<char &>(g));
          f.get(reinterpret_cast<char &>(r));
          Color c(r, g, b);

          uint16_t cur_x = pixel_idx % w;
          uint16_t cur_y = pixel_idx / w;
          uint16_t target_y = top_to_bottom ? cur_y : (h - 1 - cur_y);
          res->pixel(cur_x, target_y) = c;
          ++pixel_idx;
        }
      }
    }
  }

  return res;
}
