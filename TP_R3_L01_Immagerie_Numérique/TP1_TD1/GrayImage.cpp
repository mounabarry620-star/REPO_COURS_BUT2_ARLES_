#include "GrayImage.hpp"
#include <cstdint>
#include <iostream>
#include <stdexcept>

GrayImage::GrayImage(uint16_t w, uint16_t h)
    : width(w), height(h), array(nullptr) {
  if (w == 0 || h == 0)
    throw std::invalid_argument(
        "Dimmensions strictement positives c'est à dire supérieur à Zéro");
  array = new uint8_t[width * height];
}

GrayImage::GrayImage(const GrayImage &_orig)
    : width(_orig.width), height(_orig.height), array(nullptr) {
  array = new uint8_t[_orig.width * _orig.height];
}