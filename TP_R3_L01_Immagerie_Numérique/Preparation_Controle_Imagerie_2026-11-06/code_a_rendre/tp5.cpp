// TP5 : tracé de segments discrets (Bresenham entier)
#include "Image.hpp"
#include <cmath>
#include <fstream>
#include <iostream>

static void ecrire(const ColorImage& im, const char* nom)
{
  std::ofstream ofs(nom, std::ios::binary);
  im.writePPM(ofs);
  std::cout << nom << " écrit" << std::endl;
}

int main()
{
  try {
    const Color rouge(255, 0, 0), vert(0, 255, 0), bleu(0, 0, 255), blanc(255, 255, 255), noir;

    // 1. Premier octant : de (0,0) vers le bord droit, tous les 10 pixels.
    ColorImage im1(400, 400);
    im1.clear(rouge);
    for (uint16_t y = 0; y < 400; y += 10)
      im1.line(0, 0, 399, y, vert);
    ecrire(im1, "tp5_octant1.ppm");

    // 2. Octants 1 et 2 : on ajoute les segments vers le bord bas.
    ColorImage im2(400, 400);
    im2.clear(rouge);
    for (uint16_t i = 0; i < 400; i += 10) {
      im2.line(0, 0, 399, i, vert); // 1er octant
      im2.line(0, 0, i, 399, vert); // 2e octant
    }
    ecrire(im2, "tp5_octants12.ppm");

    // 3. Les 8 octants : du centre (250,250) vers le cercle de rayon 200, tous les 5 degrés.
    ColorImage im3(500, 500);
    im3.clear(noir);
    for (int degres = 0; degres < 360; degres += 5) {
      double angle = degres * M_PI / 180.0; // cos et sin attendent des radians !
      uint16_t x = uint16_t(std::lround(250 + 200 * std::cos(angle)));
      uint16_t y = uint16_t(std::lround(250 + 200 * std::sin(angle)));
      im3.line(250, 250, x, y, bleu);
      im3.pixel(x, y) = blanc; // le point visé, en blanc comme sur la figure du sujet
    }
    ecrire(im3, "tp5_cercle.ppm");
  } catch (const std::exception& e) {
    std::cerr << "Erreur : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
