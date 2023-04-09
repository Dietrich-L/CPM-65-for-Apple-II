;DOS 3.3 Bootsector


GBAS	= $26		;LOWRES graphics base; Applesoft $0900; DOS $0400
SLOT16	= $2B		;Slot# * 16
SECNR	= $3D
SECRD	= $3E		;ROM sector read routine
TRACKNR	= $41

;control codes

CR	= $0D
LF	= $0A
EOT	= $00


	ORG $800

          DB $01		;DOS3.3 marker

BOOT      LDA GBAS+1
          CMP #$09		;check for BOOT already loaded
          BNE BOOT1
	CMP #$A8		;last page?
	BEQ BOOT5
          LDA SLOT16
          LSR A
          LSR A
          LSR A
          LSR A
          ORA #$C0
          STA SECRD+1		;set ROM sec read routine
          LDA #$5C
          STA SECRD
          CLC
          LDA BOOT2ADR		;$B6
          ADC BOOT2ADR+1	;$09
          STA BOOT2ADR		;$BF
BOOT1     LDX BOOT2ADR+1
          BMI BOOT2
          LDA SECTAB,X
          STA SECNR		;set sector nr
          DEC BOOT2ADR+1
          LDA BOOT2ADR
          STA GBAS+1		;set target page
          DEC BOOT2ADR
          LDX SLOT16
          JMP (SECRD)

BOOT2	INC TRACKNR		;set for track 1
	LDA #7			;sectors 7..0
	STA BOOT2ADR+1
	LDA #$AF		;to page $AF..$A8
	STA BOOT2ADR
	BNE BOOT1

BOOT5	LDY $90			;move BIOS to $B600
BOOT6	LDA $B500,Y
	STA $B700,Y
	DEY
	BPL BOOT6
BOOT7	LDA $B400,Y
	STA $B600,Y
	DEY
	BPL BOOT7
	JSR $FE89		;set normal text
        JSR $FE93		;set video
        JSR $FB2F		;init text screen
	LDY #0
BOOT3	LDA BOOTM,Y
	BEQ BOOT4
	ORA #$80		;set bit 7
	JSR $FDED
	INY
	BNE BOOT3

BOOT4	LDA #$B6
	STA BOOT2ADR
	LDX SLOT16
          JMP (BOOTCONT)	;$B700

SECTAB	DB $00,$0D,$0B,$09,$07,$05,$03,$01,$0E	;RWTS
	DB $0C,$0A,$08,$06,$04,$02,$0F		;available?

BOOTM	DB 'CPM-65 Boot V0.1',CR,EOT


BOOTCONT	DB $00
BOOT2ADR	DB $B6-6,$09+6

        END


