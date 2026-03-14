

# How to run ?
## Assemble with nasm :
```
nasm -f elf64 keylogger.asm
```
*transform assembly into opcodes*

## Link with ld
```
ld keylogger.o -o keylogger
```
*combines the opcodes files to create the executable*

## Run as root and release the terminal
```
sudo ./keylogger </dev/null &
```

## One-line launch
```
nasm -f elf64 keylogger.asm ; ld keylogger.o -o keylogger ; sudo ./keylogger </dev/null &
```
