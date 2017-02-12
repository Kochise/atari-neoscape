	clr.l	-(SP)
	move.w	#$20,-(SP)
	trap	#1
	addq.l	#6,SP
	lea	PAL_MONT,A5
	move.l	#$FF9800,A6
	move.b	#255,D0
PAINT_PAL	move.l	(A5)+,D1
	move.l	D1,D2
	clr.b	D2
	rol.l	#8,D2
	move.b	D1,D2
	move.l	D2,(A6)+
	dbf	D0,PAINT_PAL
	clr.l	-(SP)
	move.w	#$20,-(SP)
	trap	#1
	addq.l	#6,SP
	clr.w	-(SP)
	move.w	#$4C,-(SP)
	trap	#1
PAL_MONT	incbin	D:\VISTNEON\MONT.DAC
