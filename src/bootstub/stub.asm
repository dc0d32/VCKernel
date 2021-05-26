
; irrespective of whether we are (chain)loaded from Windows bootloader or through PXE, we are loaded at 7c0:0
[org 7c00h]
; because i386 is old :P
[CPU P4]


NULL_SEG equ 00h    ; unused
CODE_SEG equ 08h    ; cs
DATA_SEG equ 10h    ; all other segments

section .text
[bits 16]
_entry:
        cli ; no interrupts
        xor ax, ax
        mov ds, ax
        
        lgdt [gdt_desc] ; load GDTR
        mov eax, cr0
        or al, 1
        mov cr0, eax    ; set pmode bit
        jmp CODE_SEG:clear_pipeline ; far jump ensures a prefetch queue flush and truely enter pmode

[bits 32]
clear_pipeline:
        mov ax, DATA_SEG
        mov ds, ax
        mov es, ax
        mov ss, ax
        lea esp, [initial_stack_top]
        jmp chain

chain:
        mov byte [0b8000h], '1'     ; just some on-screen deubgging
        mov byte [0b8001h], 01bh

        EXELOADADDR    equ PAYLOAD_ADDRESS  ; the load address of payload (kernel) exe
    ; PE header offsets
        sigMZ         equ esi
        PEheaderOffset   equ esi+60
        sigPE         equ esi
        NumSections      equ esi+6
        BaseOfCode      equ esi+52
        EntryAddressOffset   equ esi+40
        SizeOfNT_HEADERS   equ 248

        SectionSize      equ esi+8
        SectionBase      equ esi+12
        SectionFileOffset   equ esi+20
        SizeOfSECTION_HEADER   equ 40

        mov esi, EXELOADADDR
        mov eax, [sigMZ]
        cmp ax, 0x5A4D  ; signature check
        jnz badPE
        mov eax, [PEheaderOffset]
   
        add esi, eax
        mov eax, [sigPE]
        cmp eax, 0x00004550
        jnz badPE
   
        xor edx, edx
        mov dx, [NumSections]
        mov eax, [BaseOfCode]
        mov ebx, [EntryAddressOffset]
   
        add ebx, eax
        push ebx
   
        add esi, SizeOfNT_HEADERS

    ; load each section
        .loadloop:
				inc BYTE [0xB8000]
                mov ecx, [SectionSize]
                mov edi, [SectionBase]
                add edi, eax
                mov ebx, [SectionFileOffset]
                add ebx, EXELOADADDR
   
                push esi
   
                mov esi, ebx
                rep movsb       ; copy each section to its respective load/run address
   
                pop esi
                add esi, SizeOfSECTION_HEADER
   
                dec edx
                or edx, edx
                jnz .loadloop

				mov ecx, 0xB8000
				mov BYTE [ecx], 'X'
                pop ebx ; restore entry
                jmp ebx ; jump to entry

; PE image invalid
badPE:
        mov eax, 0b8000h
        mov byte [eax], '!'
        mov byte [eax + 1], 01bh

; spin away!    
infloop:
        hlt
        jmp infloop

; data section
section .data
initial_stack:
        times 128 dw 0  ; oughtta be enough
initial_stack_top:

; global descriptor table
gdt:
gdt_null:
    dd 0
    dd 0

gdt_code:
    dw 0FFFFh   ; RTFM
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

gdt_data:
    dw 0FFFFh
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0
gdt_end:


gdt_desc:                       ; The GDT register
    dw gdt_end - gdt - 1    ; Limit (size)
    dd gdt                  ; Address of the GDT

align 4
PAYLOAD_ADDRESS:    ; this is where the exe is loaded
