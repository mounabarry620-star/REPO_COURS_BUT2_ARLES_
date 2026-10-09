#include "ColorImage.hpp"
#include <cstdio>
#include <cstdlib>

// Inclusion des déclarations de la bibliothèque C libjpeg en C++
extern "C" {
#include <jpeglib.h>
}

// =============================================================================
// Constructeurs et Destructeur
// =============================================================================
ColorImage::ColorImage(uint16_t w, uint16_t h)
    : width(w), height(h), array(nullptr) {
  if (w == 0 || h == 0)
    throw std::invalid_argument("Les dimensions doivent etre strictement positives");
  array = new Color[width * height];
}

ColorImage::ColorImage(const ColorImage &orig)
    : width(orig.width), height(orig.height), array(nullptr) {
  array = new Color[orig.width * orig.height];
  for (size_t i = 0; i < size_t(width * height); ++i) {
    array[i] = orig.array[i];
  }
}

ColorImage::~ColorImage() {
  delete[] array;
}

// =============================================================================
// Méthodes élémentaires de dessin
// =============================================================================
void ColorImage::clear(Color color) {
  for (size_t i = 0; i < size_t(width * height); ++i) {
    array[i] = color;
  }
}

void ColorImage::rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                           Color color) {
  if (w == 0 || h == 0) return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("Rectangle hors limites");

  for (uint16_t i = 0; i < w; ++i) {
    pixel(x + i, y) = color;
    pixel(x + i, y + h - 1) = color;
  }
  for (uint16_t j = 0; j < h; ++j) {
    pixel(x, y + j) = color;
    pixel(x + w - 1, y + j) = color;
  }
}

void ColorImage::fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                               Color color) {
  if (w == 0 || h == 0) return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("Rectangle plein hors limites");

  for (uint16_t j = 0; j < h; ++j) {
    for (uint16_t i = 0; i < w; ++i) {
      pixel(x + i, y + j) = color;
    }
  }
}

// =============================================================================
// E/S Format PPM (P6 et P3)
// =============================================================================
void ColorImage::writePPM(std::ostream &os) const {
  os << "P6\n# Image sauvegardee pour RepCod.\n"
     << width << " " << height << "\n255\n";
  os.write(reinterpret_cast<const char *>(array), width * height * 3);
}

void ColorImage::skip_line(std::istream &is) {
  char c;
  while (is.get(c) && c != '\n') {}
}

void ColorImage::skip_comments(std::istream &is) {
  char c;
  while (is.get(c)) {
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r')
      continue;
    if (c == '#') {
      skip_line(is);
    } else {
      is.putback(c);
      break;
    }
  }
}

ColorImage *ColorImage::readPPM(std::istream &is) {
  std::string magic = "";
  if (!(is >> magic))
    throw std::runtime_error("Impossible de lire le magic number PPM");

  if (magic != "P6" && magic != "P3")
    throw std::runtime_error("Format non supporte (P6 ou P3 attendu) : " + magic);

  skip_comments(is);
  uint16_t w = 0, h = 0;
  if (!(is >> w >> h))
    throw std::runtime_error("Dimensions d'image invalides ou absentes");

  skip_comments(is);
  int maxval = 0;
  if (!(is >> maxval) || maxval != 255)
    throw std::runtime_error("Dynamique non supportee (255 attendu)");

  ColorImage *res = new ColorImage(w, h);

  if (magic == "P6") {
    char sep;
    is.get(sep);
    is.read(reinterpret_cast<char *>(res->array), w * h * 3);
    if (!is) {
      delete res;
      throw std::runtime_error("Erreur lecture donnees binaires PPM");
    }
  } else {
    for (size_t i = 0; i < size_t(w * h); ++i) {
      int r, g, b;
      if (!(is >> r >> g >> b)) {
        delete res;
        throw std::runtime_error("Erreur lecture pixels P3");
      }
      res->array[i] = Color(static_cast<uint8_t>(r),
                            static_cast<uint8_t>(g),
                            static_cast<uint8_t>(b));
    }
  }

  return res;
}

// =============================================================================
// Rééchantillonnages Spatiaux (TP2)
// =============================================================================
ColorImage *ColorImage::simpleScale(uint16_t w, uint16_t h) const {
  if (w == 0 || h == 0)
    throw std::invalid_argument("Dimensions de redimensionnement doivent etre > 0");

  ColorImage *res = new ColorImage(w, h);
  for (uint16_t y_prime = 0; y_prime < h; ++y_prime) {
    uint16_t y = static_cast<uint16_t>((uint32_t(y_prime) * height) / h);
    for (uint16_t x_prime = 0; x_prime < w; ++x_prime) {
      uint16_t x = static_cast<uint16_t>((uint32_t(x_prime) * width) / w);
      res->pixel(x_prime, y_prime) = pixel(x, y);
    }
  }
  return res;
}

