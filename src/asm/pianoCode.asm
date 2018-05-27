; ******************************************************
; Proyect: Piano with LCD panel
; Author:  Matias Quintana Rosales
; Date:    inicio - 05/10/11
;		     fin    -
;          fecha de entrega - 22/12/11
; ******************************************************

.include "C:\VMLAB\include\m8def.inc"

.equ ddra = $1A
.equ porta = $1B
.equ pina = $19
;Variables para LCD
.def dato = r20
.def instruccion = r21
;Variables para Notas
.def temp_oct_textl = r18
.def temp_oct_texth = r19
.def octava = r22
.def switch = r23
.def freq = r24

;xl = low(freqa*2)  a = {1,2,3,4,5,6,7,8}
;xh = high(freqa*2)

reset:
   rjmp start

titulo:    .db "    Shally's    "
titulo2:   .db "     Piano      "
octava1:   .db "    Octava 1    "
octava2:   .db "    Octava 2    "
octava3:   .db "    Octava 3    "
octava4:   .db "    Octava 4    "
octava5:   .db "    Octava 5    "
octava6:   .db "    Octava 6    "
octava7:   .db "    Octava 7    "
octava8:   .db "    Octava 8    "
nota1:     .db "       Re       "
nota2:     .db "       Mi       "
nota3:     .db "       Fa       "
nota4:     .db "       Sol      "
nota5:     .db "       La       "
nota6:     .db "       Si       "
nota7:     .db "       Do       "

;Las frecuencias ya se encuentran justas para ser enviadas por OCR1A
;               Re    Mi    Fa   Sol    La    Si   Do
freq1:   .dw  6848, 6097, 5746, 5101, 4544, 4064, 7692
freq2:   .dw  3400, 3029, 2856, 2550, 2272, 2023, 3816
freq3:   .dw  1700, 1514, 1432, 1275, 1135, 1011, 1907
freq4:   .dw   851,  758,  716,  637,  567,  505,  956
freq5:   .dw   425,  378,  357,  318,  285,  252,  478
freq6:   .dw   212,  189,  178,  159,  142,  126,  238
freq7:   .dw   105,   94,   88,   79,   70,   62,  118
freq8:   .dw    53,   46,   43,   39,   35,   31,   59

;******************************************************************************
;******************************************************************************
;*************************** PROGRAMA PRINCIPAL *******************************
;******************************************************************************
;******************************************************************************

;Display 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16
;Line 1  00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10
;Line 2  40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F 50

;instruction code to position the cursor = 80h

start:
	ldi r16, high(ramend)
	out sph, r16
	ldi r16, low(ramend)
	out spl,r16
	rcall Configurar_Puertos
	rcall Configurar_Timer
	rcall RetardoXms
	rcall Configurar_LCD
   ldi octava, 3  ; Iniciamos todo en la 3era octava
   rcall Frase_Default

;AQUI COMIENZA EL LOOP INFINITO!!!
lectura_teclas:

;Comenzamos a leer todas las entradas 		
		
; PC7 PC6 PC5 PC4 PC3 PC2 PC1 PC0 PD7 PD6
; Re   Mi  Fa Sol  La  Si  Do  Re  Mi  Fa
; SW1	SW2 SW3 SW4 SW5 SW6 SW7 SW8 SW9 SW10
	
;Colocamos el cursor en la primera posicion	
	rcall CheckBF

   ldi instruccion, $80
	rcall WriteIR
	
;*** MODIFICACIONES DE OCTAVA ****	
	;decremento de octava
   in r16, pina
   andi r16, 0b00000001 ;PA0
   cpi r16,  0b00000001
   breq decremento_octava_pulsado
   rjmp sigue_octava
decremento_octava_pulsado:
   in r16, pina
   andi r16, 0b00000001
   cpi r16, 0b00000001
   breq decremento_octava_pulsado ;sigue presionado
   rjmp decremento_octava
