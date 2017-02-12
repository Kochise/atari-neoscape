; /// INITIALISATION DU PROGRAMME ///

INIT_PRG_MEM	movea.l	4(SP),A6		; Adresse de la BASEPAGE
	move.l	$C(A6),D0		; Taille du programme
	add.l	$14(A6),D0		; Additionne la taille du SEGMENT DATA … D0
	add.l	$1C(A6),D0		; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0		; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0		; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1		; Copie D0 dans D1 (Taille … r‚server)
	add.l	A6,D1		; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1		; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	move.l	SP,OLD_STACK
	movea.l	D1,SP		; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D0,-(SP)		; EmPILE la taille … reserver	\
	move.l	A6,-(SP)		; EmPILE l'adresse du programme |-> Rend le reste de la m‚moire au systŠme
	clr.w	-(SP)		; R‚serv‚                       |
	move.w	#$4A,-(SP)		; - M_SHRINK -                  |
	trap	#1		; *** GEMDOS ***                /
	lea	12(SP),SP
	tst	D0		; Si D0<>0, problŠme grave
	bne	SYS_ERROR

; /// RESERVE DE LA MEMOIRE ///

	clr.w	-(SP)
	move.l	#307200,-(SP)
	move.w	#$44,-(SP)
	trap	#1
	addq.l	#8,SP
	tst	D0
	beq	SYS_ERROR
	move.l	D0,NEW_SCREEN
	move.l	D0,A6
	move.l	#76799,D0
CLS	clr.l	(A6)+
	dbf	d0,CLS
	
; /// CHANGE LA RESOLUTION ///

	move.w	#-1,-(SP)
	move.w	#88,-(SP)
	trap	#14
	addq.l	#4,SP
	move.w	D0,OLD_MODE
	move.w	#2,-(SP)
	trap	#14
	addq.l	#2,SP
	move.l	D0,OLD_SCREEN
	move.w	#-1,-(SP)
	move.l	NEW_SCREEN,-(SP)
	move.l	NEW_SCREEN,-(SP)
	move.w	#5,-(SP)
	trap	#14
	add.l	#12,SP
	move.w	#%0000000000010100,-(SP)
	move.w	#88,-(SP)
	trap	#14
	addq.l	#4,SP

; /// MISE EN PLACE DES COULEURS ///

	clr.l	d0-7
	move.l	NEW_SCREEN,A6
	move.l	A6,A5




; /// ATTEND UNE TOUCHE ///

	move.w	#7,-(SP)
	trap	#1
	addq.l	#2,SP

; /// REMET LA RESOLUTION ///

	move.w	OLD_MODE,-(SP)
	move.w	#88,-(SP)
	trap	#14
	addq.l	#4,SP
	move.w	#-1,-(SP)
	move.l	OLD_SCREEN,-(SP)
	move.l	OLD_SCREEN,-(SP)
	move.w	#5,-(SP)
	trap	#14
	add.l	#12,SP
	move.l	NEW_SCREEN,-(SP)
	move.w	#$49,-(SP)
	trap	#1
	addq.l	#6,SP

; /// SORTIE DU PROGRAMME ///

SYS_ERROR	move.l	OLD_STACK,SP		; Restaure l'ancienne PILE
EXIT_PROG	move.w	D0,-(SP)		; EmPILE le code de l'erreur \
	move.w	#$4C,-(SP)		; - P_TERM -                 |-> Quitte proprement
	trap	#1		; *** GEMDOS ***             /

; /// VARIABLES ///

OLD_STACK	ds.l	1		; Ancienne PILE
OLD_MODE	ds.w	1
OLD_SCREEN	ds.l	1
NEW_SCREEN	ds.l	1