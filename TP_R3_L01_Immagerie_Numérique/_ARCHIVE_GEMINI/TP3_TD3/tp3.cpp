#include "ColorImage.hpp"
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>

int main() {
  try {
    std::cout << "=== R3.L01 - Execution du TP3 : Format JPEG & libjpeg (M. Remy) ==="
              << std::endl;

    // -------------------------------------------------------------------------
    // 1. Lecture de chat.ppm et tracé des rectangles colorés
    // -------------------------------------------------------------------------
    std::cout << "\n[1/3] Chargement de 'chat.ppm' et trace des cadres..." << std::endl;
    std::ifstream fIn("chat.ppm", std::ios::binary);
    if (!fIn)
      throw std::runtime_error("Impossible d'ouvrir 'chat.ppm'");

    ColorImage *im = ColorImage::readPPM(fIn);
    std::cout << "      Dimensions : " << im->getWidth() << "x"
              << im->getHeight() << std::endl;

    // Tracé de rectangles concentriques comme dans la figure du sujet
    im->rectangle(10, 10, im->getWidth() - 20, im->getHeight() - 20,
                  Color(255, 0, 0)); // Rouge
    im->rectangle(14, 14, im->getWidth() - 28, im->getHeight() - 28,
                  Color(0, 255, 0)); // Vert
    im->rectangle(18, 18, im->getWidth() - 36, im->getHeight() - 36,
                  Color(0, 0, 255)); // Bleu

    // Sauvegarde en PPM modifié (témoin)
    std::ofstream fPpm("chat_rectangles.ppm", std::ios::binary);
    im->writePPM(fPpm);
    std::cout << "      -> 'chat_rectangles.ppm' sauvegarde (~226 Ko)." << std::endl;

    // -------------------------------------------------------------------------
    // 2. Écriture JPEG avec qualité par défaut (75%)
    // -------------------------------------------------------------------------
    std::cout << "\n[2/3] Compression JPEG par defaut (qualite 75%)..." << std::endl;
    im->writeJPEG("chat.jpg"); // Utilise la valeur par défaut quality = 75
    std::cout << "      -> 'chat.jpg' genere avec succes (~19 Ko attendu)."
              << std::endl;

    // -------------------------------------------------------------------------
    // 3. Boucle de test des 21 taux de qualité (0 à 100 de 5 en 5)
    // -------------------------------------------------------------------------
    std::cout << "\n[3/3] Generation de la serie des 21 images de qualite (0% a 100%)..."
              << std::endl;
    for (unsigned int quality = 0; quality <= 100; quality += 5) {
      std::ostringstream oss;
      oss << "out_" << std::setfill('0') << std::setw(3) << quality << ".jpg";
      im->writeJPEG(oss.str().c_str(), quality);
    }
    std::cout << "      -> 21 fichiers 'out_000.jpg' a 'out_100.jpg' generes !"
              << std::endl;

    // Test bonus : Relecture de out_075.jpg via ColorImage::readJPEG
    std::cout << "\n[Bonus] Test de ColorImage::readJPEG sur 'out_075.jpg'..."
              << std::endl;
    ColorImage *relecture = ColorImage::readJPEG("out_075.jpg");
    std::cout << "      Decompression reussie : " << relecture->getWidth() << "x"
              << relecture->getHeight() << " pixels." << std::endl;
    delete relecture;

    delete im;
    std::cout << "\n>>> TOUTES LES ETAPES DU TP3 SONT VALIDEES AVEC SUCCES !"
              << std::endl;
  } catch (const std::exception &e) {
    std::cerr << "ERREUR : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
