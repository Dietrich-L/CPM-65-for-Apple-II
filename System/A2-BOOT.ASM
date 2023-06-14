;CPM-65 Bootsector

;V0.1	12.04.23	first attempt
;V0.2	13.05.23	2nd try

VERSION	= $02

;--- Page 00 adresses

GBAS	= $26		;LOWRES graphics base; Applesoft $0900; DOS $0400
SLOT16	= $2B		;Slot# * 16
SECNR	= $3D
SECRD	= $3E		;ROM sector read routine
TRACKNR	= $41

;--- CPM-65 System adresses

BIOS00	= $A700		;BIOS cold start entr

;APPLE I/O adresses

KBD	= $C000		;Keyboard key, bit 7 =1
KBDSTRB	= $C010		;Keyboard strobe

;Apple ROM adresses

RDKEY	= $FD0C
COUT	= $FDED
SETVID	= $FE95

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
          ORA #$C0
          STA SECRD+1	;set ROM sec read routine
          LDA #$5C
          STA SECRD
	LDA #BIOS00/256+$08	;last page of BIOS Code
          STA BOOT2ADR		;= $AF
BOOT1     LDX BOOT2ADR+1
          BMI BOOT3
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

BOOT5	JMP BIOS00


SECTAB	DB $00,$0D,$0B,$09,$07,$05,$03,$01,$0E	;sector table
	DB $0C,$0A,$08,$06,$04,$02,$0F

BOOTM	DB '  CPM-65 APPLE II BOOT V'
	DB VERSION/16+$30,'.',VERSION*$1000/$1000+$30,CR,LF,EOT


BOOTCONT	DB $00
BOOT2ADR	DB $00,$0F

        END


