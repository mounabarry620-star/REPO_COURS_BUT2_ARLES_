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
// Classe ColorImage : Image couleur TrueColor 24 bits
// Enrichie pour le TP4 avec le format TrueVision Targa (TGA)
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
  static ColorImage *readPPM(std::istream &is);

  // =========================================================================
  // NOUVEAUTÉ TP4 : Format TrueVision Targa (TGA)
  // =========================================================================
  // Écriture au format TGA : brut (rle = false) ou compressé RLE (rle = true)
  void writeTGA(std::ostream &f, bool rle = true) const;

  // Lecture au format TGA : supporte type 2 (RGB brut), type 1 (Palette), type 10 (RGB RLE)
  static ColorImage *readTGA(std::istream &f);
};

#endif // COLORIMAGE_HPP
