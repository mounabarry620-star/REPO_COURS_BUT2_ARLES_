// TP3 : écriture (et lecture) JPEG avec libjpeg
#include "Image.hpp"
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>

int main()
{
  try {
    std::ifstream ifs("images/chat.ppm", std::ios::binary);
    if (!ifs)
      throw std::runtime_error("impossible d'ouvrir images/chat.ppm");
    ColorImage* im = ColorImage::readPPM(ifs);
    const uint16_t w = im->getWidth(), h = im->getHeight();
    im->rectangle(5, 5, w - 10, h - 10, Color(255, 0, 0));
    im->rectangle(10, 10, w - 20, h - 20, Color(0, 255, 0));
    im->rectangle(15, 15, w - 30, h - 30, Color(0, 0, 255));
    std::ofstream ofs("tp3_chat.ppm", std::ios::binary);
    im->writePPM(ofs);

    // Qualité par défaut (75 %).
    im->writeJPEG("tp3_chat.jpg");
    std::cout << "tp3_chat.ppm et tp3_chat.jpg écrits" << std::endl;

    // Série de 21 images de qualité 0 à 100 % (boucle donnée par le sujet).
    for (unsigned int quality = 0; quality <= 100; quality += 5) {
      std::ostringstream oss; // Variable pour former le nom de chaque fichier.
      oss << "out_" << std::setfill('0') << std::setw(3) << quality << ".jpg";
      im->writeJPEG(oss.str().c_str(), quality);
    }
    std::cout << "out_000.jpg ... out_100.jpg écrits" << std::endl;

    // Bonus : relecture d'un JPEG.
    ColorImage* relu = ColorImage::readJPEG("out_075.jpg");
    std::cout << "out_075.jpg relu : " << relu->getWidth() << " x " << relu->getHeight()
              << ", pixel (10,120) = (" << (unsigned int)relu->pixel(10, 120).r << ","
              << (unsigned int)relu->pixel(10, 120).g << ","
              << (unsigned int)relu->pixel(10, 120).b << ") au lieu de (0,255,0)" << std::endl;
    delete relu;

    // En niveaux de gris (format annoncé par le sujet du TP1 pour GrayImage).
    std::ifstream ifs2("images/chat.pgm", std::ios::binary);
    GrayImage* gris = GrayImage::readPGM(ifs2);
    gris->writeJPEG("tp3_chat_gris.jpg");
    GrayImage* gris_relu = GrayImage::readJPEG("tp3_chat_gris.jpg");
    std::cout << "tp3_chat_gris.jpg écrit puis relu : " << gris_relu->getWidth() << " x "
              << gris_relu->getHeight() << std::endl;
    delete gris_relu;
    delete gris;

    // Une erreur de libjpeg devient une exception au lieu d'arrêter le programme.
    try {
      ColorImage* p = ColorImage::readJPEG("images/chat.ppm");
      delete p;
      std::cout << "ERREUR : pas d'exception" << std::endl;
    } catch (const std::runtime_error& e) {
      std::cout << "exception attendue : " << e.what() << std::endl;
    }
    delete im;
  } catch (const std::exception& e) {
    std::cerr << "Erreur : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
