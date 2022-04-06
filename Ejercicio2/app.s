// Este programa muestra un cuadrado magenta
// que rebota cada vez que se choca con una pared
// 
// No cumple con las condiciones de la entrega (al 
// menos tres colores y dos figuras distintas) peero
// lo mandamos igual porque
// a) nos gustó hacerlo :) y
// b) lo hagamos o no, no promocionamos por las notas
// de los parciales
// 
// El código se ve desorganizado porque para hacer llamados
// de subrutinas limpios con BL necesitabamos hacer solo un
// nivel de anidado, y si no la otra era implementar
// un stack y todo (y no nos daba el tiempo ni la voluntad
// ni el cerebro para andar ensamblando semejantes cosas)
// así que está todo medio lleno de gotos

.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGHT, 	480
.equ BITS_PER_PIXEL,  	32
.equ SQUARE_SIDE,       32

.globl main

main:
	// X0 contiene la direccion base del framebuffer
 	mov x20, x0	// Save framebuffer base address to x20	
	//---------------- CODE HERE ------------------------------------

	movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00

	movz x13, 0xC7, lsl 16
	movk x13, 0x1815, lsl 00

	mov x1, 100 // x
	mov x2, 300 // y
	mov x3, 1 // dx
	mov x4, 1 // dy
	mov x5, SCREEN_HEIGHT
	mov x6, SCREEN_WIDTH
	mov x7, SQUARE_SIDE
	mov x11, SQUARE_SIDE
	mov x8, 4 // pixel width in memory words


	b stepSquare

/*
rdc:
	sub x14, x14, 1
	b stepSquare
*/

timer:
	mov x17, 5200
	b loopTimer

loopTimer:
	sub x17, x17, 1
	cmp x17, 0
	bgt loopTimer
	ble stepSquare


hitTop:
	mov x4, 1
	mov x2, 1
	b checkBottom

checkTop:
	cmp x2, 0
	ble hitTop
	bgt checkBottom

hitBottom:
	mov x4, -1
	mov x2, 447
	b checkLeft

checkBottom:
	mov x12, SCREEN_HEIGHT // the square shouldn't be more than 
	sub x12, x12, x2
	sub x12, x12, SQUARE_SIDE
	cmp x12, 0
	ble hitBottom
	bgt checkLeft

hitLeft:
	mov x3, 1
	mov x1, 1
	b checkRight

checkLeft:
	cmp x1, 0
	ble hitLeft
	bgt checkRight 

hitRight:
	mov x3, -1
	mov x1, 607
	b beginRow

checkRight:
	mov x12, SCREEN_WIDTH
	sub x12, x12, x1
	sub x12, x12, SQUARE_SIDE
	cmp x12, 0
	ble hitRight
	bgt beginRow

enterPink:
	movz x10, 0xC7, lsl 16
	movk x10, 0x1815, lsl 00
	mov x7, SQUARE_SIDE
	b draw1

exitPink:
	movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00
	mov x7, 640
	sub x11, x11, 1
	b draw2

beginRow:
	sub x9, x9, 1
	mov x6, SCREEN_WIDTH
	cmp x5, 0
	ble timer
	sub x5, x5, 1
	mov x7, x1 // para saber cuanto te falta para llegar a x
	cmp x9, 0
	bgt draw3
	cmp x11, 0
	ble draw3
	b draw2

draw2:
	stur w10, [x0]
	sub x6, x6, 1
	add x0, x0, 4
	sub x7, x7, 1
	cmp x7, 0
	ble enterPink
	cmp x6, 0
	ble beginRow // que pasa si x6 y x7 son 0? Ah, despues del primer loop ya seteo x6 a no 0
	b draw2
	 
draw3:
	stur w10, [x0]
	sub x6, x6, 1
	add x0, x0, 4
	cmp x6, 0
	ble beginRow
	bgt draw3

draw1:
	stur w10, [x0]
	sub x6, x6, 1
	add x0, x0, 4
	sub x7, x7, 1
	cmp x7, 0
	ble exitPink
	cmp x6, 0
	ble beginRow
	b draw1

stepSquare:
	//cbnz x14, rdc
	// mov x14, 0xFFFF
	add x1, x1, x3
	add x2, x2, x4
	mov x0, x20
	mov x5, SCREEN_HEIGHT
	mov x6, SCREEN_WIDTH
	mov x7, x1
	mov x9, x2
	mov x11, SQUARE_SIDE
	movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00
	b checkTop

	//---------------------------------------------------------------
	// Infinite Loop 

InfLoop: 
	b InfLoop
