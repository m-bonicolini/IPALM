_EXIT=1
_PRINTF=127
_WRITE=4
.SECT .TEXT 

start:

MOV BP,SP
MOV CX,3				! CX=3;
1:					! while(CX>0){
MOV (myint),CX				! myint=CX
CMP CX,0				! if(CX==0) goto MENU_PUK
JE MENU_PUK
CALL MSG_PIN				! msg_pin();				/*funzione definita in mymenu.s*/

CALL IS_PIN_CORRECT			! is_pin_correct();			/*funzione definita in vercode.s*/

CMP BX,0				! if(BX==0) goto MENU
JE MENU

CALL ER_PIN				! er_pin();				/*funzione definita in mymenu.s*/

MOV BP,SP
MOV CX,(myint)				! CX=myint;		/*Le funzioni utilizzate sopra usano CX e possono alterarne il valore*/
MOV BX,0				! BX=0
LOOP 1b					! CX--}

MENU_PUK:
CALL MSG_PUK
CALL IS_PUK_CORRECT
CMP BX,0
JE MENU
CALL ER_PUK
JMP FINE_IPALM

MENU:					! MENU:
CALL STAMPA_MENU			! stampa_menu();			/*stampa il menu*/

CALL GET_CODE				! BX=get_code();
CMP BX,7				! if(BX==7) goto FINE_IPALM;		/*quit da ipalm*/
JE FINE_IPALM
CMP BX,1				! if(BX==1) goto RU;			/*stampa rubrica*/
JE RU
CMP BX,2				! if(BX==2) goto RU1;			/*inserisci in rubrica*/
JE RU1
CMP BX,3				! if(BX==3) goto COIN;			/*visualizza credito*/
JE COIN
CMP BX,4				! if(BX==4) goto MENU_SEARCH;		/*Cerca in rubrica*/
JE MENU_SEARCH
CMP BX,6				! if(BX==5) goto GPS
JE GPS
JMP MENU

!	/*Sezione di Stampa Rubrica*/
RU:
CALL PRINT_RUBRICA			! print_rubrica();			/*la funzione e' definita in rubrica.s*/
PUSH nline					
PUSH video
PUSH _PRINTF				! printf(video);			/*stampa il file rubrica.txt*/
SYS
JMP MENU				! goto MENU

!	/*Inserisci in rubrica*/
RU1:
CMP (piena),1				! if(piena==1) goto r_fine;
JE r_fine					
!MOV BP,SP
PUSH 0						
PUSH rubric
PUSH _OPEN				! AX=open(rubric,0);			/*apre rubraca.txt*/
SYS
MOV BX,0				! BX=0
RULOOP:					! RULOOP:
PUSH 1				
PUSH tmp
PUSH 3
PUSH _READ
SYS					! AX=read(3,&tmp,1);			/*Poiche si apre un solo file alla volta fd=3*/
CMP AX,0				! if(AX==0) goto RUFASE
JE RUFASE
CMP AX,-1				! if(AX==-1) goto RUFASE
JE RUFASE 

MOV AX,(tmp)				! AX=tmp;
CMP AX,10				! if(AX==10) goto r_sum	/*Se AX=="\n" */
JE r_sum
JMP RULOOP				! goto RULOOP

r_sum:					! r_sum:
ADD BX,1				! BX+=1;
JMP RULOOP

RUFASE:					! RUFASE:
PUSH 3
PUSH _CLOSE
SYS					! AX=close(3);

CMP BX,10				! if(BX>=10)	goto r_fine
JGE r_fine

I_FASE:						
CALL INSERT				! insert();
!MOV BP,SP					
JMP MENU				! goto MENU

r_fine:					! r_fine:
PUSH ru
PUSH _PRINTF
SYS					! printf("rubrica piena\n");
MOV (piena),1				! piena=1;
JMP MENU				! goto MENU
!	/*Sezione visualizza credito*/
COIN:
CALL GET_COINS				! get_coins();	/*funzione  definita in vercode.s*/
PUSH BX
PUSH format
PUSH _PRINTF
SYS					! printf("credito=%d\n",&BX);
JMP MENU				! goto MENU


!	/*Sezione ricerca in rubrica*/
MENU_SEARCH:

