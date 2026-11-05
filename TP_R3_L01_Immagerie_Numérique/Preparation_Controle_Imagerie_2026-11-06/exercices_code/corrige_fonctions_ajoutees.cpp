// Corrigé des exercices F1 et F2.
// Ce fichier n'est pas à rendre : les méthodes ne sont pas dans le sujet des 5 TP.
// Il n'ajoute rien à Image.hpp. Le corps est celui qu'on copierait dans la classe
// si le contrôle donnait ces prototypes. On passe par pixel(), getWidth(), getHeight().
//
// Compilation : voir 04_Commandes_compilation_et_tests.md

#include "Image.hpp"

#include <iostream>
#include <stdexcept>

static GrayImage* toGray(const ColorImage& src)
{
  GrayImage* res = new GrayImage(src.getWidth(), src.getHeight());
  for (uint16_t y = 0; y < src.getHeight(); y++) {
    for (uint16_t x = 0; x < src.getWidth(); x++) {
      const Color& c = src.pixel(x, y);
      // CM diapo 32 : Y = 0,299 R + 0,587 G + 0,114 B, valeurs dans [0;1]
      // ici R,G,B sont dans [0;255], donc Y aussi. Arrondi au plus proche.
      double yuv = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
      if (yuv < 0)   yuv = 0;
      if (yuv > 255) yuv = 255;
      res->pixel(x, y) = uint8_t(yuv + 0.5);
    }
  }
  return res;
}

static uint32_t countEqual(const GrayImage& src, uint8_t gray)
{
  uint32_t n = 0;
  for (uint16_t y = 0; y < src.getHeight(); y++)
    for (uint16_t x = 0; x < src.getWidth(); x++)
      if (src.pixel(x, y) == gray)
        n++;
  return n;
}

int main()
{
  try {
    // Exemple chiffré de la fiche de révision (CM) : (200,100,50) → 124,2 → 124.
    ColorImage une(1, 1);
    une.pixel(0, 0) = Color(200, 100, 50);
    GrayImage* g = toGray(une);
    unsigned int y = g->pixel(0, 0);
    std::cout << "Y(200,100,50) = " << y << std::endl;
    if (y != 124)
      throw std::runtime_error("la luminance du CM devrait valoir 124");
    delete g;

    GrayImage h(4, 1);
    h.clear(0);
    h.pixel(1, 0) = 10;
    h.pixel(3, 0) = 10;
    // Cast obligatoire : cout << uint8_t affiche un caractère (CM diapo 13).
    std::cout << "pixels égaux à 10 : " << (unsigned int)countEqual(h, 10) << std::endl;
    if (countEqual(h, 10) != 2)
      throw std::runtime_error("countEqual");
  } catch (const std::exception& e) {
    std::cerr << "ERREUR : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
