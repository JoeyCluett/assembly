#!/bin/bash

gcc -m32 -S main.c
gcc -m32 -o main ../printinteger.o main.c

