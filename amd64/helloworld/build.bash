#!/bin/bash

yasm -f elf64 -g dwarf2 -l main.lst main.asm
ld -o main main.o
