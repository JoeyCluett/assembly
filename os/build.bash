#!/bin/bash

yasm -f elf32 loader.asm
ld -T link.ld -melf_i386 loader.o -o kernel.elf
#cp stage2_eltorito iso/boot/grub/
cp kernel.elf iso/boot/

genisoimage -R                      \
    -b boot/grub/stage2_eltorito    \
    -no-emul-boot                   \
    -boot-load-size 4               \
    -A os                           \
    -input-charset utf8             \
    -quiet                          \
    -boot-info-table                \
    -o os.iso                       \
    iso
