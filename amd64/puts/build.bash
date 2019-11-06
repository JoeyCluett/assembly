#!/bin/bash

yasm -f elf64 -g dwarf2 -l main.lst main.asm -o main.o

# if we define a main, use this command:
gcc -o main main.o
