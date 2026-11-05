// TP4 : format Targa (TGA) non compressé, avec palette et compressé RLE
#include "Image.hpp"
#include <fstream>
#include <iostream>
#include <string>

// Lit un fichier TGA (exception si on ne peut pas l'ouvrir).
static ColorImage* lire(const std::string& nom)
{
  std::ifstream ifs(nom, std::ios::binary);
  if (!ifs)
    throw std::runtime_error("impossible d'ouvrir " + nom);
  return ColorImage::readTGA(ifs);
}

// Écrit un fichier TGA et affiche sa taille.
static void ecrire(const ColorImage& im, const std::string& nom, bool rle)
{
  {
    std::ofstream ofs(nom, std::ios::binary);
    im.writeTGA(ofs, rle);
  } // Fermeture du fichier ici (destructeur de ofstream).
  std::ifstream f(nom, std::ios::binary | std::ios::ate); // ate : position = fin du fichier
  std::cout << "  " << nom << " : " << f.tellg() << " octets" << std::endl;
}

static bool identiques(const ColorImage& a, const ColorImage& b)
{
  if (a.getWidth() != b.getWidth() || a.getHeight() != b.getHeight())
    return false;
  for (uint16_t y = 0; y < a.getHeight(); y++)
    for (uint16_t x = 0; x < a.getWidth(); x++)
      if (a.pixel(x, y) != b.pixel(x, y))
        return false;
  return true;
}

int main()
{
  try {
    // 1. Sous-format 2 : lecture de chat.tga puis écriture brute et RLE.
    ColorImage* chat = lire("images/chat.tga");
    std::cout << "chat.tga lu : " << chat->getWidth() << " x " << chat->getHeight() << std::endl;
    ecrire(*chat, "tp4_chat_brut.tga", false);
    ecrire(*chat, "tp4_chat_rle.tga", true);
    ColorImage* relu1 = lire("tp4_chat_brut.tga");
    ColorImage* relu2 = lire("tp4_chat_rle.tga");
    std::cout << "  relecture brut identique : " << (identiques(*chat, *relu1) ? "oui" : "NON") << std::endl;
    std::cout << "  relecture RLE identique  : " << (identiques(*chat, *relu2) ? "oui" : "NON") << std::endl;
    delete relu2;
    delete relu1;

    // Sur une image avec de grandes zones uniformes, RLE est bien plus efficace.
    chat->fillRectangle(0, 0, chat->getWidth(), 100, Color(255, 255, 0));
    ecrire(*chat, "tp4_chat_bandeau_rle.tga", true);
    delete chat;

    // 2. Sous-format 1 (palette) : origine en bas à gauche, puis en haut à gauche.
    ColorImage* bl = lire("images/palette_bl.tga");
    ColorImage* tl = lire("images/palette_tl.tga");
    std::cout << "palette_bl.tga et palette_tl.tga lus ("
              << bl->getWidth() << " x " << bl->getHeight() << ")" << std::endl;
    ecrire(*bl, "tp4_palette_bl.tga", true);
    ecrire(*tl, "tp4_palette_tl.tga", true);
    delete tl;
    delete bl;

    // 3. Image à 10 couleurs avec palette : RLE la compresse très bien.
    ColorImage* chat10 = lire("images/chat010couleurs.tga");
    ecrire(*chat10, "tp4_chat10_brut.tga", false);
    ecrire(*chat10, "tp4_chat10_rle.tga", true);
    delete chat10;

    // 4. Sous-format 10 écrit par un autre logiciel (origine en bas à gauche).
    ColorImage* chanel = lire("images/chanel.tga");
    std::ofstream ofs("tp4_chanel.ppm", std::ios::binary);
    chanel->writePPM(ofs);
    std::cout << "chanel.tga (RLE) lu puis écrit en PPM : tp4_chanel.ppm" << std::endl;
    delete chanel;

    // 5. Niveaux de gris (format annoncé par le sujet du TP1) : sous-formats 3 et 11.
    std::ifstream ifs("images/chat.pgm", std::ios::binary);
    GrayImage* gris = GrayImage::readPGM(ifs);
    for (int rle = 0; rle <= 1; rle++) {
      const char* nom = rle ? "tp4_chat_gris_rle.tga" : "tp4_chat_gris_brut.tga";
      {
        std::ofstream ofs2(nom, std::ios::binary);
        gris->writeTGA(ofs2, rle == 1);
      }
      std::ifstream relire(nom, std::ios::binary);
      GrayImage* relu = GrayImage::readTGA(relire);
      bool pareil = true;
      for (uint16_t y = 0; y < gris->getHeight(); y++)
        for (uint16_t x = 0; x < gris->getWidth(); x++)
          if (relu->pixel(x, y) != gris->pixel(x, y))
            pareil = false;
      std::cout << "  " << nom << " relu identique : " << (pareil ? "oui" : "NON") << std::endl;
      delete relu;
    }
    delete gris;

    // 6. Un sous-format non géré doit lever une exception.
    try {
      ColorImage* p = lire("images/chat.ppm");
      delete p;
      std::cout << "ERREUR : pas d'exception" << std::endl;
    } catch (const std::runtime_error& e) {
      std::cout << "exception attendue : " << e.what() << std::endl;
    }
  } catch (const std::exception& e) {
    std::cerr << "Erreur : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