sigue_octava:
   ;incremento de octava
   in r16, pina
   andi r16, 0b00000010
   cpi r16,  0b00000010 ;PA1
   breq incremento_octava_pulsado
   rjmp sigue_leyendo
incremento_octava_pulsado:
	in r16, pina
	andi r16, 0b00000010
	cpi r16,  0b00000010
	breq incremento_octava_pulsado ;sigue presionado
	rjmp incremento_octava

sigue_leyendo:
;*** LECTURA DE TECLAS ***	
	;primera tecla	
	in r16, pinc	
	andi r16, 0b10000000
	cpi r16, 0b10000000
	breq nota_sw1
	;segunda tecla
	in r16, pinc
	andi r16, 0b01000000
	cpi r16, 0b01000000
	breq nota_sw2
	;tercera tecla
	in r16, pinc
	andi r16, 0b00100000
	cpi r16, 0b00100000
	breq nota_sw3
	;cuarta tecla
	in r16, pinc
	andi r16, 0b00010000
	cpi r16, 0b00010000
	breq nota_sw4
	;quinta tecla
	in r16, pinc
	andi r16, 0b00001000
	cpi r16, 0b00001000
	breq nota_sw5
	;sexta tecla
	in r16, pinc
	andi r16, 0b00000100
	cpi r16, 0b00000100
	breq nota_sw6
	;setima tecla
	in r16, pinc
	andi r16, 0b00000010
	cpi r16, 0b00000010
	breq nota_sw7
	;octava tecla
	in r16, pinc
	andi r16, 0b00000001
	cpi r16, 0b00000001
	breq nota_sw8
	;novena tecla
	in r16, pind
	andi r16, 0b10000000
	cpi r16, 0b10000000
	breq nota_sw9
	;decima tecla
	in r16, pind
	andi r16, 0b01000000
	cpi r16, 0b01000000
	breq nota_sw10	
;Si no se presiona ninguna tecla, no se emite ningun sonido
	ldi r16, 0
	out ocr1ah, r16
	out ocr1al, r16

	rcall Frase_Default
	rjmp lectura_teclas
		
;OCTAVAS!	
decremento_octava:
	cpi octava, 1
	breq tope_minimo
   dec octava
   rjmp lectura_teclas
tope_minimo:
   ldi octava, 1
   rjmp lectura_teclas
   	
incremento_octava:
	cpi octava, 8
	breq tope_maximo
	inc octava
	rjmp lectura_teclas
tope_maximo:
	ldi octava, 8
	rjmp lectura_teclas
			
;NOTAS!
nota_sw1:
	ldi switch, 1
	rcall Get_Freq
	rjmp lectura_teclas
	
nota_sw2:
	ldi switch, 2
	rcall Get_Freq
	rjmp lectura_teclas
nota_sw3:
	ldi switch, 3
	rcall Get_Freq
	rjmp lectura_teclas
nota_sw4:
	ldi switch, 4
	rcall Get_Freq
	rjmp lectura_teclas
nota_sw5:
	ldi switch, 5
	rcall Get_Freq
	rjmp lectura_teclas
nota_sw6:
	ldi switch, 6
	rcall Get_Freq
	rjmp lectura_teclas
nota_sw7:
	ldi switch, 7
	rcall Get_Freq
	rjmp lectura_teclas
nota_sw8:
	ldi switch, 8
	rcall Get_Freq
	rjmp lectura_teclas
nota_sw9:
	ldi switch, 9
	rcall Get_Freq
	rjmp lectura_teclas
nota_sw10:
	ldi switch, 10
	rcall Get_Freq
   rjmp lectura_teclas


;******************************************************************************
;******************************************************************************
;*************************** CONFIGURAR PUERTOS *******************************
;******************************************************************************
;******************************************************************************

Configurar_Puertos:

	push r16
	
	ldi r16, $00
	out ddra, r16       ; PORTA ENTRADA
	ldi r16, 0b00111111	;PD7 y PD6 teclas
	out ddrd, r16 ; PD5 = OC1A salida, PD0 = RS, PD1 = R/W, PD2 = E
	ldi r16, $FF
	out ddrb, r16 ; portB = bus de datos
	ldi r16, $00
	out ddrc, r16 ; PORTC teclas
	pop r16
	ret