!MOV BP,SP
CALL GET_CODE				! BX=get_code();
ADD BX,48				! BX+=48;
MOV (mytemp),BX				! mytemp=BX;
MOV (flag),0				! flag=0
PUSH 0
PUSH rubrica
PUSH _OPEN
SYS					! AX=open(rubrica,0);
MOV (fd),AX				! fd=AX;

!	/*Controlla se la linea e' da stampare.In caso affermativo salta all'etichetta print_line*/
SEARCH_CHECK:				! SEARCH_CHECK
PUSH 1
PUSH mytemp2
PUSH (fd)
PUSH _READ
SYS					! AX=read(fd,&mytemp2,1);
CMP AX,0				! if(AX==0) goto SEARCH_FINE;
JE SEARCH_FINE
CMP AX,-1				! if(AX==-1) goto SEARCH_FINE;
JE SEARCH_FINE

MOV BX,(mytemp2)			! BX=mytemp2;
CMP (mytemp),BX				! if(BX==mytemp2) goto PRINT_LINE
JE PRINT_LINE				
JMP FIN_LINEA				! goto FIN_LINEA


!				/*Scorre fino alla fine della linea*/
FIN_LINEA:				! FIN_LINEA
CMP BX,10				! if(BX==10) goto SEARCH_CHECK /*Se "\n"*/
JE SEARCH_CHECK
PUSH 1
PUSH mytemp2
PUSH (fd)
PUSH _READ				
SYS					! AX=read(fd,&mytemp2,1);
CMP AX,0				! if(AX==0) goto SEARCH_FINE
JE SEARCH_FINE
CMP AX,-1				! if(AX==-1) goto SEARCH_FINE
JE SEARCH_FINE
MOV BX,(mytemp2)			! BX=mytemp2
JMP FIN_LINEA				! goto FIN_LINEA

!	/*Stampa la linea*/

PRINT_LINE:				! PRINT_LINE
PUSH BX
PUSH _PUTCHAR				! AX=putchar(BX);
SYS
CMP BX,10				! if(BX==10) goto SEARCH_CHECK
JE SEARCH_CHECK

PUSH 1
PUSH mytemp2
PUSH (fd)
PUSH _READ
SYS					! AX=read(fd,&mytemp2,1);
CMP AX,0				! if(AX==0) goto SEARCH_FINE
JE SEARCH_FINE
CMP AX,-1				! if(AX==-1) goto SEARCH_FINE
JE SEARCH_FINE
MOV BX,(mytemp2)			! BX=mytemp2
JMP PRINT_LINE				! goto PRINT_LINE


SEARCH_FINE:				!SEARCH_FINE:
PUSH (fd)
PUSH _CLOSE
SYS					! close(fd);
JMP MENU				! goto MENU


GPS:					! GPS:
MOV SI,0				! SI=0
MOV DI,0				! DI=0
MOV AX,0				! AX=0
MOV BX,0				! BX=0
MOV CX,0				! CX=0
MOV DX,0				! DX=0

					
LEGGIDATI:				!LEGGIDATI:
PUSH 0					
PUSH _NOMEFILE
PUSH _OPEN
SYS					! AX=open("gps.txt",0);


GPS_START:				! GPS_START:			
PUSH 1
PUSH TMP
PUSH 3
PUSH _READ             			! AX=read(3,&TMP,1);
SYS                 
SUB (TMP),48        			! TMP=48;
MOV DX,(TMP)       			! DX=TMP;
PUSH 1
PUSH TMP
PUSH 3
PUSH _READ
SYS                 			! AX=read(3,TMP,1);         
MOV CX,(TMP)				! CX=TMP;
SUB CX,48				! CX-=48;
CMP CX,-16				! if(CX==-16) goto SALTA
JE SALTA
MOV AX,DX				! AX=DX;
ADD BX,10				! BX+=10;
MUL BX
ADD CX,AX				! CX+=AX;
PUSH 1	
PUSH TMP
PUSH 3
PUSH _READ				! AX=read(3,&TMP,1);
SYS
JMP SALTA2				! goto SALTA2

                			!				/*HO IN CX IL PRIMO VALORE*/
