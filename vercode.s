_GETCHAR=117
_OPEN=5
_READ=3
_CLOSE=6
.SECT .TEXT

!				/*calcola il valore numerico di 10^n con n appartenente ai numeri Naturali*/

EXP10:				!int exp10(int n)	
 
PUSH BP				!
MOV BP ,SP			!
MOV BX , 10			! BX=10;
MOV CX , 4(BP)		! CX=n; 
MOV AX , 1			! AX=1;	
	
1:					! while(CX>0){
CMP CX ,0			! if(CX==0) goto FINE;
JE FINE				!
MUL BX				! AX*=10;
LOOP 1b				! CX--;}

FINE:				! FINE:
MOV BX ,AX			! BX=AX;
MOV AX,0			! AX=0;
POP BP				!
RET					


GET_CODE:			! int get_code()

MOV (value),0			! value=0;
MOV (num),0			! num=0;
MOV BP,SP
MOV CX,5			! CX=5;
MOV DI,V			! DI=&v[0];
MOV AX,0			! AX=0;
MOV BX,0			! BX=0;
1:					! while(CX>0){
CMP CX,0			! if(CX==0) goto CONVERTI
JE CONVERTI	

PUSH _GETCHAR			! AX=getchar();
SYS
MOV SI,SP
CMP AX,10			! if(AX==10) goto CONVERTI;
JE CONVERTI

SUB AX,48			! AX-=48;
MOV (DI),AX			! *DI=AX
ADD DI,2			! DI++;	/*mi muovo nel vettore alla posizione successiva*/
MOV AX,0			! AX=0
LOOP 1b				! CX--;}

CONVERTI:			! CONVERTI:

MOV DI,V			! DI=&v[0];
MOV AX,5			! AX=5;
SUB AX, CX			! AX-CX;

CONV:

MOV CX,0			! CX=0;
SUB AX,1			! AX-=1;		/*calcolo l'esponente per questo ciclo*/
MOV (num),AX			! num=AX;
CMP AX,-1			! if(AX==-1) goto END;
JE END

PUSH AX		
CALL EXP10			! BX=exp10(AX);
MOV AX,0			! AX=0;
MOV AX,(DI)			! AX=*DI;
MUL BX				! AX*=BX;
ADD (value),AX			! value=AX;
ADD DI,2			! DI++;		/*mi sposto nel vettore*/
MOV AX,(num)			! AX=num;
JMP CONV			! goto CONV;


END:				! END:
MOV BX,(value)			! BX=value;	
MOV AX,0			! AX=0;
MOV (value),0			! value=0;
MOV SP,BP
RET

IS_PIN_CORRECT:			! int is_pin_correct()

CALL GET_CODE			! BX=get_code();
MOV (USER),BX			! user=BX;
MOV BX,0			! BX=0;
MOV (value),0			! value=0;
MOV (num),0			! num=0;
MOV BP,SP
MOV DI,PIN			! DI=&pin[0];
PUSH 0
PUSH rom
PUSH _OPEN			! AX=open("rom.txt",0);
SYS

MOV CX,5			! CX=5;
1:				! while(CX>0){
CMP CX,0			! if(CX==0) goto CLOSE
JE CLOSE

PUSH 1
PUSH DI
PUSH 3
PUSH _READ
SYS				! AX=read(3,DI,1);
MOV AX,(DI)			! AX=*(DI);
CMP AX,32			! if(AX==32) goto CLOSE			/*Se AX==" "*/
JE CLOSE
ADD DI,2
LOOP 1b				! CX--;}

CLOSE:
PUSH 3
PUSH _CLOSE
SYS				! AX=close(3);

MOV DI,PIN			! DI=&pin[0];
MOV AX,5			! AX=5;
SUB AX, CX			! AX-CX

CONVERT:

MOV CX,0			! CX=0;
SUB AX,1			! AX-=1;
MOV (num),AX			! num=AX;
CMP AX,-1			! if(AX==-1) goto CHIUDI
JE CHIUDI

PUSH AX		
CALL EXP10			! BX=EXP10(AX);
MOV AX,0			! AX=0;
MOV AX,(DI)			! AX=*(DI);
SUB AX,48			! AX-=48;
MUL BX				! AX*=BX;
ADD (value),AX			! value=AX;
ADD DI,2			! DI++;			/*mi sposto nel vettore*/
MOV AX,(num)			! num=AX;
JMP CONVERT			! goto CONVERT

CHIUDI:
MOV BX,(USER)			! BX=user;
MOV AX,(value)			! AX=value;
CONFRONTA:
CMP AX,BX			! if(AX==BX) goto SUCCESSO
JE SUCCESSO
				!  else
FALLIMENTO:
MOV BX,-1			! BX=-1;
MOV SP,BP
RET

SUCCESSO:			!SUCCESSO:
MOV BX,0			! BX=0;
MOV SP,BP
RET

IS_PUK_CORRECT:			! int is_puk_correct()


CALL GET_CODE			! get_code();
MOV (USER),BX			! user=BX;
MOV BX,0			! BX=0;
MOV (value),0			! value=0;
MOV (num),0			! num=0;
MOV BP,SP			
MOV DI,PUK			! DI=&puk[0];
PUSH 0
PUSH rom
PUSH _OPEN
SYS				! AX=open(rom,0);