;******************************************************************************
;******************************************************************************
;**************************** FRASE DEFAULT ***********************************
;******************************************************************************
;******************************************************************************
Frase_Default:

	;Mandamos la frase que estara por default	
	ldi zh, high(titulo*2)
	ldi zl, low(titulo*2)
   ldi r16, 16
leer_otro_caracter_linea1:

	rcall CheckBF
	lpm dato, Z+
	rcall WriteDR
	dec r16
   cpi r16, 0
   brne leer_otro_caracter_linea1

;Aqui comienza la instruccion para escribir en la linea2
	
   ;El inicio de la linea2 es 80h + 40h = C0h

   rcall CheckBF

   ldi instruccion, $C0
	rcall WriteIR
	
	rcall CheckBF
		
	ldi zl, low(titulo2*2)
	ldi zh, high(titulo2*2)
	ldi r16, 16
leer_otro_caracter_linea2:	
	
	rcall CheckBF
	lpm dato, Z+
	rcall WriteDR
	dec r16
	cpi r16, 0
	brne leer_otro_caracter_linea2
	ret
	
;******************************************************************************
;******************************************************************************
;**************************** RETARDO DE X MS *********************************
;******************************************************************************
;******************************************************************************	

RetardoXms:

	push r16
	push r17
	clr r16

lazo_ext:

	clr r17

lazo_int:

	inc r17
	brne lazo_int
	inc r16
	cpi r16, 60
	brne lazo_ext
	pop r17
	pop r16
	ret


;******************************************************************************
;******************************************************************************
;***************************** CONFIGURAR LCD *********************************
;******************************************************************************
;******************************************************************************	

Configurar_LCD:

	push r16
	push r17
	rcall RetardoXms
	
	ldi instruccion, $30 ; Configuracion de 8 bits
	rcall WriteIR
	
	rcall RetardoXms
		
	ldi instruccion, $30
	rcall WriteIR
	
	rcall RetardoXms
	
   ldi instruccion, $30
	rcall WriteIR
	
	rcall RetardoXms
	
;Funcion SET: activa funcion: 0 0 1 DL N F x x

;										DL = 1 -> 8 bits;     DL = 0 -> 4 bits
;										N  = 0 -> una linea;   N = 1 -> dos lineas
;										F  = 0 -> 5x7 puntos;  F = 1 -> 5x10 puntos
	ldi instruccion, 0b00111100
	rcall WriteIR
	
	rcall CheckBF
	
	ldi instruccion, 8       ;Display OFF
	rcall WriteIR
	
	rcall CheckBF
	
	ldi instruccion, 1       ;Clear display									
	rcall WriteIR
	
	rcall CheckBF
	
;Funcion Seleccionar modo: 0 0 0 0 0 1 ID S

