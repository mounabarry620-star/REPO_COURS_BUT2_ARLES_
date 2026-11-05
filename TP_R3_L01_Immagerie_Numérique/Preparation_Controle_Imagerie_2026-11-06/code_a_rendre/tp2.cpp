// TP2 : classe ColorImage, format PPM et rééchantillonnage
#include "Image.hpp"
#include <fstream>
#include <iostream>

int main()
{
  try {
    // 1. Lecture de chat.ppm, rectangles colorés, écriture de tp2_chat.ppm.
    std::ifstream ifs("images/chat.ppm", std::ios::binary);
    if (!ifs)
      throw std::runtime_error("impossible d'ouvrir images/chat.ppm");
    ColorImage* chat = ColorImage::readPPM(ifs);
    std::cout << "chat.ppm lu : " << chat->getWidth() << " x " << chat->getHeight() << std::endl;
    chat->rectangle(20, 20, 100, 60, Color(255, 0, 0));
    chat->fillRectangle(200, 30, 60, 40, Color(0, 255, 0));
    chat->fillRectangle(140, 180, 50, 30, Color(0, 0, 255));
    std::ofstream ofs1("tp2_chat.ppm", std::ios::binary);
    chat->writePPM(ofs1);
    std::cout << "tp2_chat.ppm écrit" << std::endl;
    delete chat;

    // 2. Agrandissement de chat_petit.ppm (80 x 60) en 823 x 400.
    std::ifstream ifs2("images/chat_petit.ppm", std::ios::binary);
    ColorImage* petit = ColorImage::readPPM(ifs2);
    ColorImage* simple = petit->simpleScale(823, 400);
    std::ofstream ofs2("tp2_simple.ppm", std::ios::binary);
    simple->writePPM(ofs2);
    std::cout << "tp2_simple.ppm écrit (plus proche voisin)" << std::endl;
    ColorImage* bilinear = petit->bilinearScale(823, 400);
    std::ofstream ofs3("tp2_bilinear.ppm", std::ios::binary);
    bilinear->writePPM(ofs3);
    std::cout << "tp2_bilinear.ppm écrit (bilinéaire)" << std::endl;
    delete bilinear;
    delete simple;
    delete petit;

    // 3. Même chose en niveaux de gris avec chat_petit.pgm.
    std::ifstream ifs4("images/chat_petit.pgm", std::ios::binary);
    GrayImage* gpetit = GrayImage::readPGM(ifs4);
    GrayImage* gsimple = gpetit->simpleScale(823, 400);
    GrayImage* gbilinear = gpetit->bilinearScale(823, 400);
    std::ofstream ofs4("tp2_simple.pgm", std::ios::binary);
    gsimple->writePGM(ofs4);
    std::ofstream ofs5("tp2_bilinear.pgm", std::ios::binary);
    gbilinear->writePGM(ofs5);
    std::cout << "tp2_simple.pgm et tp2_bilinear.pgm écrits" << std::endl;
    delete gbilinear;
    delete gsimple;
    delete gpetit;

    // 4. Bonus : lecture d'un PPM « ASCII pur » (P3).
    std::ifstream ifs6("images/Rafale30000.ppm", std::ios::binary);
    ColorImage* rafale = ColorImage::readPPM(ifs6);
    std::ofstream ofs6("tp2_rafale.ppm", std::ios::binary);
    rafale->writePPM(ofs6);
    std::cout << "Rafale30000.ppm (P3) lu puis écrit en P6 : tp2_rafale.ppm" << std::endl;
    delete rafale;

    // 5. Vérification rapide des opérateurs de Color.
    Color c = 0.5 * Color(200, 100, 1) + 0.5 * Color(100, 100, 255);
    std::cout << "0.5*(200,100,1) + 0.5*(100,100,255) = (" << (unsigned int)c.r << ","
              << (unsigned int)c.g << "," << (unsigned int)c.b << ")" << std::endl;
  } catch (const std::exception& e) {
    std::cerr << "Erreur : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
