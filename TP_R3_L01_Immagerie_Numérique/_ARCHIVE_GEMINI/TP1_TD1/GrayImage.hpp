#ifndef GRAYIMAGE_HPP
#define GRAYIMAGE_HPP
#include <cstdint>
#include <iostream>
#include <stdexcept>

class GrayImage {

private:
  const uint16_t width, height;
  uint8_t *array;
  GrayImage() = delete;

public:
  GrayImage &operator=(const GrayImage &b) = delete;
  GrayImage(uint16_t w, uint16_t h);
  GrayImage(const GrayImage &orig);
  ~GrayImage();
  inline const uint16_t &getWidth() const { return width; }
  inline const uint16_t &getHeight() const { return height; }
  inline uint8_t &pixel(uint16_t x, uint16_t y) {
    if (x >= width || y >= height)
      throw std::out_of_range("Pixel hors limites");
    return array[y * width + x];
  }
  inline const uint8_t &pixel(uint16_t x, uint16_t y) const {
    if (x >= width || y >= height)
      throw std::out_of_range("Pixel hors limites");
    return array[y * width + x];
  }
  void clear(uint8_t gray = 0);
  void rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray);
  void fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h,
                     uint8_t gray);
  void writePGM(std::ostream &os) const;
  static void skip_line(std::istream &is);
  static void skip_comments(std::istream &is);
  static GrayImage *readPGM(std::istream &is);
};
#endif // GRAYIMAGE_HPP
