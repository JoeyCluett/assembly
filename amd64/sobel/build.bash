#!/bin/bash


yasm -f elf64 -l sobel_gp.lst   sobel_gp/main.asm   -o sobel_gp.o
yasm -f elf64 -l sobel_simd.lst sobel_simd/main.asm -o sobel_simd.o
yasm -f elf64 -l sobel.lst      main.asm           -o sobel.o

gcc -c -o main.o main.c
gcc -o main main.o sobel_gp.o sobel_simd.o sobel.o
