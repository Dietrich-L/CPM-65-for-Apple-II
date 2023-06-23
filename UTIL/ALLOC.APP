;output a cr and lf
CRLF	LDA	#CR		;send
	JSR	CHROUT		;a cr
	LDA	#LF		;then a lf
;character output
CHROUT	LDX	#2		;send char
	JMP	PEM		;to console
;message output
msgout	ldx	#9		;send string
	jmp	pem		;to console
;line number counting and output
linnum	sed			;use line as decimal counter
	clc
	lda	line
	adc	#1
	sta	line
	cld
	lsr	a		;shift high digit to low
	lsr	a
	lsr	a
	lsr	a
	ora	#'0'		;make a digit
	jsr	chrout		;send it
	lda	line		;get line again
	and	#%00001111	;look at low
	ora	#'0'		;make it a digit
	jsr	chrout		;send it
	lda	#' '		;get space
	jsr	chrout		;send it
	rts

SETBAT	LDX #0		;forces BAT
	LDY #1		;set FCB1 to $120957$.$$$
SETBT1	LDA DUMMY,X
	STA (FCB1),Y
	INX
	INY
	CPY #12
	BCC SETBT1
	LDX #$16
	JSR PEM		;create dummy file
	LDX #$15
	JSR PEM		;Write dummy block
	LDX #$13
	JSR PEM		;Kill dummy file
	RTS


DUMMY	DB '$120957$$$$'
;bit mask table
BITMSK	DB	128,64,32,16,8,4,2,1
;block size messages
blkms0	DB	'1',EOT
blkms1	DB	'2',EOT
blkms2	DB	'4',EOT
blkms3	DB	'8',EOT
blkms4	DB	'16',EOT
;block size message pointers
blktbl	DW	blkms0,blkms1,blkms2,blkms3,blkms4
;opening message
opnmsg	DB	CR,LF,'CPM-65 DISK ALLOCATION MAP V2.09',CR,LF,CR,LF
	DB '   01234567890123456789012345678901'
	DB	CR,LF,EOT
nxtmsg	DB	cr,lf,'PRESS SPACE BAR TO SEE NEXT PAGE',EOT
;closing message
clsmsg	DB	'K BLOCKS FREE OF ',EOT
3SP	DB	'   ',EOT
ttlmsg	DB	' TOTAL',CR,LF,EOT

	END
