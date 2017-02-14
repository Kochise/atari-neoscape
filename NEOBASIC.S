; /////////////////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////
; ///                                                                   ///
; ///                       >>> NEON 3D BASIC <<<                       ///
; ///                                                                   ///
; /////////////////////////////////////////////////////////////////////////
; ///                                                                   ///
; /// FIN AOUT 1995, JE VEUX FAIRE DES MONTAGNES FRACTALES POUR NEON.   ///
; /// JE FAIS UNE PETITE ROUTINE EN GFA QUI SAUVE UN OBJET AU FORMAT    ///
; /// ASCII. JE LANCE NEON, J'ESSAYE DE CHARGER LE FICHIER, MAIS IL Y A ///
; /// UNE ERREUR. JE PREND 7UP, JE VERIFIE MON FICHIER. CORRECT. J'AI   ///
; /// LES NERFS APRES QUELQUES AUTRES ESSAIS INFRUCTUEUX. JE TELEPHONE  ///
; /// A COMPOSCAN FRANCE, JE LEUR EXPOSE MON PROBLEME, ET ME DISE QU'IL ///
; /// VONT EN PARLER AUX PROGRAMMEUR DE NEON. CINQ MINUTES PLUS TARD,   ///
; /// ILS ME RAPPELLENT ET ME DISENT QU'EN EFFET, NEON N'EST PAS TOUT A ///
; /// FAIT FINI, ET QU'IL NE CHARGE PAS LES FICHIER ASCII QU'IL GENERE. ///
; /// JE ME LANCE DANS UN INTERFACAGE GFA-ASSEMBLEUR. L'ENSEMBLE EST    ///
; /// PLUTOT FOIREUX, ET DEBUT JANVIER 1996, J'ABANDONNE.               ///
; /// FIN JUIN 1996, JE ME REMET AU TRAVAIL POUR HONORER MA PROMESSE DE ///
; /// FAIRE UN CREATEUR DE MONTAGNES FRACTALES POUR NEON. JE BALANCE    ///
; /// MES PREMIERES ROUTINES GFA ET ASSEMBLEUR, ET DEBUT D'UN RUDE      ///
; /// TRAVAIL, NEOSCAPE !                                               ///
; /// APRES QUELQUES ESSAIS, RESULTATS EXCELLENTS. SEULEMENT, A FORCE   ///
; /// DE TRAVAILLER SOUS L'EDITEUR DE NEON, JE ME REND COMPTE DE SA     ///
; /// PRINCIPALE FAIBLESSE, SA LENTEURE HELVETIENNE (SURTOUT LORSQU'ON  ///
; /// A DEJA TRAVAILLE SOUS L'EDITEUR DE CLOE). CHANGEMENT DE DIRECTION ///
; /// POUR ABOUTIR A NEON 3D BASIC (QUI INCLUS D'ORIGINE NEOSCAPE).     ///
; /// PLUS BASE SUR LE GFA QUE SUR LE C (SCRIPT POV), NEON 3D BASIC SE  ///
; /// DEMARQUE DE SES CONCURRENTS DE PAR SA SIMPLICITE ET DE SON        ///
; /// INTERFACE MI TEXTE, MI GRAPHIQUE. UNE ETOILE EST NEE.             ///
; ///                                                                   ///
; ///////////////////////////// REMERCIEMENTS /////////////////////////////
; ///                                                                   ///
; /// THANKS TO : ATARI FOR THE FALCON, GREATEST COMPUTER OF THE WORLD  ///
; ///             DIGITAL RESEARCH FOR THEIR FAILING BUT GOOD TOS 4.04  ///
; ///             HISOFT FOR THEIR EXCELLENT DEVPAC 3.1 AND DSP         ///
; ///             ME, FOR MY GREAT AFX LABORATORY OS (AFX-LOS)          ///
; ///                                                                   ///
; /////////////////////// STRUCTURE DES FICHIERS AF3 //////////////////////
; ///                                                                   ///
; ///          | TAILLE| FORMAT | CONTENU                               ///
; /// ---------+-------+--------+-------------------------------------- ///
; ///                                                                   ///
; ///////////////////////// HISTOIRE DU PROGRAMME /////////////////////////
; ///                                                                   ///
; /// > NEOBASIC VERSION 0.01 DU 06/21/06/1996                          ///
; ///    |                                                              ///
; ///    | RECUPERATION DES ROUTINES D'INITIALISATION DE AFG VIEWER     ///
; ///    | (AFX-LOS) ET EN TETE DU FICHIER PROGRAMME.                   ///
; ///    | '______________________________________________________'     ///
; ///    |                                 |                            ///
; ///    '-> VERSION 0.01 (19H05 -> 19H32)-' (00H27 : 00H27)            ///
; ///                                                                   ///
; /////////////////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////
;

