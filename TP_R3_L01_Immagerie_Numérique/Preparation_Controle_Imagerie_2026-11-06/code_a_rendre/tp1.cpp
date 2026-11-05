// TP1 : classe GrayImage et format PGM
#include "Image.hpp"
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

int main()
{
  try {
    // 1. Écriture : image NON carrée, effacée, avec quelques rectangles.
    GrayImage im(400, 250);
    im.clear(180);
    im.rectangle(20, 20, 100, 60, 0);
    im.fillRectangle(150, 40, 80, 80, 50);
    im.fillRectangle(270, 50, 60, 120, 255);
    std::ofstream ofs1("tp1_rectangles.pgm", std::ios::binary);
    im.writePGM(ofs1);
    std::cout << "tp1_rectangles.pgm écrit (400 x 250)" << std::endl;

    // 2. Lecture de chat.pgm (plein de commentaires !), dessin des lunettes, réécriture.
    std::ifstream ifs("images/chat.pgm", std::ios::binary);
    if (!ifs)
      throw std::runtime_error("impossible d'ouvrir images/chat.pgm");
    GrayImage* chat = GrayImage::readPGM(ifs);
    std::cout << "chat.pgm lu : " << chat->getWidth() << " x " << chat->getHeight() << std::endl;
    chat->fillRectangle(65, 100, 215, 4, 255); // la barre
    chat->fillRectangle(105, 90, 45, 30, 20);  // verre gauche
    chat->fillRectangle(195, 90, 45, 30, 20);  // verre droit
    chat->rectangle(105, 90, 45, 30, 255);     // monture gauche
    chat->rectangle(195, 90, 45, 30, 255);     // monture droite
    std::ofstream ofs2("tp1_chat_lunettes.pgm", std::ios::binary);
    chat->writePGM(ofs2);
    std::cout << "tp1_chat_lunettes.pgm écrit" << std::endl;

    // Comparaison avec l'image de référence fournie (chat_lunettes.pgm).
    std::ifstream ref("images/chat_lunettes.pgm", std::ios::binary);
    GrayImage* attendu = GrayImage::readPGM(ref);
    unsigned int differences = 0;
    for (uint16_t y = 0; y < chat->getHeight(); y++)
      for (uint16_t x = 0; x < chat->getWidth(); x++)
        if (chat->pixel(x, y) != attendu->pixel(x, y))
          differences++;
    std::cout << "comparaison avec chat_lunettes.pgm : " << differences
              << " pixel(s) différent(s)" << std::endl;
    delete attendu;
    delete chat;

    // 3. Bonus : lecture d'un PGM « ASCII pur » (P2), réécrit en P5.
    std::ifstream ifs3("images/Rafale30000.pgm", std::ios::binary);
    GrayImage* rafale = GrayImage::readPGM(ifs3);
    std::ofstream ofs3("tp1_rafale.pgm", std::ios::binary);
    rafale->writePGM(ofs3);
    std::cout << "Rafale30000.pgm (P2) lu puis écrit en P5 : tp1_rafale.pgm" << std::endl;
    delete rafale;

    // 4. En-têtes « inhabituels » mais valides selon PGM.txt (« be as lenient as possible ») :
    //    tout sur une ligne, et fins de ligne Windows (CR LF).
    std::istringstream une_ligne(std::string("P5 2 1 255\n") + char(10) + char(35));
    std::istringstream windows(std::string("P5\r\n# commentaire\r\n2 1\r\n255\n") + char(10) + char(35));
    GrayImage* a = GrayImage::readPGM(une_ligne);
    GrayImage* b = GrayImage::readPGM(windows);
    std::cout << "en-têtes souples : pixels " << (unsigned int)a->pixel(0, 0) << " "
              << (unsigned int)a->pixel(1, 0) << " et " << (unsigned int)b->pixel(0, 0) << " "
              << (unsigned int)b->pixel(1, 0) << " (attendu : 10 35 et 10 35)" << std::endl;
    delete b;
    delete a;

    // 5. Les erreurs sont signalées par des exceptions.
    try {
      im.pixel(400, 0) = 0; // x = 400 n'existe pas (0 <= x < 400)
      std::cout << "ERREUR : pas d'exception" << std::endl;
    } catch (const std::out_of_range& e) {
      std::cout << "exception attendue : " << e.what() << std::endl;
    }
    try {
      std::ifstream faux("images/chat.ppm", std::ios::binary); // un PPM, pas un PGM
      GrayImage* p = GrayImage::readPGM(faux);
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