;										ID = 1 -> incrementa la direccion DDRAM
;										ID = 0 -> decrementa
;										 S = 1 -> desplazamiento de toda la pantalla
;													 (con ID = 1 desplaz. a la izquierda
;                                        con ID = 0 desplaz. a la derecha
;										 S = 0 -> no desplaza

	ldi instruccion, 0b00000110
	rcall WriteIR      ;Cursor sin desplazamiento
	
;Funcion ON/OFF del LCD: 0 0 0 0 1 D C B

;										D = 0 -> apagar la pantalla; D = 1 -> encender
;										C = 0 -> desactivar cursor;  C = 1 -> activar
;										B = 0 -> no parpadea el caracter senhalado por
;													el cursor
	rcall CheckBF
	
	ldi instruccion, 0b00001100  ;Enciende pantalla y no muestra cursor
	rcall WriteIR
	
	rcall CheckBF
	
	pop r17
	pop r16
	ret

;******************************************************************************
;******************************************************************************
;**************************** READ/WRITE **************************************
;******************************************************************************
;******************************************************************************

                           ;PD2 = E, PD1 = R/W, PD0 = RS
WriteIR:
	
	push r17
	ldi r17, 0b000 ; E = 0, R/W = 0, RS = 0
	out portd, r17
	ldi r17, 0b100 ; E = 1, R/W = 0, RS = 0
	out portd, r17
	
	out portb, instruccion
	
	ldi r17, 0b000 ; E = 0, R/W = 0, RS = 0
	out portd, r17
	ldi r17, 0b010 ; E = 0, R/W = 1, RS = 0
	out portd, r17
	
	pop r17
	ret
	
WriteDR:
	
	push r16
	push r17
	
	ldi r16, 0b001 ; E = 0, R/W = 0, RS = 1	
	out portd, r16
	ldi r16, 0b101 ; E = 1, R/W = 0, RS = 1	
	out portd, r16
	
	out portb, dato
	
	ldi r16, 0b001 ; E = 0, R/W = 0, RS = 1	
	out portd, r16
	ldi r16, 0b010 ; E = 0, R/W = 1, RS = 0
	out portd, r16
	
	pop r17
	pop r16
	ret
	
;******************************************************************************
;******************************************************************************
;***************************** BUSY FLAG **************************************
;******************************************************************************
;******************************************************************************

	
CheckBF:
	
	push r16
	push r17
	
	ldi r16, 0  ; Bus de datos: entrada
	out ddrb, r16
	
LecturaBF:
	
	ldi r16, 0b010 ; E = 0, R/W = 1, RS = 0
	out portd, r16
	ldi r16, 0b110 ; E = 1, R/W = 1, RS = 0		
	out portd, r16
	nop
	in r17, pinb   ; analiza el BF
	
	ldi r16, 0b010 ; E = 0, R/W = 1, RS = 0
	out portd, r16
	
	andi r17, 0b10000000
	cpi r17, 0
	brne LecturaBF ;Si el LCD esta ocupado -> espera
	
	ldi r16, $FF   ;Bus de datos: salida
	out ddrb, r16
	
	pop r17
	pop r16
	ret

;******************************************************************************
;******************************************************************************
;*************************** CONFIGURAR_TIMER *********************************
;******************************************************************************
;******************************************************************************
;                           Modo CTC con OCR1A
;                 0<<WGM13 1<<WGM12  0<<WGM11 0<<WGM10
;
;                          Preescalador = 1
;                       0<<CS12 0<<CS11 1<<CS10
;
;                      interrupciones habilitadas
;                              1<<OCIE1A
;
;                    generador de ondas habilitado
;                          0<<COM1A1 1<<COM1A0

Configurar_Timer:
	push r16
	ldi r16, (0<<COM1A1)|(1<<COM1A0)|(0<<WGM11)|(0<<WGM10)
	out TCCR1A, r16
	ldi r16, (0<<WGM13) |(1<<WGM12) | (1<<CS10)
	out TCCR1B, r16
	ldi r16, 0b00111111	;PD7 y PD6 teclas
	out ddrd, r16 ; PD5 = OC1A salida, PD0 = RS, PD1 = R/W, PD2 = E
	ldi r16, 0
	out OCR1AL, r16
	out OCR1AH, r16
	pop r16
	ret

;******************************************************************************
;******************************************************************************
;***************************** GET OCTAVA *************************************
;******************************************************************************
;******************************************************************************

Get_Octava:
	
	cpi octava, 1
	breq oct1
	cpi octava, 2
	breq oct2
	cpi octava, 3
	breq oct3
	cpi octava, 4
	breq oct4
	cpi octava, 5
	breq oct5
	cpi octava, 6
	breq oct6
	cpi octava, 7
	breq oct7
	cpi octava, 8
	breq oct8
	
oct1:
	ldi zh, high(octava1*2)
	ldi zl, low(octava1*2)
	mov temp_oct_textl, zl ;Almacenamos temporalmente la direccion en tabla
	mov temp_oct_texth, zh ;para luego ser mandada por LCD
	ldi zh, high(freq1*2)
	ldi zl, low(freq1*2)
	ret
	
oct2:
	ldi zh, high(octava2*2)
	ldi zl, low(octava2*2)
	mov temp_oct_textl, zl ;Almacenamos temporalmente la direccion en tabla
	mov temp_oct_texth, zh ;para luego ser mandada por LCD
	ldi zh, high(freq2*2)
	ldi zl, low(freq2*2)
	ret
	
oct3:
	ldi zh, high(octava3*2)
	ldi zl, low(octava3*2)
	mov temp_oct_textl, zl ;Almacenamos temporalmente la direccion en tabla
	mov temp_oct_texth, zh ;para luego ser mandada por LCD
	ldi zh, high(freq3*2)
	ldi zl, low(freq3*2)
	ret
	
oct4:
	ldi zh, high(octava4*2)
	ldi zl, low(octava4*2)
	mov temp_oct_textl, zl ;Almacenamos temporalmente la direccion en tabla
	mov temp_oct_texth, zh ;para luego ser mandada por LCD
	ldi zh, high(freq4*2)
	ldi zl, low(freq4*2)
	ret
	
oct5:
	ldi zh, high(octava5*2)
	ldi zl, low(octava5*2)
	mov temp_oct_textl, zl ;Almacenamos temporalmente la direccion en tabla
	mov temp_oct_texth, zh ;para luego ser mandada por LCD
	ldi zh, high(freq5*2)
	ldi zl, low(freq5*2)
	ret
	
oct6:
	ldi zh, high(octava6*2)
	ldi zl, low(octava6*2)
	mov temp_oct_textl, zl ;Almacenamos temporalmente la direccion en tabla
	mov temp_oct_texth, zh ;para luego ser mandada por LCD
	ldi zh, high(freq6*2)
	ldi zl, low(freq6*2)
	ret
	
oct7:
	ldi zh, high(octava7*2)
	ldi zl, low(octava7*2)
	mov temp_oct_textl, zl ;Almacenamos temporalmente la direccion en tabla
	mov temp_oct_texth, zh ;para luego ser mandada por LCD
	ldi zh, high(freq7*2)
	ldi zl, low(freq7*2)
	ret
	
oct8:
	ldi zh, high(octava8*2)
	ldi zl, low(octava8*2)
	mov temp_oct_textl, zl ;Almacenamos temporalmente la direccion en tabla
	mov temp_oct_texth, zh ;para luego ser mandada por LCD
	ldi zh, high(freq8*2)
	ldi zl, low(freq8*2)
   ret

;******************************************************************************
;******************************************************************************
;*************************** GET FREQUENCY ************************************
;******************************************************************************
;******************************************************************************

Get_Freq:

 	push octava ;como vamos a modificarlo en algunos switches
 	
compara_switch:
   cpi switch,1
   breq sw1
	cpi switch,2
	breq sw2
	cpi switch,3
	breq sw3
	cpi switch,4
	breq sw4
	cpi switch,5
	breq sw5i
	cpi switch,6
	breq sw6i
	cpi switch,7
	breq sw7i
	cpi switch,8
	breq sw8i
	cpi switch,9
	breq sw9i
	cpi switch,10
	breq sw10i
sw5i:
	rjmp sw5
sw6i:
	rjmp sw6
sw7i:
	rjmp sw7	
sw8i:	
	rjmp sw8
sw9i:
	rjmp sw9
sw10i:
	rjmp sw10
		
sw1:
	cpi octava, 7
	brlo sigue_sw1
	ldi octava, 7
sigue_sw1:
	rcall Get_Octava	
	ldi r16, 0
	add zl, r16
	adc zl, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota1*2)
	ldi zh, high(nota1*2)
	rjmp fin_sw
	
