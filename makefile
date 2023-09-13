snake: snake.o field.o control.o helpers.o
	gcc -o snake snake.o field.o control.o helpers.o -no-pie
snake.o: snake.asm
	nasm -f elf64 -g -F dwarf -o snake.o snake.asm
field.o: field.asm
	nasm -f elf64 -g -F dwarf -o field.o field.asm
control.o: control.asm
	nasm -f elf64 -g -F dwarf -o control.o control.asm
helpers.o: helpers.asm
	nasm -f elf64 -g -F dwarf -o helpers.o helpers.asm
