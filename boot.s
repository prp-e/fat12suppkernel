bits  16              ; We are still in 16 bit Real Mode

org   0x7c00            

start:          jmp loader          


bpbOEM                  db "FAT12SP"      
bpbBytesPerSector:      DW 512
bpbSectorsPerCluster:   DB 1
bpbReservedSectors:     DW 1
bpbNumberOfFATs:        DB 2
bpbRootEntries:         DW 224
bpbTotalSectors:        DW 2880
bpbMedia:               DB 0xF0
bpbSectorsPerFAT:       DW 9
bpbSectorsPerTrack:     DW 18
bpbHeadsPerCylinder:    DW 2
bpbHiddenSectors:       DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber:          DB 0
bsUnused:               DB 0
bsExtBootSignature:     DB 0x29
bsSerialNumber:         DD 0xa0a1a2a3
bsVolumeLabel:          DB "MOS FLOPPY "
bsFileSystem:           DB "FAT12   "

msg db  "Welcome to My tiny operating system, it can now support FAT12 filesystem", 0x0D, 0x0A, 0
buffer times 64 db 0
prompt db ">> ", 0
print:
  lodsb
  or      al, al        
  jz      print_end     
  mov     ah, 0eh       
  int     10h
  jmp     print
print_end:
  ret

get_string:
 xor cl, cl
 .loop:
   mov ah, 0
   int 0x16

   cmp al, 0x08
   je .backspace
   
   cmp al, 0x0D
   je .done
   
   cmp cl, 0x3F
   je .loop
   
   mov ah, 0x0e
   int 0x10

   stosb
   inc cl
   jmp .loop

   .backspace:
    cmp cl, 0
    je .loop

    dec di
    mov byte [di], 0
    dec cl
    
    mov ah, 0x0e
    mov al, 0x08
    int 0x10

    mov al, ' '
    int 0x10

    mov al, 0x08
    int 0x10

    jmp .loop

    .done:
      mov al,0
      stosb
      
      mov ah, 0x0e
      mov al, 0x0d
      int 0x10
      mov al, 0x0a
      int 0x10

      ret

strcmp:
 .loop:
  mov al, [si]
  mov bl, [di]
  cmp al, bl
  jne .notequal

  cmp al, 0
  je .done

  inc di
  inc si

  jmp .loop

  .notequal:
   clc
   ret
  .done:
    stc
    ret

 

loader:
  xor ax, ax    
  mov ds, ax   
  mov es, ax   
      
  mov si, msg   
  call print 
mainloop:
  mov si, prompt
  call print

  mov di, buffer
  call get_string

  mov si, buffer
  cmp byte [si], 0
  je loader

  xor ax, ax    
  int 0x12
  jmp mainloop

  cli     
  hlt     

times 510 - ($-$$) db 0   

dw 0xAA55     
