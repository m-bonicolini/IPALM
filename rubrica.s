_LSEEK=19
_PUTCHAR=122
.SECT .TEXT

PRINT_RUBRICA:	!void print_rubrica(void)

MOV BP,SP
MOV (fd),0			! fd=0;

PUSH 0
PUSH rubrica
PUSH _OPEN
SYS				! AX=open("rubrica.txt",0);

MOV (fd),AX			! fd=AX;
STA:
MOV DI,video			! DI=&video[0];
PUSH 1024
PUSH DI
PUSH (fd)
PUSH _READ
SYS				! AX=read(fd,DI,1024);


F:
PUSH (fd)
PUSH _CLOSE
SYS				! AX=close(fd);
MOV SP,BP
RET

INSERT:
MOV BP,SP
PUSH 2
PUSH rubrica
PUSH _OPEN
SYS				! AX=open("rubrica.txt",2);
MOV (fd),AX			! fd=AX;
MOV CX,0			! CX=0;


MOV AX,0			! AX=0;
MOV DX,0			! DX=0;
PUSH 2
PUSH DX
PUSH AX
PUSH (fd)
PUSH _LSEEK			! lseek(fd,DX,2);
SYS

MOV BX,0			! BX=0;
MOV DI,contatto			! DI=contatto;
MOV CX,0			! CX=0;


INSERT_LOOP:
PUSH _GETCHAR
SYS				! AX=getchar();
MOV (DI),AX			! *(DI)=AX;

ADD CX,1			! CX+=1;
CMP (DI),10			! if(*DI==10) goto DOPO_LOOP
JE DOPO_LOOP

CMP (DI),32			! if(*DI==32) goto SOMMA_SPACES
JE SOMMA_SPACES

ADD DI,1			! DI++;
JMP INSERT_LOOP			! goto INSERT_LOOP

SOMMA_SPACES:			! SOMMA_SPACES:
ADD BX,1			! BX+=1;
CMP BX,3			! if(BX==3) goto LEND1
JE LEND1
ADD DI,1			! DI++;
JMP INSERT_LOOP			! goto INSERT_LOOP

DOPO_LOOP:			! DOPO_LOOP:
PUSH CX				
PUSH contatto
PUSH 3
PUSH _WRITE
SYS				! AX=write(3,contatto,CX);

LEND1:
PUSH (fd)
PUSH _CLOSE			! AX=close(fd);
SYS
MOV SP,BP
RET

.SECT .DATA
mytemp2: .WORD 0
contatto: .SPACE 300
video: .SPACE 1024
rubrica: .ASCIZ"rubrica.txt"
fd: .WORD 0
word: .WORD 0
nline: .ASCIZ"%s\n"
count: .WORD 0
mymsg:.ASCIZ"Rubrica piena\n"
flag: .WORD 0
mytemp: .WORD 0
