;*******************************************************************************
;	DiskIO.asm - x86 Assembly Disk IO Functions
;						
;
;       Copyright (c) Davan Etelamaki
;
;	Purpose:
;       To provide the functions needed for disk access
;
;*******************************************************************************


;********************************************************************************
;	disk_load
;	Purpose:
;      To load sectors from a disk
;			Prototype:
;				void disk_load(byte address, byte sectors, byte drive);
;			Algorithm:
;				void disk_load(byte address, byte sectors, byte drive)
;					try{
;						int sectors_loaded = BIOS_INT_0X13(0x02, address, drive, sectors, 0, 0, 0);
;						if(sectors_loaded != sectors){
;							Disk_Error()
;						}
;					}
;					catch
;					{
;						Disk_Error();
;					}
;				}
;				
;	Entry:
;       Byte address in register ES:BX, Byte sectors in register DH, Byte drive in register DL
;	Exit:
;       None
;	Uses:
;		BX, DX
;	Exceptions:
;		Disk Read Error
;*******************************************************************************
disk_load:
	push ax
	push dx
	mov ah, 0x02 				;BIOS read sector function
	mov al, dh					;Read DH Sectors
	mov ch, 0x00 				;Cylinder 0
	mov dh, 0x00 				;Head 0
	mov cl, 0x02			    ;Sector 2
	
	int 0x13					;BIOS interrupt
	jc disk_error				;If there was an error flagged by the BIOS display an error message

	pop dx 						;Pop DX from the stack
	cmp dh, al 					;Compare the number of sectors loaded to the number requested
	jne disk_error 				;If they do not match there was a disk read error
	pop ax
ret

%ifdef Stage2
;********************************************************************************
;	disk_save
;	Purpose:
;      To save sectors to a disk
;			Prototype:
;				void disk_save(byte address, byte sectors, byte drive);
;			Algorithm:
;				void disk_save(byte address, byte sectors, byte drive)
;					try{
;						int sectors_saved = BIOS_INT_0X13(0x03, address, drive, sectors, 0, 0, 0);
;						if(sectors_saved != sectors){
;							Disk_Error()
;						}
;					}
;					catch
;					{
;						Disk_Error();
;					}
;				}
;				
;	Entry:
;       Byte address in register ES:BX, Byte sectors in register DH, Byte drive in register DL
;	Exit:
;       None
;	Uses:
;		BX, DX
;	Exceptions:
;		Disk Read Error
;*******************************************************************************
disk_save:
	push ax
	inc dh
	push dx
	mov di, 0 					;Clear out DI
	mov es, di 					;Clear out ES

	sub bx, 0x8000 				;Remove our offset

	mov cl, 9 					;Put 9 in cl to for our shift 
	shr bx, cl 					;Shift right by 9 essentially dividing by 512
	mov al, bl 					;Store the starting sector in dx
	add al, 2 					;We start at sector 2

	mov cl, 9 					;Put 9 in cl for our next shift
	shl bx, cl 					;Shift left by 9 essentially multiplying by 512 this puts us as the start of the sector before the code to save

	add bx, 0x8000				;Add our offset back in

	mov cl, al 					;Set our starting Sector
	mov ah, 0x03 				;BIOS write sector function
	mov al, dh					;Read DH Sectors
	mov ch, 0x00 				;Cylinder 0
	mov dh, 0x00 				;Head 0
	
	int 0x13					;BIOS interrupt
	jc disk_error				;If there was an error flagged by the BIOS display an error message

	pop dx 						;Pop DX from the stack
	cmp dh, al 					;Compare the number of sectors loaded to the number requested
	jne disk_error 				;If they do not match there was a disk read error
	pop ax
ret
%endif

disk_error:
	mov bx, DISK_ERROR_MSG
	call print_string
	cli
	hlt


DISK_ERROR_MSG db " Disk read error !", 13, 10, 0
