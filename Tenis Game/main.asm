.8086
.model small
.stack 100h
.data
	
	SegundosInicio db 0

.code
	main proc
	mov ax, @data
	mov ds, ax

extrn ConfiguracionEntorno:proc
extrn CompararTiempo:proc
extrn PelotaDibujo:proc
extrn MovimientoPelota:proc
extrn NaveDibujo:proc
extrn MoverNave:proc
extrn PegarPelota:proc
extrn DibujarPuntos:proc
extrn Menu:proc
	
	call ConfiguracionEntorno

	xor bx, bx
	;En bx tengo el codigo, 1 para jugar 0 para salir
	call Menu

	cmp bx, 1
	je Comparar

	cmp bx, 0
	je Fin

Comparar:
	xor ax, ax
	xor bx, bx
	lea bx, SegundosInicio
	mov al, SegundosInicio
	call CompararTiempo

	cmp al, SegundosInicio
	jne Juego

	jmp Comparar

Juego:
	;call ConfiguracionEntorno ; Para limpiar pantalla
	call MovimientoPelota
	call PelotaDibujo
	call NaveDibujo
	call MoverNave
	call PegarPelota
	call MoverNave
	call DibujarPuntos

	jmp Comparar

Fin:
	mov ah, 00h
	mov al, 00h
	int 10h

	mov ax, 4c00h
	int 21h
	main endp
end