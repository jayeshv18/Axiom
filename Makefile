#Tell Make that 'run' and 'clean' aren't actual files, just commands
.PHONY: all run clean

#The default command if you just type 'make'
all: build/os.img

#Create the build directory if it doesn't exist
build:
	mkdir -p build

#Compile Stage 1
build/boot.bin: src/boot/boot.asm | build
	nasm -f bin src/boot/boot.asm -o build/boot.bin

#Compile Stage 2
build/boot2.bin: src/boot/boot2.asm | build
	nasm -f bin src/boot/boot2.asm -o build/boot2.bin

#Compile the Assembly Bridge
build/kernel_entry.o: src/kernel_entry.asm | build
	nasm -f elf32 src/kernel_entry.asm -o build/kernel_entry.o

#Compile the C Kernel
build/kernel.o: src/kernel.c | build
	gcc -m32 -I include -ffreestanding -fno-pie -fno-pic -c src/kernel.c -o build/kernel.o

#Link the Kernel
build/kernel.bin: build/kernel_entry.o build/vga_print.o build/string.o build/idt_asm.o build/idt.o build/isr_asm.o build/isr.o build/kernel.o
	ld -m elf_i386 -T linker.ld -o build/kernel.bin build/kernel_entry.o build/vga_print.o build/string.o build/idt_asm.o build/idt.o build/isr_asm.o build/isr.o build/kernel.o

build/vga_print.o: src/vga_print.c | build
	gcc -m32 -I include -ffreestanding -fno-pie -fno-pic -c src/vga_print.c -o build/vga_print.o

#Compile the String Library
build/string.o: src/string.c | build
	gcc -m32 -I include -ffreestanding -fno-pie -fno-pic -c src/string.c -o build/string.o

#Compile the IDT C Logic
build/idt.o: src/idt.c | build
	gcc -m32 -I include -ffreestanding -fno-pie -fno-pic -c src/idt.c -o build/idt.o

#Compile the IDT Assembly Bridge
build/idt_asm.o: src/idt_asm.asm | build
	nasm -f elf32 src/idt_asm.asm -o build/idt_asm.o

#Fuse the Final OS Image
build/os.img: build/boot.bin build/boot2.bin build/kernel.bin
	cat build/boot.bin build/boot2.bin build/kernel.bin > build/os.img

build/isr_asm.o: src/isr.asm | build
	nasm -f elf32 src/isr.asm -o build/isr_asm.o

build/isr.o: src/isr.c | build
	gcc -m32 -I include -ffreestanding -fno-pie -fno-pic -c src/isr.c -o build/isr.o

#Boot the OS in QEMU
run: build/os.img
	qemu-system-i386 -fda build/os.img

#Nuke the build folder to start fresh
clean:
	rm -rf build/*