SALTA:
MOV CX,DX				! CX=DX;
SALTA2:
PUSH 1
PUSH TMP
PUSH 3
PUSH _READ
SYS					! AX=read(3,&(TMP),1);
MOV DX,(TMP)				! DX=TMP
SUB DX,48         			! DX-=48;
PUSH 1
PUSH TMP
PUSH 3
PUSH _READ				! AX=read(3,&TMP,1);
SYS
MOV BX,(TMP)				! BX=TMP;
CMP BX,10
JE SECONDAPARTE  			! if(BX==10) goto SECONDAPARTE    /* E HO IN CX IL PRIMO VALORE E IN DX IL SECONDO*/
MOV AX,DX				! AX=DX;
MOV DX,10				! DX=10;
MUL DX					! AX*=DX;
MOV DX,AX				! DX=AX;
SUB BX,48				! BX-=48;
ADD DX, BX				! DX+=BX;

					!				/* HO IN CX-SI IL PRIMO VALORE E IN DX IL SECONDO*/

SECONDAPARTE:				! SECONDAPARTE:
PUSH 3
PUSH _CLOSE
SYS					! AX=close(3);

MOV SI,CX				! SI=CX;
MOV DI,DX				! DI=DX;
           

MOV AX,0				! AX=0;
MOV BX,0				! BX=0;
MOV CX,0				! CX=0;
MOV DX,0				! DX=0;


MOV CX,0				! CX=0;
MOV BX,-1				! BX=-1;
COLONNE:				! COLONNE:
MOV CX,0				! CX=0;
ADD BX,1				! BX+=1;
CMP BX,SI				! if(BX==SI) goto PRIMOSEGNALE
JE PRIMOSEGNALE
RIT2:					! RIT2:
CMP BX,30				! if(BX==30) got EXIT
JE EXIT
RIGHE:					! RIGHE:

CMP CX,DI				!if(CX==DI) goto COLONNAGIUSTA
JE COLONNAGIUSTA
RIT1:					! RIT1:
PUSH 46
PUSH _PUTCHAR
SYS					! putchar(46);
FATTO:					! FATTO:
ADD CX,1				! CX++;
CMP CX,30				! if(CX==30) goto AGGIUNGISPAZIO
JE AGGIUNGISPAZIO
TORNA:					! TORNA:
CMP CX,30				! if(CX==30) goto COLONNE
JE COLONNE
JMP RIGHE				! goto RIGHE

AGGIUNGISPAZIO:				! AGGIUNGISPAZIO
PUSH 10
PUSH _PUTCHAR
SYS					! putchar(10);
JMP TORNA				! goto TORNA;

PUSH 10
PUSH _PUTCHAR
SYS					! putchar(10);

PRIMOSEGNALE:				! PRIMOSEGNALE:
ADD DX,1				! DX++;
JMP RIT2				! goto RIT2

COLONNAGIUSTA:				! COLONNAGIUSTA:
CMP DX,1				! if(DX==1) goto RIGAGIUSTA
JE RIGAGIUSTA
JMP RIT1				! goto RIT1

RIGAGIUSTA:				! RIGAGIUSTA:
PUSH 42					
PUSH _PUTCHAR
SYS					! putchar(42);
SUB DX,1				! DX--;
JMP FATTO				! goto FATTO


EXIT:					! EXIT:
MOV AX,0				! AX=0;
MOV BX,0				! BX=0;
MOV CX,0				! CX=0;
MOV DX,0				! DX=0;
MOV DI,0				! DI=0;
MOV SI,0				! SI=0;

JMP MENU				! goto MENU



! /*quit dal programma */
FINE_IPALM:				! FINE_IPALM:
PUSH _EXIT
SYS					! exit();


.SECT .DATA
_NOMEFILE: .ASCIZ"gps.txt"
logo: .SPACE 1024
romB: .SPACE 1024
sms_name: .SPACE 300
ru: .ASCIZ"rubrica piena\n"
myint: .WORD 0
format: .ASCIZ"\ncredito=%d\n"
rubric: .ASCIZ"rubrica.txt"
mylogo: .ASCIZ"logo.txt"
tmp: .WORD 0
piena: .WORD 0

.SECT .BSS