START_PROG	move.l	4(SP),A6		; Adresse de la BASEPAGE
	lea	$80(A6),A6		; Adresse de la COMMAND-TAIL
	move.b	(A6)+,D0		; Taille de la COMMANDE-TAIL (ATTENTION : Format PASCAL)
	beq	NO_COMMAND		; Branche la sous routine NO_COMMAND si la taille de la COMMAND-TAIL est nulle
	move.b	#1,EXIST_COMMAND	; Mets le Flag d'existence de la COMMAN-TAIL … 1
	lea	AFG_NAME,A5		; Installe AFG_NAME dans A5
COPY_AF3_NAME	move.b	(A6)+,(A5)+		; Copie la COMMAND_TAIL … partir de AFG_NAME
	subq.b	#1,D0		; Soustrait 1 … D0 (Taille de la COMMAND-TAIL encore … copier)
	bne	COPY_AF3_NAME		; Branche la sous routine COPY_AFG_NAME tant qu'il reste de la COMMAND-TAIL … copier
	clr.b	(A5)		; Mets un OCTET nul … la fin de la chaine (ATTENTION : Transformation au format C)
INIT_PRG_&_MEM	movea.l	4(SP),A6		; Adresse de la BASEPAGE
	move.l	$C(A6),D0		; Taille du programme
	add.l	$14(A6),D0		; Additionne la taille du SEGMENT DATA … D0
	add.l	$1C(A6),D0		; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0		; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0		; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1		; Copie D0 dans D1 (Taille … r‚server)
	add.l	A6,D1		; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1		; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	move.l	SP,OLD_STACK		; Sauvegarde l'ancienne PILE
	movea.l	D1,SP		; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D0,-(SP)		; EmPILE la taille … reserver	\
	move.l	A6,-(SP)		; EmPILE l'adresse du programme |-> Rend le reste de la m‚moire au systŠme
	clr.w	-(SP)		; R‚serv‚                       |
	move.w	#$4A,-(SP)		; - M_SHRINK -                  |
	trap	#1		; *** GEMDOS ***                /
	lea	12(SP),SP		; Restaure la PILE
	tst	D0		; Si D0<>0, problŠme grave
	bne	SYS_ERROR		; Branche la sous routine SYS_ERROR si D0 n'est pas nul
MONITOR_TEST	move.l	#$FFFF8006,A0		; Registre Moniteur
	move.b	(A0),D0		; Type de moniteur
	andi.b	#%11,D0		; Idem
	cmp.b	#2,D0		; Si pas VGA ...
	bne	NO_VGA		; ... on sort


NO_COMMAND	move.b	#0,EXIST_COMMAND	; Efface le Flag d'existance de la COMMAN-TAIL
	rts			; Retour d'o— l'on vient
NO_VGA	clr.w	D0		; Pas d'erreur
	bra	EXIT_PROG		; Zou...
SYS_ERROR	move.l	OLD_STACK,SP		; Restaure l'ancienne PILE
EXIT_PROG	move.w	DO.-(SP)		; EmPILE le code de l'erreur \
	move.w	#$4C,-(SP)		; - P_TERM -                 |-> Quitte proprement
	trap	#1		; *** GEMDOS ***             /



EXIST_COMMAND	ds.b	1		; Flag pour l'existence de la COMMAND-TAIL o— non
OLD_STACK	ds.l	1		; Ancienne PILE
DTA	ds.b	21		; Le tampon DTA
ATTRIBUTES	ds.b	1		; Les attributs du fichier
HOUR_FILE	ds.w	1		; L'heure du fichier
DATE_FILE	ds.w	1		; La date du fichier
SIZE_FILE	ds.l	1		; La taille du fichier
NAME_FILE	ds.b	14		; Le nom du fichier
AF3_NAME	ds.b	256		; Un peu de place pour la COMMAND-TAIL
