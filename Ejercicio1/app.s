.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,  	32

// el algoritmo dibuja el logo del disco "The Dark Side on the Moon" de Pink Floyd
    
.globl main
main:
	// X0 contiene la direccion base del framebuffer
 	mov x20, x0	// Save framebuffer base address to x20	
	// ----------------------- CODE HERE ------------------------------------
	
	movz x10, 0x0000, lsl 16
	movk x10, 0x000f, lsl 00
	
	mov x2, SCREEN_HEIGH         // Y Size 
loop1:
	mov x1, SCREEN_WIDTH         // X Size
loop0:
	stur w10,[x0]	   // Set color of pixel N
	add x0,x0,4	       // Next pixel
	sub x1,x1,1	       // decrement X counter
	cbnz x1,loop0	   // If not end row jump
	sub x2,x2,1	       // Decrement Y counter
	cbnz x2,loop1	   // if not last row, jump


	//dibuja el haz de luz blanco que entra al prisma
	bl luz
	
    //dibuja la desfragmentacion de los colores saliendo del prisma
	bl seis_colores
	
    //dibuja un triangulo blanco para hacer los bordes del prisma, los valores anteriores a la llamada son los que se necesitan
	mov x5, 190 // altura
	mov x3, 300 // posicion esquina X
	mov x4, 100 // posicion esquina Y
	movz x11, 0x00ff, lsl 16
	movk x11, 0xffff, lsl 00
	BL triangulo
	
	//dibuja un triangulo negro mas chico que el anterior para hacer el interior del prisma

	mov x5, 160 // altura
	mov x3, 300 // posicion esquina X
	mov x4, 120 // posicion esquina Y
	movz x11, 0x0000, lsl 16
	movk x11, 0x0000, lsl 00
	BL triangulo

	b fin
	
	// --- AUXILIARES ---


//-------------------------------------------------------------------

// Los registros se inicializados contienen: la posicion del primer rectangulo del haz (abajo y a la izquierda),
// los valores de hancho y largo de cada rectangulo del haz, y el color blanco

// dibuja el haz de luz utilizando iterativamente llamadas a la funcion que dibuja un rectangulo,
// durante las itereaciones se modifican los valores de inicio de cada rectangulo procurando dar la forma correcta al haz de luz

luz:
	sub sp, sp, 8
	stur lr, [sp, 0] 
	
	movz x11, 0x00ff, lsl 16
	movk x11, 0xffff, lsl 00
	
	mov x2, 10 // largo
	mov x1, 40 // ancho
	mov x3, 20 // posicion esquina X
	mov x4, 210 // posicion esquina y
	
loop_l:	
	BL rectangulo
	sub x4, x4, 10 
	add x3, x3, 30
	
	cmp	x3, 240
	b.le loop_l 
	
	ldur lr, [sp, 0]
	add sp, sp, 8
	br lr

//-------------------------------------------------------------------


// los valores inicializados contienen los mismos datos que en el caso del haz de luz, 
// se distingue el valor del registro x13, usado para determinar que color del arco a pintar

seis_colores:
	sub sp, sp, 8
	stur lr, [sp]

	mov x2, 10   // largo
	mov x1, 40  // ancho
	mov x3, 310 // posicion esquina X
	mov x4, 120 // posicion esquina y
	mov x13, 6  // el 6 equivale al rojo en la funcion elegir color
	
un_color:
	bl elegir_color	
	mov x5, x3 //guarda el valor de x3
	add x6, x4, 10 //guarda el valor de la nueva franja que comienza mas abajo 
	

	//dibuja un haz completo de un solo color, lo hace bajo la misma idea que en la funcion luz
loop_color:	
	BL rectangulo
	add x4, x4, 10
	add x3, x3, 30
	cmp x3, 600
	b.le loop_color
	
	mov x3, x5  // recupera el valor donde comienza el primer rectangulo del arco
	mov x4, x6  // recupera el valor del siguiente rectangulo
	cbnz x13, un_color // si quedan colores por pintar vuelve al ciclo
	

	ldur lr, [sp]
	add sp, sp, 8
	br lr
	
//-------------------------------------------------------------------


// la funcion se encarga de elegir el color del arco que se va a pintar
// lo hace comparando el valor del x13 para decidir si esta en el color correcto o debe seguir buscandolo
// una vez tiene el valor correcto decrementa en uno x13
// cuando x13 es igual a cero, ya no hay mas colores para elegir 
// funciona como un if con varios elseif

elegir_color:
	sub sp, sp, 8
	stur lr, [sp]
	
rojo:
	cmp x13, 6
	b.ne naranja
	movz x11, 0x00ff, lsl 16
	movk x11, 0x0003, lsl 00
	sub x13, x13, 1
	b elegi
	
naranja:
	cmp x13, 5
	b.ne amarillo
	movz x11, 0x00ff, lsl 16
	movk x11, 0x6800, lsl 00
	sub x13, x13, 1
	b elegi

