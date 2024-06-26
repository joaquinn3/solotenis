.8086
.model small
.stack 100h
.data


	;VARIABLES PARA EL CAMBIO DE COLOR
	NumeroColor dw 0 
	ColoresPelota db 36h, 0fh, 30h, 19h, 37h, 01h, 08h, 39h, 37h, 17h, 06h
	ColoresNave   db 36h, 0fh, 30h, 19h, 37h, 01h, 08h, 39h, 37h, 17h, 06h
	
	;VARIABLES PUNTOS
	Puntos db 0
	TextoPuntos db '000', 24h


	;VARIABLES DE JUEGO
	GameOver db 0 ; Game Over 1 Si 0 No
	TextoGameOver db 'Game Over', 24h
	PerdisteTexto db 'Perdiste', 24h
	GanasteTexto db 'Ganaste', 24h
	ReiniciarTexto db 'Presiona R para reiniciar', 24h
	SalirInterrupcion db 'Presiona . para salir', 24h

	;VARIABLES PELOTA
	PelotaX dw 0ah ; X de la pelota
	PelotaY dw 01h ; Y de la pelota
	PelotaSize dw 04h ; Tamaño de la pelota en pixeles
	PelotaParaPantalla dw 03h

	PelotaVelocidadX dw 05h ; Velocidad de la pelota en X
	PelotaVelocidadY dw 05h ; Velocidad de la pelota en Y

	ColorPelota db 0fh

	;VARIABLES NAVE
	NaveX dw 0A0h ; Para dibujar la nave, posición X
	NaveY dw 0B4h ; Posición Y

	NaveWidth dw 0fh; Ancho de la nave
	NaveHeight dw 05h; Alto de la nave

	NaveVelocidad dw 06h ; Velocidad en la que se mueve la nave

	NaveColor db 0fh


	;VARIABLES DE VENTANA
	VentanaWidth dw 140h ; Se que es 320px de ancho, lo paso a hex.
	VentanaHeight dw 0c8h ; 200px de alto, a hex.

	;MENU
	MenuTexto db 'Tenis', 24h
	JugarTexto db 'JUGAR - ENTER', 24h
	SalirTexto db 'SALIR - Q', 24h
	ComoJugar db 'Como Jugar', 24h


.code
	mov ax, @data
	mov ds, ax

