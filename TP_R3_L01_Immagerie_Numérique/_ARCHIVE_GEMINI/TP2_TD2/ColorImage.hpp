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

  // Constructeur avec noir par défaut (0, 0, 0)
  inline Color(uint8_t _r = 0, uint8_t _g = 0, uint8_t _b = 0)
      : r(_r), g(_g), b(_b) {}

  // Opérateur d'égalité (Slide 38)
  friend bool operator==(const Color &c1, const Color &c2) {
    return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b;
  }

  // Multiplication par un réel (nécessaire pour l'interpolation bilinéaire)
  friend Color operator*(double alpha, const Color &c) {
    return Color(static_cast<uint8_t>(alpha * c.r),
                 static_cast<uint8_t>(alpha * c.g),
                 static_cast<uint8_t>(alpha * c.b));
  }

  // Addition de deux couleurs (nécessaire pour l'interpolation bilinéaire)
  friend Color operator+(const Color &c1, const Color &c2) {
    return Color(c1.r + c2.r, c1.g + c2.g, c1.b + c2.b);
  }
};

// =============================================================================
// Classe ColorImage : Image couleur TrueColor 24 bits (Slide 39 du cours)
// =============================================================================
class ColorImage {
private:
  const uint16_t width, height;
  Color *array;

  // Empêcher la construction par défaut
  ColorImage() = delete;

public:
  // Empêcher l'affectation par copie
  ColorImage &operator=(const ColorImage &b) = delete;

  // Constructeur avec dimensions
  ColorImage(uint16_t w, uint16_t h);

  // Constructeur de recopie profonde
  ColorImage(const ColorImage &orig);

  // Destructeur
  ~ColorImage();

  // Accesseurs de dimensions
  inline const uint16_t &getWidth() const { return width; }
  inline const uint16_t &getHeight() const { return height; }

  // Accesseur pixel avec contrôle de bornes (lecture/écriture)
  inline Color &pixel(uint16_t x, uint16_t y) {
    if (x >= width || y >= height)
      throw std::out_of_range("Pixel hors limites de l'image");
    return array[y * width + x];
  }

  // Accesseur pixel constant (lecture seule)
  inline const Color &pixel(uint16_t x, uint16_t y) const {
    if (x >= width || y >= height)
      throw std::out_of_range("Pixel hors limites de l'image");
    return array[y * width + x];
  }

  // Effacement de l'image (couleur noire par défaut)
  void clear(Color color = Color());

  // Tracé d'un cadre rectangulaire d'épaisseur 1
  void rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, Color color);

  // Tracé d'un rectangle plein
  void fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                     Color color);

  // Écriture au format PPM binaire (P6)
  void writePPM(std::ostream &os) const;

  // Méthodes utilitaires de parsing PPM
  static void skip_line(std::istream &is);
  static void skip_comments(std::istream &is);

  // Lecture d'image PPM (supporte P6 binaire et P3 ASCII)
  static ColorImage *readPPM(std::istream &is);

  // Rééchantillonnage simpliste (Plus Proche Voisin)
  ColorImage *simpleScale(uint16_t w, uint16_t h) const;

  // Rééchantillonnage bilinéaire
  ColorImage *bilinearScale(uint16_t w, uint16_t h) const;
};

#endif // COLORIMAGE_HPP
