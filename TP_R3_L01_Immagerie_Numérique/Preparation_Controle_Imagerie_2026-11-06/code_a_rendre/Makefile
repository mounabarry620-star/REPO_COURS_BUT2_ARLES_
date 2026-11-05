# R3.L01 : compilation de tous les TP
#   make          -> compile tp1 ... tp5
#   make test     -> compile puis exécute les 5 programmes
#   make clean    -> supprime les fichiers compilés et les images produites
CXX      = g++
CXXFLAGS = -std=c++11 -Wall -Wextra
LDLIBS   = -ljpeg

PROGS = tp1 tp2 tp3 tp4 tp5

all: $(PROGS)

tp%: tp%.o Image.o
	$(CXX) -o $@ $^ $(LDLIBS)

%.o: %.cpp Image.hpp
	$(CXX) $(CXXFLAGS) -c $<

test: all
	./tp1 && ./tp2 && ./tp3 && ./tp4 && ./tp5

clean:
	rm -f *.o $(PROGS) tp1_*.pgm tp2_*.p?m tp3_* out_*.jpg tp4_* tp5_*.ppm

.PHONY: all test clean
.PRECIOUS: %.o
