#ifndef GRAYIMAGE_HPP
#define GRAYIMAGE_HPP

#include <cstdint>
#include <iostream>
#include <stdexcept>

#include <string>

class GrayImage {

private:
  const uint16_t width, height;
  uint8_t *array;
  GrayImage() = delete;

public:
  GrayImage &operator=(const GrayImage &b) = delete;
  GrayImage(uint16_t w, uint16_t);
  GrayImage(const GrayImage &_orig);
  ~GrayImage();
};
#endif // GRAYIMAGE_HPP