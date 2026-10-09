#ifndef COLORIMAGE_HPP
#define COLORIMAGE_HPP

#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <string>

// =============================================================================
// Classe Color : Modèle RGB 24 bits (Slide 38 du cours R3.L01 de M. Rémy)
// =============================================================================
class Color {
public:
  uint8_t r, g, b;

  inline Color(uint8_t _r = 0, uint8_t _g = 0, uint8_t _b = 0)
      : r(_r), g(_g), b(_b) {}

  friend bool operator==(const Color &c1, const Color &c2) {
    return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b;
  }

  friend Color operator*(double alpha, const Color &c) {
    return Color(static_cast<uint8_t>(alpha * c.r),
                 static_cast<uint8_t>(alpha * c.g),
                 static_cast<uint8_t>(alpha * c.b));
  }

  friend Color operator+(const Color &c1, const Color &c2) {
    return Color(c1.r + c2.r, c1.g + c2.g, c1.b + c2.b);
  }
};

// =============================================================================
// Classe ColorImage : Image couleur TrueColor 24 bits (Slide 39 du cours)
// Enrichie pour le TP3 avec le support de libjpeg (writeJPEG & readJPEG)
// =============================================================================
class ColorImage {
private:
  const uint16_t width, height;
  Color *array;

  ColorImage() = delete;

public:
  ColorImage &operator=(const ColorImage &b) = delete;
  ColorImage(uint16_t w, uint16_t h);
  ColorImage(const ColorImage &orig);
  ~ColorImage();

  inline const uint16_t &getWidth() const { return width; }
  inline const uint16_t &getHeight() const { return height; }

  inline Color &pixel(uint16_t x, uint16_t y) {
    if (x >= width || y >= height)
      throw std::out_of_range("Pixel hors limites de l'image");
    return array[y * width + x];
  }

  inline const Color &pixel(uint16_t x, uint16_t y) const {
    if (x >= width || y >= height)
      throw std::out_of_range("Pixel hors limites de l'image");
    return array[y * width + x];
  }

  void clear(Color color = Color());
  void rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, Color color);
  void fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                     Color color);

  // E/S Format PPM
  void writePPM(std::ostream &os) const;
  static void skip_line(std::istream &is);
  static void skip_comments(std::istream &is);
  static ColorImage *readPPM(std::istream &is);

  // Echantillonnages spatiaux (TP2)
  ColorImage *simpleScale(uint16_t w, uint16_t h) const;
  ColorImage *bilinearScale(uint16_t w, uint16_t h) const;

  // =========================================================================
  // NOUVEAUTÉ TP3 : Support du format JPEG avec libjpeg
  // =========================================================================
  // Écriture au format JPEG avec réglage de la qualité (75% par défaut)
  void writeJPEG(const char *fname, unsigned int quality = 75) const;

  // Lecture d'une image au format JPEG (Décompression)
  static ColorImage *readJPEG(const char *fname);
};

#endif // COLORIMAGE_HPP