sw2:
	cpi octava, 7
	brlo sigue_sw2
	ldi octava, 7
sigue_sw2:	
	rcall Get_Octava
	ldi r16, 2
	add zl, r16
	ldi r16, 0
	adc zh, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota2*2)
	ldi zh, high(nota2*2)
	rjmp fin_sw
	
sw3:
	cpi octava, 7
	brlo sigue_sw3
	ldi octava, 7
sigue_sw3:
	rcall Get_Octava	
	ldi r16, 4
	add zl, r16
	ldi r16, 0
	adc zh, r16
	lpm xl, z+
	lpm xh, z	
	ldi zl, low(nota3*2)
	ldi zh, high(nota3*2)
	rjmp fin_sw
	
sw4:
	cpi octava, 7
	brlo sigue_sw4
	ldi octava, 7
sigue_sw4:	
	rcall Get_Octava
	ldi r16, 6
	add zl, r16
	ldi r16, 0
	adc zh, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota4*2)
	ldi zh, high(nota4*2)
	rjmp fin_sw
	
sw5:
	cpi octava, 7
	brlo sigue_sw5
	ldi octava, 7
sigue_sw5:	
	rcall Get_Octava
	ldi r16, 8
	add zl, r16
	ldi r16, 0
	adc zh, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota5*2)
	ldi zh, high(nota5*2)
	rjmp fin_sw
	
