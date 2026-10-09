// R3.L01 - Représentations et codages des images
// Classes GrayImage, Color et ColorImage (TP1 à TP5), dans un seul couple
// de fichiers Image.hpp / Image.cpp comme demandé par le sujet du TP2.
#ifndef IMAGE_HPP
#define IMAGE_HPP

#include <cstdint>   // uint8_t, uint16_t, ... (CM diapo 12)
#include <iostream>  // std::istream, std::ostream
#include <stdexcept> // std::runtime_error, std::out_of_range, ...

// Fonctions de lecture d'en-tête communes à PGM et PPM (TD1, questions 3 et 4).
void skip_line(std::istream& is);     // Lit jusqu'au « Line Feed » inclus.
void skip_comments(std::istream& is); // Saute 0, 1 ou plusieurs lignes « # ... ».

// ===========================================================================
// GrayImage : image en niveaux de gris, 1 octet par pixel (CM diapos 26 à 28)
// ===========================================================================
class GrayImage { // N'oubliez pas <cstdint> !
  const uint16_t width, height; // Largeur et hauteur de l'image dans [0;65535].
         uint8_t  *array;       // Tableau « à plat » des pixels, alloué dynamiquement.
                                // Chaque pixel peut varier dans [0;255].
  GrayImage() = delete;         // Construction sans paramètre interdite ! (C++11)
public:
  GrayImage& operator=(const GrayImage& b) = delete; // Affectation interdite !
  GrayImage(uint16_t w, uint16_t h);                 // Construction à la dimension w x h
  GrayImage(const GrayImage& orig);                  // Construction par copie
  ~GrayImage();                                      // Destructeur

  // Consultation de la largeur ou de la hauteur
  inline const uint16_t& getWidth()  const { return width;  }
  inline const uint16_t& getHeight() const { return height; }

  // Consultation ou modification d'un pixel (x,y) : t = y * width + x (CM diapo 25).
  inline uint8_t& pixel(uint16_t x, uint16_t y) {
    if (x >= width || y >= height) throw std::out_of_range("GrayImage::pixel : hors de l'image");
    return array[y * width + x];
  }
  inline const uint8_t& pixel(uint16_t x, uint16_t y) const {
    if (x >= width || y >= height) throw std::out_of_range("GrayImage::pixel : hors de l'image");
    return array[y * width + x];
  }

  // TP1 : dessin
  void clear(uint8_t gray = 0);
  void rectangle    (uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray);
  void fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray);

  // TP1 / TD1 : format PGM (P5, et P2 en lecture pour le bonus)
  void writePGM(std::ostream& os) const;
  static GrayImage* readPGM(std::istream& is);

  // TP2 / TD3 : rééchantillonnage
  GrayImage* simpleScale  (uint16_t w, uint16_t h) const;
  GrayImage* bilinearScale(uint16_t w, uint16_t h) const;

  // Autres formats annoncés par le sujet du TP1 (« writeFormat » avec PGM, TGA, JPEG) :
  // même travail qu'en couleur (TP3, TP4), avec 1 octet par pixel.
  void writeJPEG(const char* fname, unsigned int quality = 75) const;
  static GrayImage* readJPEG(const char* fname);
  void writeTGA(std::ostream& os, bool rle = true) const; // sous-format 3, ou 11 en RLE
  static GrayImage* readTGA(std::istream& is);            // sous-formats 3 et 11
};

// ===========================================================================
// Color : une couleur RGB sur 3 x 8 bits = « TrueColor 24 bits » (CM diapo 38)
// ===========================================================================
class Color {
public:
  uint8_t r, g, b; // Gardez « public » ces trois données dans votre classe.
  inline Color(uint8_t _r = 0, uint8_t _g = 0, uint8_t _b = 0)
    : r(_r), g(_g), b(_b)
  {}
  friend bool  operator==(const Color& c1, const Color& c2);
  friend bool  operator!=(const Color& c1, const Color& c2);
  friend Color operator* (double alpha, const Color& color); // Pour le bilinéaire
  friend Color operator+ (const Color& c1, const Color& c2); // Pour le bilinéaire
};

// ===========================================================================
// ColorImage : même principe que GrayImage avec Color à la place de uint8_t
// ===========================================================================
class ColorImage {
  const uint16_t width, height;
         Color    *array;
  ColorImage() = delete;
public:
  ColorImage& operator=(const ColorImage& b) = delete;
  ColorImage(uint16_t w, uint16_t h);
  ColorImage(const ColorImage& orig);
  ~ColorImage();

  inline const uint16_t& getWidth()  const { return width;  }
  inline const uint16_t& getHeight() const { return height; }

  inline Color& pixel(uint16_t x, uint16_t y) {
    if (x >= width || y >= height) throw std::out_of_range("ColorImage::pixel : hors de l'image");
    return array[y * width + x];
  }
  inline const Color& pixel(uint16_t x, uint16_t y) const {
    if (x >= width || y >= height) throw std::out_of_range("ColorImage::pixel : hors de l'image");
    return array[y * width + x];
  }

  // TP2 : dessin
  void clear(Color color = Color());
  void rectangle    (uint16_t x, uint16_t y, uint16_t w, uint16_t h, Color color);
  void fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, Color color);

  // TP2 / TD2 : format PPM (P6, et P3 en lecture pour le bonus)
  void writePPM(std::ostream& os) const;
  static ColorImage* readPPM(std::istream& is);

  // TP2 / TD3 : rééchantillonnage
  ColorImage* simpleScale  (uint16_t w, uint16_t h) const;
  ColorImage* bilinearScale(uint16_t w, uint16_t h) const;

  // TP3 : format JPEG avec la bibliothèque libjpeg (édition de liens avec -ljpeg)
  void writeJPEG(const char* fname, unsigned int quality = 75) const;
  static ColorImage* readJPEG(const char* fname); // Bonus

  // TP4 : format Targa (TGA). Écriture : sous-format 2 (rle=false) ou 10 (rle=true).
  // Lecture : sous-formats 1 (palette), 2 (RGB) et 10 (RGB + RLE).
  void writeTGA(std::ostream& os, bool rle = true) const;
  static ColorImage* readTGA(std::istream& is);

  // TP5 : tracé de segment par l'algorithme de Bresenham entier (8 octants)
  void line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, const Color pixel_value);
};

#endif // IMAGE_HPP