public ConfiguracionEntorno
public CompararTiempo
public PelotaDibujo
public MovimientoPelota
public NaveDibujo
public MoverNave
public PegarPelota
public DibujarPuntos
public Menu

	; Tengo en OFFSET BX los segundos iniciales
	; Esta función va comparando los segundos del sistema con el anterior guardado para
	; que el juego este en loop
	CompararTiempo proc
		push ax
		push dx
		push bx

		mov ah, 2ch ; Tengo el horario del sistema
		int 21h ; En DL tengo los segundos

		cmp dl, bl
		je CompararTiempo

		mov [bx], dl

		cmp GameOver, 1
		je GameOverYes

		cmp Puntos, 5
		je ChangeSize

		cmp Puntos, 10
		je ChangeSize2

		jmp FinTiempo

	ChangeSize:
			mov NaveWidth, 0ah
			jmp FinTiempo

	ChangeSize2:
			mov NaveWidth, 04h
			jmp FinTiempo

	GameOverYes:
		call GameOverMenu

	FinTiempo:
		pop bx
		pop dx
		pop ax
		ret
	CompararTiempo endp


	ConfiguracionEntorno proc
		push ax
		push bx

		mov ah, 00h ; Configuro el entorno a modo gráfico
		mov al, 13h ; Elijo el modo gráfico
		int 10h ; Llamo a la interrupcion

		mov ah, 0Bh ; Configuro para el color de fondo
		mov bh, 00h
		mov bl, 00h ; Color de fondo
		int 10h ; Interrupcion

		pop bx
		pop ax
		ret
	ConfiguracionEntorno endp


	PelotaDibujo proc
		push cx
		push dx
		push ax

	Dibuja:
		mov cx, PelotaX ; Columna, posicion X inicial
		mov dx, PelotaY ; Fila, posicion Y inicial

	PelotaDibujoHorizontal:
		mov ah, 0Ch ; Configuro para dibujar pixel gráfico
		mov al, ColorPelota; Color del pixel
		mov bh, 00h ; Numero de pagina
		int 10h

		;Para aumentar el tamaño de la pelota
		inc cx
		mov ax, cx
		sub ax, PelotaX
		cmp ax, PelotaSize
		jl PelotaDibujoHorizontal

		mov cx, PelotaX
		inc dx
		mov ax, dx
		sub ax, PelotaY
		cmp ax, PelotaSize
		jl PelotaDibujoHorizontal


	DibujoFin:

		pop ax
		pop dx
		pop cx
		ret
	PelotaDibujo endp


	MovimientoPelota proc
		push bx
		push ax

	Inicio:
		;PELOTA EN X
		mov ax, PelotaVelocidadX
		add PelotaX, ax

		;Si la pelota llega al borde izquierdo cambio la dirección
		cmp PelotaX, 03h
		jl CambiarDireccionX

		;Si la pelota llega al borde derecho cambio la dirección
		mov ax, VentanaWidth
		sub ax, PelotaSize
		sub ax, PelotaParaPantalla
		cmp PelotaX, ax
		jg CambiarDireccionX

		;PELOTA EN Y
		mov ax, PelotaVelocidadY
		add PelotaY, ax

		;Si la pelota llega al borde superior cambio la dirección
		cmp PelotaY, 02h
		jl CambiarDireccionY

		;Si la pelota llega al borde inferior, game over
		mov ax, VentanaHeight
		sub ax, PelotaSize
		cmp PelotaY, ax
		jg GameOverYes2

		jmp CambioPosicion


	CambioPosicion:
		call ConfiguracionEntorno
		jmp Fin

	CambiarDireccionX:
		neg PelotaVelocidadX
		jmp CambioPosicion

	CambiarDireccionY:
		neg PelotaVelocidadY
		jmp CambioPosicion

	GameOverYes2:
	mov GameOver, 1
	jmp CambiarDireccionY

	Fin:
		pop ax
		pop bx
		ret
	MovimientoPelota endp

	NaveDibujo proc

		push cx
		push dx
		push ax
		push bx

        mov cx, NaveX
        sub cx, NaveWidth
        mov dx, NaveY

        DibujoNaveHorizontal:
            mov ah, 0ch ; Configuro para dibujar pixel gráfico
            mov al, NaveColor ; Color
            mov bh, 00h ; Numero de pagina
            int 10h

            inc cx
            mov ax, cx
            sub ax, NaveX
            mov bx, NaveWidth
            cmp ax, bx 
            jng DibujoNaveHorizontal

            mov cx, NaveX
            sub cx, NaveWidth
            inc dx
            mov ax, dx
            sub ax, NaveY
            cmp ax, NaveHeight

            
            jng DibujoNaveHorizontal

		pop bx
		pop ax
		pop dx
		pop cx
		ret
	NaveDibujo endp

	MoverNave proc
		push ax

	MueveNave:
		; Veo si se apreta una tecla
		mov ah, 01h
		int 16h
		jz MoverNaveFin

		; Que tecla (en AL tengo la tecla)
		mov ah, 00h
		int 16h

		cmp al, 41h ; "A"
		je MoverNaveIzquierda
		cmp al, 61h ; "a"
		je MoverNaveIzquierda

		cmp al, 44h ; "D"
		je MoverNaveDerecha
		cmp al, 64h ; "d"
		je MoverNaveDerecha

		jmp MoverNaveFin

	MoverNaveIzquierda:
		mov ax, NaveVelocidad
		sub NaveX, ax
		;call ConfiguracionEntorno ; Limpio pantalla para que se mueva
		jmp MueveNave

	MoverNaveDerecha:
		mov ax, NaveVelocidad
		add NaveX, ax
		;call ConfiguracionEntorno ; Limpio pantalla para que se mueva
		jmp MueveNave

	MoverNaveFin:

		pop ax
		ret
	MoverNave endp

	PegarPelota proc
		push ax
		push bx

		mov bx, 0

		mov ax, PelotaX
		add ax, PelotaSize
		add ax, 05h
		cmp ax, NaveX
		jng Puente

		mov ax, NaveX
		add ax, NaveWidth
		add ax, 05h
		cmp PelotaX, ax
		jnl Puente

		mov ax, PelotaY
		add ax, PelotaSize
		add ax, 05h
		cmp ax, NaveY
		jng Puente

		mov ax, NaveY
		add ax, NaveHeight
		add ax, 05h
		cmp PelotaY, ax
		jnl Puente

		;Si pego a la pelota
		jmp CambiarDireccion

	Puente:
		jmp FinPelota

	CambiarDireccion:
		;Cambio la dirección
		neg PelotaVelocidadY

		;Puntos
		inc Puntos
		call RegToAscii

		cmp Puntos, 15
		je GameOverSi

		jmp CambioColor


	Reset:
		mov NumeroColor, 0
		jmp FinPelota

	CambioColor:
		xor ax, ax
		mov bx, NumeroColor
		mov al, ColoresPelota[bx]
		mov ColorPelota, al
		mov al, ColoresNave[bx]
		mov NaveColor, al

		inc NumeroColor
		cmp NumeroColor, 11
		je Reset

		jmp FinPelota

	GameOverSi:
		mov GameOver, 1
		jmp FinPelota

	FinPelota:
		pop bx
		pop ax
		ret
	PegarPelota endp


	DibujarPuntos proc
		push ax
		push bx
		push dx

		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 05h ; Fila
		mov dl, 0ah ; Columna
		int 10h


		mov ah, 09h
		lea dx, TextoPuntos
		int 21h

		pop dx
		pop bx
		pop ax
		ret
	DibujarPuntos endp

