; =============================================================================
; @file HELLO86.ASM
; @brief 16-bit 8086 MASM Assembly Test Program for MS-DOS 1.25, 2.0, and 4.00
; @description
;   Prints a greeting banner over DOS INT 21h AH=09h and exits cleanly via
;   INT 21h AH=4Ch AL=00h (with INT 20h fallback for MS-DOS 1.25).
; =============================================================================

CODE    SEGMENT PARA PUBLIC 'CODE'
        ASSUME  CS:CODE, DS:CODE, ES:CODE, SS:CODE
        ORG     100H

START:
        MOV     DX, OFFSET MSG
        MOV     AH, 09H
        INT     21H

        MOV     AX, 4C00H
        INT     21H
        INT     20H

MSG     DB      'Hello from 16-bit 8086 MS-DOS (1.25 / 2.0 / 4.00) inside Bento!', 0DH, 0AH, '$'

CODE    ENDS
        END     START
