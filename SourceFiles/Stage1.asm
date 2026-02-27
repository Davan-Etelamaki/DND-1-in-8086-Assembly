; Stage1 boot sector — DND-1 8086 Assembly port. Loads Stage2 from sectors 2+ to 0x8000 and jumps.
[BITS 16]
[ORG 0x7C00]
[CPU 8086]
%define LightGrayOnBlack 0x07
%define Stage1
main:
	mov [BOOT_DRIVE], dl
	xor ax, ax						;clear ax
	mov ds, ax						;clear ds
	mov ss, ax						;start the stack at 0
	mov bp, 0x7F00					;move the stack pointer to 0x2000 past the start
	mov sp, bp
	push es
	call clear_screen

	mov bx, BootString
	call print_string

	mov bx, LoadingSectors
	call print_string
	pop es
	mov bx, 0x8000 					;Set our starting address to 0x8000
	mov dh, 60 						;Load 99 more sectors
	mov dl, [BOOT_DRIVE] 			;Set our drive to the boot drive
	call disk_load 					;Perform the load operation

	mov bx, SectorsLoaded
	call print_string

	mov dl, [BOOT_DRIVE]
	jmp 0x8000					;Jump to our newly loaded code

	cli								;Disable Interrupts
	hlt								;Halt the Processor
	
%include "Libraries/Graphics/Print.asm"
%include "Libraries/IO/DiskIO.asm"

BOOT_DRIVE 			db 0

BootString 			db 'Booting', 13, 10, 0
LoadingSectors 		db 'Loading Sectors from Memory', 13, 10, 0
SectorsLoaded 		db 'Sector Load Complete', 13, 10, 0

times 510-($-$$) 	db 0
dw 0xAA55