sw6:
	cpi octava, 7
	brlo sigue_sw6
	ldi octava, 7
sigue_sw6:	
	rcall Get_Octava
	ldi r16, 10
	add zl, r16
	ldi r16, 0
	adc zh, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota6*2)
	ldi zh, high(nota6*2)
	rjmp fin_sw
	
sw7:
	cpi octava, 8
	breq sigue_sw7
	inc octava
sigue_sw7:	
	rcall Get_Octava
	ldi r16, 12
	add zl, r16
	ldi r16, 0
	adc zh, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota7*2)
	ldi zh, high(nota7*2)
	rjmp fin_sw

sw8:      ;las unicas 3 notas que van en una octava mayor
	cpi octava, 8
	breq sigue_sw8
	inc octava
sigue_sw8:
	rcall Get_Octava
	ldi r16, 0
	add zl, r16
	adc zh, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota1*2)
	ldi zh, high(nota1*2)
	rjmp fin_sw
	
sw9:
	cpi octava,8
	breq sigue_sw9
	inc octava
sigue_sw9:	
	rcall Get_Octava
	ldi r16, 2
	add zl, r16
	ldi r16, 0
	adc zh, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota2*2)
	ldi zh, high(nota2*2)
	rjmp fin_sw
	
sw10:
	cpi octava, 8
	breq sigue_sw10
	inc octava
sigue_sw10:
	rcall Get_Octava
	ldi r16, 4
	add zl, r16
	ldi r16, 0
	adc zh, r16
	lpm xl, z+
	lpm xh, z
	ldi zl, low(nota3*2)
	ldi zh, high(nota3*2)
	rjmp fin_sw
		
fin_sw:
	; hasta el momento
	; Z = nombre de la nota (Re, Mi ..)
	; X = freq lista para OCR1ah
	; temp_oct_text = texto de "Octava.."
	
   ldi instruccion, $80
	rcall WriteIR
	
	;Mandamos el nombre de la nota que se encuentra		
	ldi r16, 16
	nombre_nota:

	rcall CheckBF
	lpm dato, Z+
	rcall WriteDR
	dec r16
   cpi r16, 0       ;solo mandamos 16 caracteres
   brne nombre_nota

;Aqui comienza la instruccion para escribir en la linea2
	
   ;El inicio de la linea2 es 80h + 40h = C0h

   rcall CheckBF

   ldi instruccion, $C0
	rcall WriteIR
	
	;Mandamos el numero de octava actual
	ldi r16, 16
	mov zh, temp_oct_texth
	mov zl, temp_oct_textl
	
	numero_octava:
	
	rcall CheckBF
	lpm dato, Z+
	rcall WriteDR
	dec r16
   cpi r16, 0
   brne numero_octava
	
	;Mandamos la nota correspondiente por el parlante
	out OCR1AH, xh
	out OCR1AL, xl

		
	
	pop octava
	ret
	
