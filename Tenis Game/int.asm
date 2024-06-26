;-----------------------------------------------------------------------
; Programa TSR que se instala en el vector de interrupciones 09h
; que cierra el programa al presionar la tecla 'Q'
; Se debe generar el ejecutable .COM con los siguientes comandos:
;    tasm tsr2.asm
;    tlink /t tsr2.obj
;-----------------------------------------------------------------------
.8086
.model tiny        ; Definicion para generar un archivo .COM
.code
   org 100h        ; Definicion para generar un archivo .COM
start:
   jmp main        ; Comienza con un salto para dejar la parte residente primero

;------------------------------------------------------------------------
;- Parte que queda residente en memoria y contiene las ISR
;- de las interrupciones capturadas
;------------------------------------------------------------------------
OldKeyboardISR dw 0
OldKeyboardISR_SEG dw 0

KeyboardISR PROC FAR
    push ax
    push dx

    in al, 60h            ; Leer el scancode de la tecla presionada
    cmp al, 34h           ; Comparar con el scancode de '.'
    je ExitProgram        ; Si es '.', salir del programa

    ; Llamar a la ISR original del teclado
    pushf
    call dword ptr cs:[OldKeyboardISR]

    pop dx
    pop ax
    iret

ExitProgram:
    mov ah, 00h
    mov al, 00h
    int 10h
    mov ax, 4C00h         ; Terminar el programa y volver al DOS
    int 21h
    iret
KeyboardISR ENDP

FinResidente LABEL BYTE 
;------------------------------------------------------------------------
; Datos a ser usados por el Instalador
;------------------------------------------------------------------------
Cartel    DB "Programa Instalado exitosamente!!!",0dh, 0ah, '$'

main:
; Se apunta todos los registros de segmentos al mismo lugar CS.
    mov ax,CS
    mov DS,ax
    mov ES,ax

InstalarInt:
    ; Guardar la ISR actual del teclado
    mov ax,3509h
    int 21h
    mov [OldKeyboardISR], bx
    mov [OldKeyboardISR_SEG], es

    ; Instalar nuestra nueva ISR del teclado
    mov ax,2509h
    mov dx, offset KeyboardISR
    int 21h

MostrarCartel:
    mov dx, offset Cartel
    mov ah, 9
    int 21h

DejarResidente:        
    mov     AX,(15+offset FinResidente) 
    shr     AX,1            
    shr     AX,1        ; Se obtiene la cantidad de paragraphs
    shr     AX,1
    shr     AX,1        ; ocupado por el codigo
    mov     DX,AX           
    mov     AX,3100h    ; y termina sin error 0, dejando el
    int     21h         ; programa residente
end start
