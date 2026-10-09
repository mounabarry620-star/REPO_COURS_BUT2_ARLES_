#include "ColorImage.hpp"
#include <cmath>
#include <fstream>
#include <iostream>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

int main() {
  std::cout << "============================================================"
            << std::endl;
  std::cout << "  TP5 : Trace de segments discrets (Algorithme de Bresenham)"
            << std::endl;
  std::cout << "  Auteur : BUT2 Informatique Arles - R3.L01 (M. Eric Remy)"
            << std::endl;
  std::cout << "============================================================"
            << std::endl;

  Color rouge(255, 0, 0);
  Color vert(0, 255, 0);
  Color bleu(0, 0, 255);
  Color blanc(255, 255, 255);
  Color noir(0, 0, 0);

  // =========================================================================
  // TEST 1 : Octant 1 (0 <= dy <= dx)
  // Fond rouge 400x400, lignes vertes depuis (0,0) vers le bord droit (399, y)
  // =========================================================================
  std::cout << "\n[1/3] Test 1 : Premier octant (lineOctant1)..." << std::endl;
  {
    ColorImage img1(400, 400);
    img1.clear(rouge);

    for (int y = 0; y < 400; y += 10) {
      img1.lineOctant1(0, 0, 399, y, vert);
    }

    std::ofstream ofs("tp5_test1.ppm", std::ios::binary);
    if (!ofs) {
      std::cerr << "Erreur d'ouverture de tp5_test1.ppm" << std::endl;
      return 1;
    }
    img1.writePPM(ofs);
    ofs.close();
    std::cout << "  -> Sauvegarde reussie : tp5_test1.ppm (400x400)"
              << std::endl;
  }

  // =========================================================================
  // TEST 2 : Octants 1 et 2 (lineOctant1Et2)
  // Fond rouge 400x400, bord droit (399, y) et bord bas (x, 399) tous les 10 px
  // =========================================================================
  std::cout << "\n[2/3] Test 2 : Octants 1 et 2 (lineOctant1Et2)..."
            << std::endl;
  {
    ColorImage img2(400, 400);
    img2.clear(rouge);

    // Bord droit : Octant 1 (pente dy/dx <= 1)
    for (int y = 0; y < 400; y += 10) {
      img2.lineOctant1Et2(0, 0, 399, y, vert);
    }

    // Bord bas : Octant 2 (pente dy/dx >= 1)
    for (int x = 0; x < 400; x += 10) {
      img2.lineOctant1Et2(0, 0, x, 399, vert);
    }

    std::ofstream ofs("tp5_test2.ppm", std::ios::binary);
    if (!ofs) {
      std::cerr << "Erreur d'ouverture de tp5_test2.ppm" << std::endl;
      return 1;
    }

    img2.writePPM(ofs);
    ofs.close();
    std::cout << "  -> Sauvegarde reussie : tp5_test2.ppm (400x400)"
              << std::endl;
  }

  // =========================================================================
  // TEST 3 : Generalisation aux 8 octants (line)
  // Fond noir 500x500, centre (250,250), cercle rayon 200, rayons bleus pas 5
  // deg Points d'extremite blancs
  // =========================================================================
  std::cout << "\n[3/3] Test 3 : Generalisation aux 8 octants (line)..."
            << std::endl;
  {
    ColorImage img3(500, 500);
    img3.clear(noir);

    const int16_t cx = 250;
    const int16_t cy = 250;
    const double rayon = 200.0;

    for (int deg = 0; deg < 360; deg += 5) {
      double rad = deg * M_PI / 180.0;
      int16_t x = static_cast<int16_t>(std::round(cx + rayon * std::cos(rad)));
      int16_t y = static_cast<int16_t>(std::round(cy + rayon * std::sin(rad)));

      // Tracé du rayon bleu depuis le centre vers le point du cercle
      img3.line(cx, cy, x, y, bleu);

      // Tracé du point d'extrémité en blanc
      if (x >= 0 && x < img3.getWidth() && y >= 0 && y < img3.getHeight()) {
        img3.pixel(x, y) = blanc;
      }
    }

    std::ofstream ofs("tp5_test3.ppm", std::ios::binary);
    if (!ofs) {
      std::cerr << "Erreur d'ouverture de tp5_test3.ppm" << std::endl;
      return 1;
    }
    img3.writePPM(ofs);
    ofs.close();
    std::cout << "  -> Sauvegarde reussie : tp5_test3.ppm (500x500)"
              << std::endl;
  }

  std::cout << "\n============================================================"
            << std::endl;
  std::cout << "  Tous les tests du TP5 ont ete executes avec succes !"
            << std::endl;
  std::cout << "============================================================"
            << std::endl;

  return 0;
}