ColorImage *ColorImage::bilinearScale(uint16_t w, uint16_t h) const {
  if (w == 0 || h == 0)
    throw std::invalid_argument("Dimensions de redimensionnement doivent etre > 0");

  ColorImage *res = new ColorImage(w, h);
  for (uint16_t y_prime = 0; y_prime < h; ++y_prime) {
    double y = (static_cast<double>(y_prime) * height) / h;
    uint16_t y0 = static_cast<uint16_t>(y);
    uint16_t y1 = (y0 + 1 < height) ? y0 + 1 : y0;
    double dy = y - y0;

    for (uint16_t x_prime = 0; x_prime < w; ++x_prime) {
      double x = (static_cast<double>(x_prime) * width) / w;
      uint16_t x0 = static_cast<uint16_t>(x);
      uint16_t x1 = (x0 + 1 < width) ? x0 + 1 : x0;
      double dx = x - x0;

      const Color &c00 = pixel(x0, y0);
      const Color &c10 = pixel(x1, y0);
      const Color &c01 = pixel(x0, y1);
      const Color &c11 = pixel(x1, y1);

      Color c_top = (1.0 - dx) * c00 + dx * c10;
      Color c_bot = (1.0 - dx) * c01 + dx * c11;
      res->pixel(x_prime, y_prime) = (1.0 - dy) * c_top + dy * c_bot;
    }
  }
  return res;
}

// =============================================================================
// NOUVEAUTÉ TP3 : Écriture et Lecture JPEG avec libjpeg
// =============================================================================

// Écriture d'une image au format JPEG avec paramètre de qualité (0 à 100)
void ColorImage::writeJPEG(const char *fname, unsigned int quality) const {
  if (!fname)
    throw std::invalid_argument("Nom de fichier JPEG invalide (pointeur nul)");

  // 1. Déclaration et initialisation des structures libjpeg
  struct jpeg_compress_struct cinfo;
  struct jpeg_error_mgr jerr;

  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_compress(&cinfo);

  // 2. Ouverture du fichier de sortie en binaire ("wb")
  FILE *outfile = fopen(fname, "wb");
  if (!outfile) {
    jpeg_destroy_compress(&cinfo);
    throw std::runtime_error(std::string("Impossible d'ouvrir le fichier en ecriture : ") + fname);
  }
  jpeg_stdio_dest(&cinfo, outfile);

  // 3. Spécification des paramètres de l'image source
  cinfo.image_width = width;
  cinfo.image_height = height;
  cinfo.input_components = 3;         // 3 composantes (Rouge, Vert, Bleu)
  cinfo.in_color_space = JCS_RGB;     // Espace de couleur d'entrée RGB

  jpeg_set_defaults(&cinfo);
  // Réglage du taux de qualité demandé par l'énoncé du TP3
  jpeg_set_quality(&cinfo, quality, TRUE);

  // 4. Démarrage de la compression
  jpeg_start_compress(&cinfo, TRUE);

  // 5. Écriture ligne par ligne (scanlines)
  JSAMPROW row_pointer[1];
  int row_stride = width * 3;
  const JSAMPLE *buffer = reinterpret_cast<const JSAMPLE *>(array);

  while (cinfo.next_scanline < cinfo.image_height) {
    row_pointer[0] = const_cast<JSAMPROW>(&buffer[cinfo.next_scanline * row_stride]);
    jpeg_write_scanlines(&cinfo, row_pointer, 1);
  }

  // 6. Finalisation et libération propre des ressources
  jpeg_finish_compress(&cinfo);
  fclose(outfile);
  jpeg_destroy_compress(&cinfo);
}

// Lecture d'une image au format JPEG (Décompression)
ColorImage *ColorImage::readJPEG(const char *fname) {
  if (!fname)
    throw std::invalid_argument("Nom de fichier JPEG invalide (pointeur nul)");

  FILE *infile = fopen(fname, "rb");
  if (!infile)
    throw std::runtime_error(std::string("Impossible d'ouvrir le fichier en lecture : ") + fname);

  struct jpeg_decompress_struct cinfo;
  struct jpeg_error_mgr jerr;

  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_decompress(&cinfo);
  jpeg_stdio_src(&cinfo, infile);

  jpeg_read_header(&cinfo, TRUE);
  cinfo.out_color_space = JCS_RGB; // Forcer l'espace de couleur en RGB 24 bits
  jpeg_start_decompress(&cinfo);

  ColorImage *res = new ColorImage(cinfo.output_width, cinfo.output_height);
  int row_stride = cinfo.output_width * cinfo.output_components;
  JSAMPLE *buffer = reinterpret_cast<JSAMPLE *>(res->array);
  JSAMPROW row_pointer[1];

  while (cinfo.output_scanline < cinfo.output_height) {
    row_pointer[0] = &buffer[cinfo.output_scanline * row_stride];
    jpeg_read_scanlines(&cinfo, row_pointer, 1);
  }

  jpeg_finish_decompress(&cinfo);
  fclose(infile);
  jpeg_destroy_decompress(&cinfo);

  return res;
}
