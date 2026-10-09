#include "GrayImage.hpp"

GrayImage::GrayImage(uint16_t w, uint16_t h)
    : width(w), height(h), array(nullptr) {
  if (w == 0 || h == 0)
    throw std::invalid_argument("Dimensions strictement positives");
  array = new uint8_t[width * height];
}
GrayImage::GrayImage(const GrayImage &o)
    : width(o.width), height(o.height), array(nullptr) {
  array = new uint8_t[o.width * o.height];
  for (size_t t = 0; t < size_t(width * height); t++)
    array[t] = o.array[t];
}
GrayImage::~GrayImage() { delete[] array; }
void GrayImage::clear(uint8_t gray) {
  for (size_t t = 0; t < size_t(width * height); t++)
    array[t] = gray;
}
void GrayImage::rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                          uint8_t gray) {
  if (w == 0 || h == 0)
    return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("Rectangle hors limites");
  for (uint16_t i = 0; i < w; ++i) {
    pixel(x + i, y) = gray;
    pixel(x + i, y + h - 1) = gray;
  }
  for (uint16_t j = 0; j < h; ++j) {
    pixel(x, y + j) = gray;
    pixel(x + w - 1, y + j) = gray;
  }
}
void GrayImage::fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                              uint8_t gray) {
  if (w == 0 || h == 0)
    return;
  if (x + w > width || y + h > height)
    throw std::out_of_range("Rectangle plein hors limites");
  for (uint16_t j = 0; j < h; ++j)
    for (uint16_t i = 0; i < w; ++i)
      pixel(x + i, y + j) = gray;
}

void GrayImage::writePGM(std::ostream &os) const {
  os << "P5\n# Image sauvegardee pour les TP de RepCod.\n"
     << width << " " << height << "\n255\n";
  os.write((const char *)array,
           width * height); // Cast direct (const char*) exact du prof
}
void GrayImage::skip_line(std::istream &is) {
  char c;
  while (is.get(c) && c != '\n') {
  }
}
void GrayImage::skip_comments(std::istream &is) {
  char c;
  while (is.get(c)) {
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r')
      continue;
    if (c == '#')
      skip_line(is);
    else {
      is.putback(c);
      break;
    }
  }
}
GrayImage *GrayImage::readPGM(std::istream &is) {
  std::string magic = "";
  if (!(is >> magic))
    throw std::runtime_error("Magic number absent");
  if (magic != "P5" && magic != "P2")
    throw std::runtime_error("Format non PGM");
  skip_comments(is);
  uint16_t w = 0, h = 0;
  if (!(is >> w >> h))
    throw std::runtime_error("Erreur dimensions");
  skip_comments(is);
  int dyn = 0;
  if (!(is >> dyn) || dyn != 255)
    throw std::runtime_error("Dynamique != 255");
  GrayImage *res = new GrayImage(w, h);
  if (magic == "P5") {
    char sep;
    is.get(sep);
    is.read((char *)res->array, w * h);
    if (!is) {
      delete res;
      throw std::runtime_error("Erreur lecture pixels");
    }
  } else {
    for (size_t t = 0; t < size_t(w * h); ++t) {
      int val;
      if (!(is >> val)) {
        delete res;
        throw std::runtime_error("Erreur ASCII P2");
      }
      res->array[t] = (uint8_t)val;
    }
  }
  return res;
}