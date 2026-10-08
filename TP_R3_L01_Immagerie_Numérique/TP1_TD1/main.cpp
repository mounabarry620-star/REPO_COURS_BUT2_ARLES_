#include "GrayImage.hpp"
#include <fstream>
#include <iostream>
#include <stdexcept>

int main() {
  try {

    std::cout << "[Test 1] Creation d'une image non carree et dessin..."
              << std::endl;
    GrayImage testImg(400, 250);
    testImg.clear(180);
    testImg.rectangle(20, 20, 100, 60, 0);
    testImg.fillRectangle(150, 40, 80, 80, 50);
    testImg.fillRectangle(270, 50, 60, 120, 255);

    std::ofstream fTest("test_rectangles.pgm", std::ios::binary);
    if (!fTest) {
      throw std::runtime_error(
          "Impossible de creer le fichier test_rectangles.pgm");
    }
    testImg.writePGM(fTest);
    fTest.close();
    std::cout << " -> Fichier 'test_rectangles.pgm' genere avec succes !"
              << std::endl;

    std::cout
        << "\n[Test 2] Lecture de chat.pgm, modifications et reecriture..."
        << std::endl;
    std::ifstream fChat("chat.pgm", std::ios::binary);
    if (!fChat) {
      throw std::runtime_error("Impossible d'ouvrir 'chat.pgm'");
    }

    GrayImage *chat = GrayImage::readPGM(fChat);
    fChat.close();
    std::cout << " -> 'chat.pgm' charge avec succes (" << chat->getWidth()
              << "x" << chat->getHeight() << " pixels)." << std::endl;

    chat->rectangle(10, 10, 70, 50, 255);
    chat->fillRectangle(chat->getWidth() - 80, 10, 70, 50, 0);

    std::ofstream fChatOut("chat_modifie.pgm", std::ios::binary);
    if (!fChatOut) {
      delete chat;
      throw std::runtime_error("Impossible de creer 'chat_modifie.pgm'");
    }
    chat->writePGM(fChatOut);
    fChatOut.close();
    delete chat;
    std::cout << " -> Fichier 'chat_modifie.pgm' sauvegarde avec succes !"
              << std::endl;

    std::cout << "\n[Test 3] Verification de la levee d'exceptions C++..."
              << std::endl;
    try {
      testImg.pixel(999, 999);
      std::cerr << "ERREUR : L'exception n'a pas ete levee !" << std::endl;
      return 1;
    } catch (const std::out_of_range &e) {
      std::cout << " -> Succes : exception bien interceptee (" << e.what()
                << ")" << std::endl;
    }

    std::cout << "\n========================================" << std::endl;
    std::cout << "TOUS LES TESTS DU SUJET SONT VALIDES !" << std::endl;
    std::cout << "========================================" << std::endl;

  } catch (const std::exception &e) {
    std::cerr << "ERREUR FATALE : " << e.what() << std::endl;
    return 1;
  }

  return 0;
}