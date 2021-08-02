.SECT .TEXT

PARTE_1:

MOV BP,SP
MOV DI,PAROLA			! DI=&PAROLA;

!76 69 78  69			Demo di una ipotetica parola da testare
MOV AX,76
MOV (DI),AX
ADD DI,2
MOV AX,69
MOV (DI),AX
ADD DI,2
MOV AX,78
MOV (DI),AX
ADD DI,2
MOV AX,69
MOV (DI),AX

MOV DI,PAROLA


LEGGIPAROLA:
PUSH 0
PUSH _NOME
PUSH _OPEN
SYS				! AX=open(_NOME,0);

CARPERCAR:			! CARPECAR:
PUSH 1
PUSH TMP
PUSH 3
PUSH _READ			! AX=read(3,&TMP,1);
SYS 
! 32 e il carattere di spazio
MOV CX,(TMP)			! CX=TMP;
MOV BX,(DI)			! BX=DI;
CMP CX,32			! if(CX==32) goto FINITO
JE FINITO
CMP BX,CX 			! if(BX==CX) goto CORRETTO
JE CORRETTO
JMP FAL				! goto FAL


CORRETTO:			! CORRETTO:
ADD DI,2			! DI++;
MOV DX,1			! DX=1;
JMP CARPERCAR			! goto CARPECAR


FINITO:				! FINITO:
CMP DX,1			! if(DX==1) goto SUC
JE SUC
CMP DX,0			! if(DX==0) goto FAL
JE FAL


SUC:				! SUC:
MOV BX,DX			! BX=DX;
PUSH 1	
PUSH TMP
PUSH 3
PUSH _READ
SYS				! AX=read(3,TMP,1);
CMP (TMP),32			! if(TMP==32) goto OPERATORE
JE OPERATORE
JMP SUC				! goto SUC


OPERATORE:			! OPERATORE:
PUSH 1
PUSH TMP
PUSH 3
PUSH _READ
SYS				! AX=read(3,&TMP,1);
MOV BX,(TMP)
JMP CHIUDITI			! goto CHIUDITI

FAL:				! FAL:
MOV BX,-1			! BX=-1;
MOV DX,-1			! DX=-1;
JMP CHIUDITI			! goto CHIUDITI


CHIUDITI:			! CHIUDITI:
PUSH 3
PUSH _CLOSE
SYS				! close(3);

! BX OPERATORE della RUBRICA
! CX OPERATORE CASA, nella ROM
! DX RISULTATO OPERAZIONE (-1 fallimento)

CMP BX,-1			! if(BX==-1) goto E
JE E
!cerca operatore ipalm 8088
PUSH 0
PUSH _OPERATORECASA
PUSH _OPEN			
SYS				! AX=open(_OPERATORECASA,0);

MOV CX,0			! CX=0;
RICERCA:			! RICERCA:
PUSH 1
PUSH TMP
PUSH 3
PUSH _READ			! AX=read(3,&TMP,1);
SYS
CMP (TMP),32			! if(TMP==32) goto TROVAOPERATORE
JE TROVAOPERATORE
JMP RICERCA			! goto RICERCA

TROVAOPERATORE:			! TROVAOPERATORE:
ADD CX,1			! CX++;
CMP CX,3			! if(CX==3) goto TROVATO
JE TROVATO
JMP RICERCA			! goto RICERCA

TROVATO:			! TROVATO:
PUSH 1
PUSH TMP
PUSH 3
PUSH _READ
SYS				! AX=read(3,&TMP,1);
MOV CX,(TMP)
PUSH 3
PUSH _CLOSE
SYS				! AX=close(3);


! BX RUBRICA
! CX ROM

CMP CX,65			! if(CX==65) goto OPERATOREA
JE OPERATOREA
CMP CX,66
JE OPERATOREB			! if(CX==66) goto OPERATOREB
CMP CX,67
JE OPERATOREC			! if(CX==67) goto OPERATOREC
JMP E  ! Errore

OPERATOREA:			! OPERATOREA:
CMP BX,65			! if(BX==65) goto COSTO1
JE COSTO1
CMP BX,66			! if(BX==66) goto COSTO2
JE COSTO2
CMP BX,67			! if(BX==67) goto COSTO3
JE COSTO3

OPERATOREB:			! OPERATOREB:
CMP BX,65			! if(BX==65) goto COSTO2
JE COSTO2
CMP BX,66			! if(BX==66) goto COSTO0
JE COSTO0
CMP BX,67			! if(BX==67) goto COSTO3
JE COSTO3

OPERATOREC:			! OPERATOREC:
CMP BX,65			! if(BX==65) goto COSTO2
JE COSTO2
CMP BX,66			! if(BX==66) goto COSTO2
JE COSTO2
CMP BX,67			! if(BX==67) goto COSTO2
JE COSTO2

COSTO0:				! COSTO0:
MOV BX,0			! BX=0;
JMP E				! goto E

COSTO1:				! COSTO1:
MOV BX,1			! BX=1;
JMP E

COSTO2:				! COSTO2
MOV BX,2			! BX=2;
JMP E

COSTO3:				! COSTO3
MOV BX,3			! BX=3;
JMP E


E:
MOV SP,BP
RET


.SECT .DATA
PAROLA: .SPACE  1024
_NOME: .ASCIZ"rubrica.txt"
_OPERATORECASA: .ASCII"rom.txt"
.SECT .BSS