MOV CX,5			! CX=5;
1:				! while(CX>0){
CMP CX,0
JE  SECONDO

PUSH 1
PUSH TMP
PUSH 3
PUSH _READ
SYS				! AX=read(3,&TMP,1);
CMP (TMP),32			! if(TMP==32) goto SECONDO
JE SECONDO
LOOP 1b				! CX--;}

SECONDO:			! SECONDO:
MOV CX,5			! CX=5;
2:				! while(CX>0){	
PUSH 1
PUSH DI
PUSH 3
PUSH _READ
SYS				! AX=read(3,DI,1);
MOV AX,(DI)			! AX=*(DI)
CMP AX,32			! if(AX==32) goto CLOS
JE CLOS				! 
ADD DI,2			! DI++;
LOOP 2b				! CX--;}

CLOS:
PUSH 3
PUSH _CLOSE
SYS				! AX=close(3);

MOV DI,PUK			! DI=&puk[0];
MOV AX,5			! AX=5;
SUB AX, CX			! AX-CX


CON:
MOV CX,0			! CX=0;
SUB AX,1			! AX-=1;
MOV (num),AX			! num=AX;
CMP AX,-1			! if(AX==-1) goto FINISCI
JE FINISCI

PUSH AX		
CALL EXP10			! BX=exp10(AX);
MOV AX,0			! AX=0;
MOV AX,(DI)			! AX=*(DI)
SUB AX,48			! AX-=48;
MUL BX				! AX*=BX;
ADD (value),AX			! value=AX;
ADD DI,2			! DI++;
MOV AX,(num)			! AX=num;
JMP CON				! goto CON

FINISCI:			
MOV BX,(USER)			! BX=USER;
MOV AX,(value)			! AX=value;
CMP AX,BX			! if(AX==BX) goto SUCCESS
JE SUCCESS
				!else
FAILURE:
MOV BX,-1			! BX=-1;
MOV SP,BP
RET

SUCCESS:
MOV BX,0			! BX=0;
MOV SP,BP
RET

GET_COINS:			! int get_coins()

MOV (USER),BX			! USER=BX;
MOV BX,0			! BX=0;
MOV (value),0			! value=0;
MOV (num),0			! num=0;
MOV BP,SP
MOV DI,COINS			! DI=&coins[0];
PUSH 0
PUSH rom
PUSH _OPEN
SYS				! AX=open("rom.txt",0);

MOV CX,5			! CX=5;
1:				! while(CX>0){
CMP CX,0			! if(CX==0) goto LAB_2
JE  LAB_2

PUSH 1
PUSH TMP
PUSH 3
PUSH _READ
SYS				! AX=read(3,&TMP,1);
CMP (TMP),32			! if(TMP==32) goto LAB_2
JE LAB_2
LOOP 1b				! CX--}

LAB_2:				
MOV CX,5			! CX=5;
2:				! while(CX>0){
CMP CX,0			! if(CX==0) goto LAB_3
JE  LAB_3

PUSH 1
PUSH TMP
PUSH 3
PUSH _READ
SYS				! AX=read(3,&TMP,1);
CMP (TMP),32			! if(TMP==32) goto LAB_3
JE LAB_3
LOOP 2b				! CX--}

LAB_3:
MOV CX,5			! CX=5;
3:				! while(CX>0){
PUSH 1
PUSH DI
PUSH 3
PUSH _READ
SYS				! AX=read(3,DI,1);
MOV AX,(DI)			! AX=*(DI);
CMP AX,32			! if(AX==32) goto LABEL_CLOS;
JE LABEL_CLOS
ADD DI,2			! DI++;			/*mi sposto nel vettore*/
LOOP 3b				! CX--;}

LABEL_CLOS:
PUSH 3
PUSH _CLOSE			! AX=close(3);
SYS

MOV DI,COINS			! DI=&coins[0]
MOV AX,5			! AX=5;
SUB AX, CX			! AX-CX


LABEL_CON:			! LABEL_CON
CMP AX,-1			! if(AX==-1) goto LABEL_FINISCI;
JE LABEL_FINISCI
MOV CX,0			! CX=0;
SUB AX,1			! AX-=1;
MOV (num),AX			! num=AX;

PUSH AX		
CALL EXP10			! BX=exp10(AX);

MOV AX,0			! AX=0;
MOV AX,(DI)			! AX=*(DI)
SUB AX,48			! AX-=48;
MUL BX				! AX*=BX;
ADD (value),AX			! value=AX;
ADD DI,2			! DI++;
MOV AX,(num)			! AX=num;
JMP LABEL_CON			! goto LABEL_CON

LABEL_FINISCI:
MOV BX,(value)			! BX=value;
MOV SP,BP
RET



.SECT .DATA
V: .WORD 0,0,0,0,0,0
num: .WORD 0
value: .WORD 0
tbp: .WORD 0
spa:.WORD 0
PIN: .WORD 0,0,0,0,0,0
USER: .WORD 0
PUK: .WORD 0,0,0,0,0,0
TMP: .WORD 0
COINS: .WORD 0,0,0,0,0,0 
.ALIGN 2
rom: .ASCII"rom.txt"
.SECT .BSS
