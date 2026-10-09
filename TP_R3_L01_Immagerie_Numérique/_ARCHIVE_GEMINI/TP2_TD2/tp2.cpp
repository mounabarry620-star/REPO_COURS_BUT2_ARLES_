#include "ColorImage.hpp"
#include <fstream>
#include <iostream>

int main() {
  try {
    std::cout << "=== R3.L01 - Execution du TP2 (M. Remy) ===" << std::endl;

    // -------------------------------------------------------------------------
    // Étape 1 : Test de ColorImage et écriture PPM sur chat.ppm
    // -------------------------------------------------------------------------
    std::cout << "[1/3] Lecture de chat.ppm et trace de rectangles..." << std::endl;
    std::ifstream fChat("chat.ppm", std::ios::binary);
    if (!fChat)
      throw std::runtime_error("Impossible d'ouvrir le fichier source 'chat.ppm'");

    ColorImage *chat = ColorImage::readPPM(fChat);
    std::cout << "      Dimensions de chat.ppm : " << chat->getWidth()
              << "x" << chat->getHeight() << std::endl;

    // Trace un cadre rectangulaire rouge et un rectangle plein vert
    chat->rectangle(20, 20, 80, 50, Color(255, 0, 0));
    chat->fillRectangle(150, 30, 60, 60, Color(0, 255, 0));

    std::ofstream fChatOut("tp2_chat.ppm", std::ios::binary);
    if (!fChatOut)
      throw std::runtime_error("Impossible d'ecrire dans 'tp2_chat.ppm'");
    chat->writePPM(fChatOut);
    delete chat;
    std::cout << "      -> 'tp2_chat.ppm' genere avec succes." << std::endl;

    // -------------------------------------------------------------------------
    // Étape 2 : Rééchantillonnage Simpliste (80x60 -> 823x400)
    // -------------------------------------------------------------------------
    std::cout << "[2/3] Lecture de chat_petit.ppm et simpleScale(823, 400)..." << std::endl;
    std::ifstream fPetit("chat_petit.ppm", std::ios::binary);
    if (!fPetit)
      throw std::runtime_error("Impossible d'ouvrir le fichier source 'chat_petit.ppm'");

    ColorImage *petit = ColorImage::readPPM(fPetit);
    std::cout << "      Dimensions d'origine : " << petit->getWidth()
              << "x" << petit->getHeight() << std::endl;

    ColorImage *simple = petit->simpleScale(823, 400);
    std::ofstream fSimple("tp2_simple.ppm", std::ios::binary);
    if (!fSimple)
      throw std::runtime_error("Impossible d'ecrire dans 'tp2_simple.ppm'");
    simple->writePPM(fSimple);
    delete simple;
    std::cout << "      -> 'tp2_simple.ppm' genere avec succes (effet de blocs)." << std::endl;

    // -------------------------------------------------------------------------
    // Étape 3 : Rééchantillonnage Bilinéaire (80x60 -> 823x400)
    // -------------------------------------------------------------------------
    std::cout << "[3/3] bilinearScale(823, 400)..." << std::endl;
    ColorImage *bilinear = petit->bilinearScale(823, 400);
    std::ofstream fBilinear("tp2_bilinear.ppm", std::ios::binary);
    if (!fBilinear)
      throw std::runtime_error("Impossible d'ecrire dans 'tp2_bilinear.ppm'");
    bilinear->writePPM(fBilinear);
    delete bilinear;
    delete petit;
    std::cout << "      -> 'tp2_bilinear.ppm' genere avec succes (aspect adouci)." << std::endl;

    std::cout << "\n>>> TOUTES LES ETAPES DU TP2 ONT ETE COMPLETEES AVEC SUCCES !" << std::endl;
  } catch (const std::exception &e) {
    std::cerr << "ERREUR CRITIQUE : " << e.what() << std::endl;
    return 1;
  }

  return 0;
}
