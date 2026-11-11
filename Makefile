TOP      := gb_fpga_top
FILE	 := gb_fpga.v
SFML_DIR = $(HOME)/SFML-3.1.0

SFML_CFLAGS := -std=c++17 -I$(SFML_DIR)/include
SFML_LIBS   := -L$(SFML_DIR)/lib -Wl,-rpath,$(SFML_DIR)/lib -lsfml-graphics -lsfml-window -lsfml-system

VFLAGS := --cc --exe --build -j 2 -O3 -I. --top-module $(TOP)
BIN    := obj_dir/V$(TOP)

all: $(BIN)

$(BIN): $(wildcard *.v) sim_main.cpp constants.h
	verilator $(VFLAGS) -CFLAGS "$(SFML_CFLAGS)" -LDFLAGS "$(SFML_LIBS)" $(FILE) sim_main.cpp

run: $(BIN)
	./$(BIN)

clean:
	rm -rf obj_dir

.PHONY: all run clean
