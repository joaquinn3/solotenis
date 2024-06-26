@echo off
cd C:\Tasm 1.4\Tasm
tasm main.asm
tasm lib.asm
tasm int.asm
tlink main lib
tlink /t int
int
main.exe
