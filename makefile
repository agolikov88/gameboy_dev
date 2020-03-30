all:
	rgbasm -o main.o main.asm
	rgblink -o tech_demo.gb main.o
	rgbfix -v -p 0 tech_demo.gb