amarillo:
	cmp x13, 4
	b.ne verde
	movz x11, 0x00ff, lsl 16
	movk x11, 0xff00, lsl 00
	sub x13, x13, 1
	b elegi

verde:	
	cmp x13, 3
	b.ne azul
	movz x11, 0x0000, lsl 16
	movk x11, 0xff0f, lsl 00
	sub x13, x13, 1	
	b elegi

azul:
	cmp x13, 2
	b.ne violeta
	movz x11, 0x0000, lsl 16
	movk x11, 0x26cf, lsl 00
	sub x13, x13, 1
	b elegi

violeta:
	movz x11, 0x0078, lsl 16
	movk x11, 0x00c1, lsl 00
	sub x13, x13, 1
	b elegi	

elegi:
	ldur lr, [sp]
	add sp, sp, 8
	br lr
	
//-------------------------------------------------------------------


// dibuja un rectangulo, los parametros que necesita estan en los registros x1,x2,x3,x4 siendo estos valores el ancho, largo, posicion inicial en el eje x, posicion inicial en el eje y; respectivamente

//guarda en x15, x16 los limites finales del rectangulo siendo x15 = ancho + posicion inicial en el eje x. Y x16 = largo + posicion inicial en el eje y
//uso estos valores para saber cuando vuelvo a entrar a un ciclo y cuando no.
//por cada iteracion encuentra un pixel dentro del cuadrado y lo pinta

rectangulo:
	sub sp, sp, 48
	stur x5, [sp, 40]
	stur x13, [sp, 32]
	stur lr, [sp, 24]
	stur x7, [sp, 16] 
	stur x4, [sp, 8]
	stur x3, [sp, 0]
	
	add x15, x3, x1  
	add x16, x4, x2  
	mov x9, x3      
	mov x13, 3
	
c_loopy:
	mov x3, x9
c_loopx:
	stur w11, [x7]
	add x3, x3, 1
	bl setpixel //encuentra segun x2 y x3, cual es el pixel en esa posicion de la pantalla
	cmp x3, x15
	b.LE c_loopx
	add x4, x4, 1
	cmp x4, x16
	b.LE c_loopy

	stur w11, [x7]
	
	ldur x5, [sp, 40]
	ldur x13, [sp, 32]
	ldur lr, [sp,24]
	ldur x7, [sp,16]
	ldur x4, [sp,8]
	ldur x3, [sp,0]
	add sp, sp, 48
	br lr
 
//-------------------------------------------------------------------

// dibuja un triangulo: usa como parametros de entrada los registros x3, x4, x5 siendo posicion inicial en el eje X, posicion inicial en el eje Y, altura; respectivamente
//la posicion inicial es la punta del triangulo, por cada iteacion empieza un pixel más a la izquerda y llega a la derecha que la iteracion anterior.
//x5 es usada como un indice en un ciclo for, que va desde la altura hasta al cero 
 

triangulo:
	sub sp, sp, 24
	stur lr, [sp]	
	stur x3, [sp, 8]
	stur x4, [sp, 16]
	
	mov x9, x3
	mov x1, x3
	mov x2, x4
	
t_loopy:
	mov x3, x9
t_loopx:
	bl setpixel
	stur w11, [x7]
	add x3, x3, 1
	cmp x3, x1
	b.le t_loopx
	sub x9, x9, 1
	add x1, x1, 1
	add x4, x4, 1
	sub x5, x5, 1
	cbnz x5, t_loopy

	ldur lr, [sp]
	ldur x3, [sp, 8]
	ldur x4, [sp, 16]
	add sp, sp, 24
	br lr
	
//-------------------------------------------------------------------

// calcula el valor correspondiente a un pixel dadas coordenas (x, y) guardas en x3 y x4 respectivamente
// realiza la siguiente operacion:
// pixel = 4 * [x + (y * 640)] + posicion cero del frame_buffer
// no pinta el pixel, solo lo encuentra y lo retorna en el registro x7 para ser usado en otra funcion

setpixel:
    sub sp, sp, 48
    stur x6, [sp, 40]
    stur x9, [sp, 32]
    stur lr, [sp, 24] 
	stur x4, [sp, 8]
	stur x3, [sp, 0]    
	
	mov x9, 640
	mul x6, x4, x9
	add x7, x6, x3
	mov x9, 4 
	mul x7, x7, x9              
	add x7, x7, x20
    
    ldur x6, [sp, 40]
    ldur x9, [sp, 32]
    ldur lr, [sp, 24]
	ldur x4, [sp, 8]
	ldur x3, [sp, 0]
	add sp, sp, 48   
	br lr
	
	
	//el timer esta solo por que el loop infinito sobreforzaba la cpu
timer:
	mov x5, 25471
loop_timer:
	sub x5, x5, 1
	cbnz x5, loop_timer
	b fin

//---------------------------------------------------------------

	// Infinite Loop 
fin:
b timer

InfLoop: 
	b InfLoop
