snake: snake.o
	gcc -o snake snake.o -no-pie
snake.o: snake.asm
	nasm -f elf64 -g -F dwarf -o snake.o snake.asm
