;CPM-65 Bootsector

;V0.1	12.04.23	first attempt
;V0.2	13.05.23	2nd try
;V0.3	19.06.23	Load CCP & BDOS via BIOS
;V0.4	20.06.23	CCP at $A800
;V0.5	23.06.23	BOOT drive detection

VERSION	= $05

;--- Page 00 adresses

GBAS	= $26		;LOWRES graphics base; Applesoft $0900; DOS $0400
SLOT16	= $2B		;Slot# * 16
SECNR	= $3D
SECRD	= $3E		;ROM sector read routine
TRACKNR	= $41

PTR	= $FA		;BIOS Pointer
DMAV	= $FE		;DMA-VECTOR

;--- CPM-65 System adresses

CCP	= $A800
BIOS00	= $B700		;BIOS cold start entr
HOME	= BIOS00+24
SELDSK	= BIOS00+27
SETSEC	= BIOS00+33
READ	= BIOS00+36
BUILD_GCR = BIOS00+$30


;APPLE I/O adresses

KBD	= $C000		;Keyboard key, bit 7 =1
KBDSTRB	= $C010		;Keyboard strobe

;Apple ROM adresses

RDKEY	= $FD0C
COUT	= $FDED
SETVID	= $FE95

;Constants

SPT	= 16		;SECTORS PER TRACK

;control codes

CR	= $0D
LF	= $0A
EOT	= $00


	ORG $800

	DB $01		;# sectors to be loaded to $800 ff.

BOOT	LDA GBAS+1
	CMP #$09	;check for BOOT already loaded
	BNE BOOT1
	LDA SLOT16
	LSR A
	LSR A
	LSR A
	LSR A
	STA PTR+1		;save slot #
	ORA #$C0
	STA SECRD+1	;set ROM sec read routine
	LDA #$5C
	STA SECRD
BOOT1	LDX BOOT2ADR+1
	CMP #BIOS00/256-1	;last BIOS sector loaded?
	BEQ BOOT3
	LDA SECTAB,X		;convert to phys sector
	STA SECNR		;set sector nr
	DEC BOOT2ADR+1
	LDA BOOT2ADR
	STA GBAS+1		;set target page
	DEC BOOT2ADR
	LDX SLOT16
	JMP (SECRD)

BOOT3	JSR $FE89		;set normal text
        JSR $FE93		;set video
        JSR $FB2F		;init text screen
	LDA #3
	JSR SETVID		;set to 80 coloumn mode
	LDY #0
BOOT4	LDA BOOTM,Y		;Print Boot message
	BEQ BOOT5
	ORA #$80		;set bit 7
	JSR COUT
	INY
	BNE BOOT4

BOOT5	JSR DISK_INIT
	JMP BIOS00


DISK_INIT		;init disk driver

	JSR BUILD_GCR	;build GCR tables

    ; set Boot disk


DSKIN1	LDA PTR+1		;set boot drive
	LDY #0		;default boot drive is A:
	CMP #5
	BNE DSKIN2	;if slot#=5 then boot from C:
	LDY #2
DSKIN2	TYA
	JSR SELDSK 	;set Disk to current drive
	JSR HOME	;and home it

    ; Read the BDOS & CCP from track 1 into memory

	lda #CCP/256
	sta DMAV+1
	LDA #SPT	;1. sector on track 1
	STA 0
	LDA #0
	STA 1
	STA 2
	sta DMAV
    
    ; Copy from the beginning of CCP
MOVE1	LDA #0
	JSR SETSEC
	JSR READ
	BCS MOVEX
	INC 0		;next sector
        inc DMAV+1
	LDA DMAV+1
        CMP #BIOS00/256	;BIOS reached?
	BNE MOVE1
MOVEX	RTS


SECTAB	DB $00,$0D,$0B,$09,$07,$05,$03,$01,$0E	;sector table
	DB $0C,$0A,$08,$06,$04,$02,$0F

BOOTM	DB '  CPM-65 APPLE II BOOT V'
	DB VERSION/16+$30,'.',VERSION*$1000/$1000+$30,CR,LF,EOT

BOOT2ADR	DB BIOS00/256+$08	;last page of BIOS Code
		DB $0F			;start with sec $0F

        END


