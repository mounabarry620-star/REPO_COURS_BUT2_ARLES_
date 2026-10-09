// TD2, exercice 2 : lire sur un PC (little endian) des données écrites par une
// machine big endian. Ce programme d'entraînement n'est pas à rendre.
//
//   g++ -std=c++11 -Wall -Wextra td2_endianness.cpp -o td2 && ./td2
//
// 1. Il fabrique « data.dat » comme l'aurait fait une machine big endian :
//    un int16_t, un double, 4 caractères FourCC, une chaîne précédée de sa taille.
// 2. Il le relit avec les deux méthodes vues dans la fiche de révision.
#include <cstddef>
#include <cstdint>
#include <cstring>   // std::memcpy
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

// Question 1 : permute les octets de n'importe quelle variable.
template <typename T>
void swap_bytes(T& t)
{
  uint8_t* ptr = reinterpret_cast<uint8_t*>(&t);
  for (size_t i = 0; i < sizeof(T) / 2; i++) {
    uint8_t tmp            = ptr[i];
    ptr[i]                 = ptr[sizeof(T) - 1 - i];
    ptr[sizeof(T) - 1 - i] = tmp;
  }
}

// Vrai si le premier octet en mémoire est le poids faible.
bool machine_little_endian()
{
  uint16_t v = 0x1234;
  return *reinterpret_cast<uint8_t*>(&v) == 0x34;
}

struct Data {
  int16_t     a;         // entier signé 16 bits
  double      b;         // réel IEEE 754 double précision
  char        fourcc[4]; // exactement 4 caractères, sans '\0'
  std::string d;         // chaîne de 0 à 255 caractères
};

// Écrit la valeur v octet par octet, poids fort d'abord (big endian), quelle
// que soit la machine : on travaille sur la valeur, pas sur la mémoire.
static void ecrire_big_endian(std::ostream& os, uint64_t v, int nb_octets)
{
  for (int i = nb_octets - 1; i >= 0; i--)
    os.put(char((v >> (8 * i)) & 0xFF));
}

static void fabriquer_fichier(const char* nom)
{
  std::ofstream os(nom, std::ios::binary);
  int16_t a = -1234;
  double  b = 3.14159;
  uint64_t bits_b;
  std::memcpy(&bits_b, &b, 8);                 // les 64 bits du double
  ecrire_big_endian(os, uint16_t(a), 2);
  ecrire_big_endian(os, bits_b, 8);
  os.write("JFIF", 4);                         // FourCC : 4 octets isolés, pas d'ordre
  std::string d = "Bonjour R3.L01";
  os.put(char(d.size()));                      // préfixe : la taille sur 1 octet
  os.write(d.data(), d.size());
}

// Question 2 : lecture champ par champ, puis permutation si la machine est little endian.
void read_Data(Data& data, std::istream& is)
{
  is.read((char*)&data.a, 2);
  is.read((char*)&data.b, 8);
  is.read(data.fourcc, 4);
  uint8_t taille = 0;
  is.read((char*)&taille, 1);
  data.d = std::string(taille, ' ');   // (nombre, caractère)
  is.read(&data.d[0], taille);
  if (!is)
    throw std::runtime_error("read_Data : fichier tronqué");
  if (machine_little_endian()) {       // question 3 : rien à faire sur une machine big endian
    swap_bytes(data.a);
    swap_bytes(data.b);
  }
}

// Question 3, autre méthode : reconstruire les nombres avec des décalages.
// Aucun test de la machine : le code est le même partout.
void read_Data_portable(Data& data, std::istream& is)
{
  uint8_t o[2];
  is.read((char*)o, 2);
  data.a = int16_t((o[0] << 8) | o[1]);
  uint8_t p[8];
  is.read((char*)p, 8);
  uint64_t bits = 0;
  for (int i = 0; i < 8; i++)
    bits = (bits << 8) | p[i];
  std::memcpy(&data.b, &bits, 8);
  is.read(data.fourcc, 4);
  uint8_t taille = 0;
  is.read((char*)&taille, 1);
  data.d = std::string(taille, ' ');
  is.read(&data.d[0], taille);
  if (!is)
    throw std::runtime_error("read_Data_portable : fichier tronqué");
}

static void afficher(const char* titre, const Data& data)
{
  std::cout << titre << " : a = " << data.a << ", b = " << data.b << ", fourcc = "
            << std::string(data.fourcc, 4) << ", d = \"" << data.d << "\"" << std::endl;
}

int main()
{
  try {
    std::cout << "Cette machine est " << (machine_little_endian() ? "little" : "big")
              << " endian." << std::endl;

    int16_t essai = 0x1234;
    swap_bytes(essai);
    std::cout << std::hex << "swap_bytes(0x1234) = 0x" << essai << std::dec << std::endl;

    fabriquer_fichier("data.dat");

    Data d1, d2;
    std::ifstream f1("data.dat", std::ios::binary);
    read_Data(d1, f1);
    afficher("méthode 1 (swap_bytes)", d1);
    std::ifstream f2("data.dat", std::ios::binary);
    read_Data_portable(d2, f2);
    afficher("méthode 2 (décalages)  ", d2);

    std::cout << "sizeof(Data) = " << sizeof(Data)
              << " : on ne peut pas lire la structure d'un seul bloc (padding, std::string)."
              << std::endl;
  } catch (const std::exception& e) {
    std::cerr << "Erreur : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
