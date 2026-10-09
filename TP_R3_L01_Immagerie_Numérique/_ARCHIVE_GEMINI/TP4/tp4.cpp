#include "ColorImage.hpp"
#include <fstream>
#include <iostream>

int main() {
  try {
    std::cout << "=== R3.L01 - Execution du TP4 : Format TrueVision Targa (TGA) ==="
              << std::endl;

    // -------------------------------------------------------------------------
    // 1. Lecture de chat.tga (Type 2 : RGB 24 bits non-compressé)
    // -------------------------------------------------------------------------
    std::cout << "\n[1/4] Test du Sous-format 2 (RGB non-compresse) sur 'chat.tga'..."
              << std::endl;
    std::ifstream fChatIn("images/chat.tga", std::ios::binary);
    if (!fChatIn)
      throw std::runtime_error("Impossible d'ouvrir 'images/chat.tga'");

    ColorImage *chat = ColorImage::readTGA(fChatIn);
    std::cout << "      Dimensions de chat.tga : " << chat->getWidth() << "x"
              << chat->getHeight() << std::endl;

    chat->rectangle(20, 20, 80, 50, Color(255, 0, 0));      // Cadre rouge
    chat->fillRectangle(150, 30, 60, 60, Color(0, 255, 0)); // Carré vert

    // Écriture non-compressée (Sous-format 2)
    std::ofstream fChatRaw("tp4_chat_raw.tga", std::ios::binary);
    chat->writeTGA(fChatRaw, false);
    fChatRaw.close();
    std::cout << "      -> 'tp4_chat_raw.tga' genere (brut, ~230 Ko)." << std::endl;

    // Écriture compressée RLE (Sous-format 10)
    std::ofstream fChatRle("tp4_chat_rle.tga", std::ios::binary);
    chat->writeTGA(fChatRle, true);
    fChatRle.close();
    std::cout << "      -> 'tp4_chat_rle.tga' genere (compresse RLE)." << std::endl;
    delete chat;

    // -------------------------------------------------------------------------
    // 2. Test du décodage de notre propre fichier RLE
    // -------------------------------------------------------------------------
    std::cout << "\n[2/4] Test de lecture du fichier RLE genere..." << std::endl;
    std::ifstream fRleTest("tp4_chat_rle.tga", std::ios::binary);
    ColorImage *chatRleDecoded = ColorImage::readTGA(fRleTest);
    std::cout << "      -> 'tp4_chat_rle.tga' relu avec succes : "
              << chatRleDecoded->getWidth() << "x" << chatRleDecoded->getHeight()
              << std::endl;
    delete chatRleDecoded;

    // -------------------------------------------------------------------------
    // 3. Test du Sous-format 1 (Palette) et gestion de l'orientation
    // -------------------------------------------------------------------------
    std::cout << "\n[3/4] Test du Sous-format 1 (Palette) & Orientation Bottom/Top..."
              << std::endl;

    // Image palette Bottom-Left (origine en bas à gauche)
    std::ifstream fPalBL("images/palette_bl.tga", std::ios::binary);
    if (!fPalBL) throw std::runtime_error("Impossible d'ouvrir 'images/palette_bl.tga'");
    ColorImage *palBL = ColorImage::readTGA(fPalBL);
    std::ofstream fOutBL("tp4_palette_bl.tga", std::ios::binary);
    palBL->writeTGA(fOutBL, true);
    delete palBL;
    std::cout << "      -> 'tp4_palette_bl.tga' converti et enregistre (remis a l'endroit)."
              << std::endl;

    // Image palette Top-Left (origine en haut à gauche)
    std::ifstream fPalTL("images/palette_tl.tga", std::ios::binary);
    if (!fPalTL) throw std::runtime_error("Impossible d'ouvrir 'images/palette_tl.tga'");
    ColorImage *palTL = ColorImage::readTGA(fPalTL);
    std::ofstream fOutTL("tp4_palette_tl.tga", std::ios::binary);
    palTL->writeTGA(fOutTL, true);
    delete palTL;
    std::cout << "      -> 'tp4_palette_tl.tga' converti et enregistre." << std::endl;

    // -------------------------------------------------------------------------
    // 4. Test sur chat010couleurs.tga (Palette 10 couleurs)
    // -------------------------------------------------------------------------
    std::cout << "\n[4/4] Test sur 'chat010couleurs.tga'..." << std::endl;
    std::ifstream fChat10("images/chat010couleurs.tga", std::ios::binary);
    if (!fChat10) throw std::runtime_error("Impossible d'ouvrir 'images/chat010couleurs.tga'");
    ColorImage *chat10 = ColorImage::readTGA(fChat10);
    std::ofstream fOutChat10("tp4_chat10.tga", std::ios::binary);
    chat10->writeTGA(fOutChat10, true);
    delete chat10;
    std::cout << "      -> 'tp4_chat10.tga' converti et enregistre." << std::endl;

    std::cout << "\n>>> TOUTES LES ETAPES DU TP4 SONT VALIDEES AVEC SUCCES !"
              << std::endl;
  } catch (const std::exception &e) {
    std::cerr << "ERREUR CRITIQUE : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
