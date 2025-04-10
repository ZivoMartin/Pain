nasm:
	nasm -f elf64 -g src/main.asm && ld src/main.o -static -o main && ./main ; echo $?

clean:
	rm main solus  *.o src/*.o