regToAscii proc
	;Recibe en un registro (cx), el nro a convertir y en bx, el offset de la variable donde almacenará los caracteres
	;que correspondan al nro. 

		push ax
		push cx
		push bx
		pushf

		xor ax, ax
		mov al, Puntos ;CARGO EN EL REGISTRO ACUMULADOR (AX) EL VALOR QUE QUIERO CONVERTIR
		mov cl, 100
		div cl ; AHORA QUE DIVIDÍ EN AH TENGO EL RESTO Y EN AL EL RESULTADO
		add al, 30h ; SUMO 30 h para convertir el nro en caracter ascii

		mov TextoPuntos[0], al
		mov al, ah
		xor ah, ah 
		mov cl, 10
		div cl 
		add al, 30h
		mov TextoPuntos[1], al 
		add ah, 30h
		mov TextoPuntos[2],ah

		popf
		pop bx
		pop cx
		pop ax
		ret 
	regToAscii endp


	GameOverMenu proc
		push ax
		push bx
		push dx

		call ConfiguracionEntorno ; Limpio la pantalla

		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 05h ; Fila
		mov dl, 0eh ; Columna
		int 10h


		mov ah, 09h
		lea dx, TextoGameOver
		int 21h

		cmp Puntos, 15
		jge GanasteMenu

		jmp PerdisteMenu

	GanasteMenu:
		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 08h ; Fila
		mov dl, 0eh ; Columna
		int 10h


		mov ah, 09h
		lea dx, GanasteTexto
		int 21h

		jmp ReiniciarMenu

	PerdisteMenu:
		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 08h ; Fila
		mov dl, 0eh ; Columna
		int 10h


		mov ah, 09h
		lea dx, PerdisteTexto
		int 21h

	ReiniciarMenu:
		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 0Bh ; Fila
		mov dl, 0ah ; Columna
		int 10h


		mov ah, 09h
		lea dx, ReiniciarTexto
		int 21h

	SalirMenuInt:
		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 0Eh ; Fila
		mov dl, 0ah ; Columna
		int 10h


		mov ah, 09h
		lea dx, SalirInterrupcion
		int 21h

	EsperarTecla:
		;Espero a una tecla
		mov ah, 00h
		int 16h

		cmp al, 'R'
		je Reiniciar
		cmp al, 'r'
		je Reiniciar

		jmp EsperarTecla

	Reiniciar:
		mov GameOver, 0
		mov Puntos, 0
		mov TextoPuntos, '0'
		mov NumeroColor, 0
		mov NaveWidth, 0fh
		call RegToAscii
		call ConfiguracionEntorno


		pop dx
		pop bx
		pop ax
		ret
	GameOverMenu endp

	; Muestra el menú, con las opciones y devuelve un codigo para jugar o salir.
	Menu proc
		push ax
		push dx

		call ConfiguracionEntorno

		xor ax, ax
		xor bx, bx
		xor dx, dx
	InicioOpciones:
		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 05h ; Fila
		mov dl, 07h ; Columna
		int 10h


		mov ah, 09h
		lea dx, MenuTexto
		int 21h

	JugarMenu:
		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 07h ; Fila
		mov dl, 04h ; Columna
		int 10h

		mov ah, 09h
		lea dx, JugarTexto
		int 21h

	SalirMenu:
		mov ah, 02h ; Posición del cursor
		mov bh, 00h ; Número de página
		mov dh, 09h ; Fila
		mov dl, 04h ; Columna
		int 10h

		mov ah, 09h
		lea dx, SalirTexto
		int 21h

	EsperarTeclaMenu:
		;Espero a una tecla
		mov ah, 00h
		int 16h

		cmp al, 0dh
		je EmpiezaJuego
		cmp al, 'q'
		je SalirJuego
		cmp al, 'Q'
		je SalirJuego

		jmp EsperarTeclaMenu

	EmpiezaJuego:
		mov bx, 1
		jmp FinMenu

	SalirJuego:
		mov bx, 0
		jmp FinMenu

	FinMenu:	
		pop dx
		pop ax
		ret
	Menu endp


end
