#include <avr/boot.h>
#include <avr/interrupt.h>
#include <avr/io.h>


//Nuevas Variables
	typedef unsigned char byte;
	
//Variables Globales
	byte instruccion;
	byte dato;


void(Port_Config(void))
{
    DDRA = 0;            // PORTA = botones octava        
	DDRD = 0b00111111;   // PD7 y PD6 son teclas, PD5 = OC1A salida, PD0 = RS, PD1 = R/W, PD2 = E
	DDRB = 0b11111111;   // PORTB = bus de datos
	DDRC = 0;            // PORTC = teclas
}

void(Timer_Config(void))
{
	TCCR1A = (0<<COM1A1)|(1<<COM1A0)|(0<<WGM11)|(0<<WGM10);
	TCCR1B = (0<<WGM13) |(1<<WGM12) | (1<<CS10);
	TIMSK  = 1<<OCIE1A;
}

void(RetardoXms(void))
{
	
	r17=0;
	for(r16=0, r16 <= 60 , r16++)
	{
		r17++;
		if(r17 != 0 ) r17++;
		else  r17=0;
	}
}

void(WriteIR(void))
{
	PORTD = 0b000; //E = 0, R/W = 0, RS = 0
	PORTD = 0b000; //E = 1, R/W = 0, RS = 0
	
	PORTB = instruccion;
	
	PORTD = 0b000; //E = 0, R/W = 0, RS = 0
	PORTD = 0b010; //E = 0, R/W = 1, RS = 0
}

void(WriteDR(void))
{
	PORTD = 0b001; //E = 0, R/W = 0, RS = 1
	PORTD = 0b101; //E = 1, R/W = 0, RS = 1
	
	PORTB = dato;
	
	PORTD = 0b001; //E = 0, R/W = 0, RS = 1
	PORTD = 0b010; //E = 0, R/W = 1, RS = 0
	
}

void(CheckBF(void))
{
    byte r17;
//CheckBF
	DDRB = 0;      // bus de datos entrada
	
//LecturaBF	
    do        
	{
      PORTD = 0b010; //E = 0, R/W = 1, RS = 0
	  PORTD = 0b110; //E = 1, R/W = 1, RS = 0
	  r17 = PINB;
	  PORTD = 0b010; //E = 0, R/W = 1, RS = 0
	  r17 = r17& 0b10000000;
     }while(r17 != 0 )  
     
     DDRB = 0xFF;    // bus de datos salida
	
}
void(LCD_Config(void))
{
	RetardoXms();
	instruccion = 0x30;
	WriteIR();
	
	RetardoXms();
	instruccion = 0x30;
	WriteIR();
	
	RetardoXms();
	instruccion = 0x30;
	WriteIR();
	
	RetardoXms();	
	
//Funcion SET: Activa funcion: 0 0 1 DL N F x x 
//	DL = 1 -> 8 bits;     DL = 0 -> 4 bits
//	N  = 0 -> una linea;   N = 1 -> dos lineas
//	F  = 0 -> 5x7 puntos;  F = 1 -> 5x10 puntos

	instruccion = 0b00111100;
	WriteIR();
	CheckBF();
	instruccion = 8;
	WriteIR();
	CheckBF();
	instruccion = 1;
	WriteIR();
	CheckBF();
	
//Funcion Seleccionar modo: 0 0 0 0 1 ID S
//	ID = 1 -> incrementa la direccion DDRAM
//	ID = 0 -> decrementa
//	S = 1 -> desplazamiento de toda la pantalla
//	(con ID = 1 desplaz. a la izquierda
//	con ID = 0 desplaz. a la derecha
//	S = 0 -> no desplaza	
	instruccion = 0b00000110;
	WriteIR();
	
//Funcion ON/OFF del LCD: 0 0 0 0 1 D C B
// D = 0 -> apagar la pantalla; D = 1 -> encender
// C = 0 -> desactivar cursor;  C = 1 -> activar
// B = 0 -> no parpadea el caracter senhalado por
// el cursor
	
	CheckBF();
	instruccion = 0b00001100;
	WriteIR();
	CheckBF();
}

void (Titulo(void))
{
//Mandamos primera linea "     Shally's"
    CheckBF();
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = 'S';
    WriteDR(); 
    CheckBF();
    dato = 'h';
    WriteDR(); 
    CheckBF();
    dato = 'a';
    WriteDR(); 
    CheckBF();
    dato = 'l';
    WriteDR(); 
    CheckBF();
    dato = 'l';
    WriteDR(); 
    CheckBF();
    dato = 'y';
    WriteDR(); 
    CheckBF();
    dato = '`';
    WriteDR(); 
    CheckBF();
    dato = 's';
    
//Mandamos la segunda linea "     Piano"

    CheckBF();
    instruccion = 0xC0;  //El inicio de la linea2 es 80h + 40h = C0h
    WriteIR();
    CheckBF();    
              
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = ' ';
    WriteDR(); 
    CheckBF();
    dato = 'P';
    WriteDR(); 
    CheckBF();
    dato = 'i';
    WriteDR(); 
    CheckBF();
    dato = 'a';
    WriteDR(); 
    CheckBF();
    dato = 'n';
    WriteDR(); 
    CheckBF();
    dato = 'o';
}

int main(void)
{
	Port_Config();
	Timer_Config();
	RetardoXms;
	LCD_Config();
    while(1)
    {	
     //Mandamos titulo
     Titulo();  
     
    }       

	//FAAAALTTAAAAA
	
}
