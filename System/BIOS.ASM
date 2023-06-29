;CPM-65 version adapted 2023 by Dietrich Lausberg
;CPM-65 BIOS for Apple II

; This BIOS makes heavy use of David Givens code for CP/M-65
; CP/M-65 Copyright © 2023 David Given
; This file is licensed under the terms of the 2-clause
; BSD license

;D. LAUSBERG	(C) 2023
;V0.1	06.04.23	initial version
;V0.2	11.06.23	error corrections &CR/US
;V0.3	12.06.23	Drives A - D support
;V0.4	13.06.23	error corrections writetrack
;V0.5	15.06.23	single sector R/W
;V0.6	19.06.23	save & load ROM page 0 cells
;V0.7	20.06.23	CCP at $A800
;V0.8	21.06.23	minor corrections

VERSION	= $08		;VERSION NUMBER

;PAGE 00 CELLS

DMAV	= $FE		;DMA-VECTOR
DIRBFV	= $FC		;DIRBF-VECTOR
PTR	= $FA		;BIOS Pointer
DPHV	= $F8		;DPH-VECTOR
JPBDOS	= $F0

;SYSTEM CONSTANTS

CCP	= $A800
BEGIN	= $B700		;BIOS cold start
DMABF	= BEGIN-256	;default DMA buffer at $B500
DIRBF	= DMABF-256	;dir sector buffer at $B400

;APPLE I/O adresses

KBD_READ	= $C000		;Keyboard key, bit 7 =1
KBD_STROBERESET	= $C010		;Keyboard strobe

;Apple ROM adresses

RDKEY	= $FD0C
COUT	= $FDED
SETVID	= $FE95

;CONTROL CODES

BREAKC	= $03		;BREAK CODE
TAB	= $09		;TAB
CLS	= $0C		;CLEAR SCREEN
CR	= $0D		;CR
ESC	= $1B		;ESC
FS	= $1C		;cursor right
US	= $1F		;cursor up
SP	= $20		;space

;ERROR CODES

WRPROT	= $FC
ILLFUNC	= $F8		;illegal BIOS function
NO_DEV	= $F4

;CONSTANTS

MAXTRK	= 35		;MAX TRACKS

SPT	= 16		;SECTORS PER TRACK
SPTDIV	= 4		;log(2) SPT
SPB	= 4		;SECTORS PER BLOCK
SPBDIV	= 2		;LOG(2) SPB
SYS	= 32		;SYSTEM sectors
BPD	= MAXTRK*SPT-SYS/SPB-1	;BLOCKS PER DISK
DIRSCS	= 16		;DIRECTORY SECTORS
DIRMSK	= %11111111	;DIR MASK FOR BAT
RPEXT	= 8*SPB*2 	;RECORD PER EXTENT
BATSIZ	= BPD/8		;SIZE OF BAT

MAXTRY	= 10		;MAX TRIES ON ERROR

;----------------

SCREEN_80STOREOFF = $c000
SCREEN_80STOREON  = $c001
SCREEN_80COLOFF   = $c00c
SCREEN_80COLON    = $c00d
SCREEN_PAGE2OFF   = $c054
SCREEN_PAGE2ON    = $c055


; It's tempting to bake in the $60 offset for the drive unit 
; at slot 6... but this changes the timing of the instructions 
; which access these registers, and then writes don't work!
; You _must_ use lda <addr>,X or sta <addr>,X instructions
; (the right ones; they take 4 and 5 cycles respectively).

DISK_PH0OFF   = $c080 ; Q0
DISK_PH0ON    = $c081
DISK_PH1OFF   = $c082 ; Q1
DISK_PH1ON    = $c083
DISK_PH2OFF   = $c084 ; Q2
DISK_PH2ON    = $c085
DISK_PH3OFF   = $c086 ; Q3
DISK_PH3ON    = $c087
DISK_MOTOROFF = $c088 ; Q4
DISK_MOTORON  = $c089
DISK_DRIVE1   = $c08a ; Q5
DISK_DRIVE2   = $c08b
DISK_SHIFT    = $c08c ; Q6
DISK_LOAD     = $c08d
DISK_READ     = $c08e ; Q7
DISK_WRITE    = $c08f

DECODE_TABLE_START = $96

disk_sixes_buffer = $300
track_buffer = $B000

;--- BIOS code ---

	ORG BEGIN

FBIOS	JMP BOOT		; 00
	JMP WBOOT		; 01
	JMP CONST		; 02
	JMP CONIN		; 03
	JMP CONOUT		; 04
	JMP NOFUNC		; 05
	JMP NOFUNC		; 06
	JMP NOFUNC		; 07
	JMP HOME		; 08
	JMP SELDSK		; 09
	JMP NOFUNC		; 0A
	JMP SETSEC		; 0B
	JMP READ		; 0C
	JMP WRITE		; 0D
	JMP NOFUNC		; 0E
	JMP GET_VERSION		; 0F

;==================================

BUILD_GCR		;BIOS function $10
	ldx #$03	; Build the GCR tables.
	ldy #0
BGCR2	stx PTR
        txa
        asl a		; check for double ones
        bit PTR
        beq reject
        ora PTR		; check for double zeros
        eor #$ff
        and #$7e
BGCR1	bcs reject
	lsr a
	BNE BGCR1
        txa
        ora #$80
        sta encode_tab,Y
        tya
        sta decode_tab-DECODE_TABLE_START+$80,X
        iny
reject	inx
	BPL BGCR2
	RTS

;========== DATA AREA =============

DPHA	DW DIRBF	;DISK PARAMETER HEADER
	DW DMABF	;FOR DRIVE A to D
	DW BAT

	DB SPB-1	;DISK PARAMETER BLOCK FOR DISK A
	DB SPBDIV
	DW BPD
	DB DIRSCS
	DB DIRMSK
	DB RPEXT
	DB SYS,0,0
	DB BATSIZ

BAT	DB %10000000	;Block Allocation Table Drive A-D
	DS BATSIZ+1,0	;17 Bytes

;--- SLOT TABLE Floppy Drives ---

SLOTTAB	DB 6*16, 5*16
SECS	DS 3, $00
DRIVE	DB 0
DISK_SLOT DB 0
DRIVENR DB 0
motor_countdown DB 0
current_phase	DB 0

wanted_track	DB 0
wanted_sector	DB 0
PHASE_TAB	DS 4,MAXTRK*2+2

sector_prologue		DB $ad, $aa, $d5 ; REVERSED
sector_prologue_len = 3
sector_epilogue		DB $ff, $eb, $aa, $de ; REVERSED
sector_epilogue_len = 4

reverse_sector_map	DB $00,$07,$0E,$06,$0D,$05,$0C,$04
			DB $0B,$03,$0A,$02,$09,$01,$08,$0F

;--- BIOS data area ---

YBUF	DB 0	;Y buffer for CHRIN & CHROUT
CHARBUF	DB 0
CHR	DB 0

;==================================

BOOT	LDA #$4C		;SET JMP BDOS
	STA JPBDOS
	LDA #CCP
	STA JPBDOS+1
	LDA #CCP/256
	STA JPBDOS+2
	LDA DRIVE		;set actual drive
	LDX #$0E		;VIA BDOS
	JSR JPBDOS
	LDY #PZ_BUF-PZ_TAB-1	;save page 0 cells
STOPZ1	LDX PZ_TAB,Y
	LDA 0,X
	STA PZ_BUF,Y
	DEY
	BPL STOPZ1
	LDX #0 			;WARM BOOT
	JMP JPBDOS


WBOOT	LDA DRIVE		;SELECT DEFAULT DRIVE
	JSR SELDSK
	RTS


CONST	ldx motor_countdown	
	BEQ CONST3
CONST1	dec motor_countdown
	BNE CONST3
CONST2	ldx DISK_SLOT
	lda DISK_MOTOROFF,X
CONST3	lda KBD_READ
	BPL CONST4
	STA KBD_STROBERESET
        AND #$7F
	SEC
CONST5	STA CHARBUF
	rts

CONST4	LDA #0
	CLC
	BEQ CONST5


CONIN	STY YBUF	;CHR input; CHR in A, 8 bit transparent
	PHA
	JSR SWAP_PZ	;restore page 0 cells for ROM
	PLA
	ldx DISK_SLOT	; Turn the disk motor off
	lda DISK_MOTOROFF,X
	lda #0
	sta motor_countdown
	LDA CHARBUF	;CTRL-C pressed?
	BNE CONIN2
	JSR RDKEY	;read key
	AND #$7F	;clear bit 7
CONIN2	LDY #0
	STY CHARBUF
	PHA
	JSR SWAP_PZ	;restore page 0 cells for ROM
	PLA
	LDY YBUF
	RTS


CONOUT	STY YBUF	;PRINTS CHR in A TO CON
	PHA
	JSR SWAP_PZ	;restore page 0 cells for ROM
	PLA
	ORA #$80	;set bit 7
	CMP #TAB+$80
	BNE CONOU4
	LDA #FS+$80	;TAB --> FS
CONOU4	CMP #CR+$80
	BNE CONOU3
	JSR COUT	;if CR then print CR & US
	LDA #US+$80
CONOU3	JSR COUT
	JSR CONST
CHROU1	PHA
	JSR SWAP_PZ	;save page 0 cells for ROM
	PLA
	LDY YBUF
	RTS


HOME	lda #0
	jsr seek_to_track	;move to track 0
	LDA #$FF		;seek error
HOMEX	RTS


SELDSK	CMP #4			;TEST FOR DRIVE A to D
	BCS SELDS3
	STA DRIVE
	LSR A
	TAY
	LDA SLOTTAB,Y		;set SLOT
	STA DISK_SLOT
	STA WTRK_SL+1		;copy slot nr into write_track routine
	LDA DRIVE
	AND #$01
	STA DRIVENR		;SELECT DISK LOGICAL
	LDA #DPHA		;SET DPHVEC
	STA DPHV
	LDA #DPHA/256
	STA DPHV+1
	CLC
SELDSX	RTS

SELDS3	LDA #$F9		;ILLEGAL DRIVE NR
	RTS


SETSEC	TAX			;sector pointer for p.00 in Accu
	LDA 0,X
	STA SECS
	LDA 1,X
	STA SECS+1
	LDA 2,X
	STA SECS+2
	RTS


READ	JSR FD_ST		;convert sec nr to sector/track
	BCS READX
	LDA wanted_track
	jsr seek_to_track
	BCS READX
	JSR read_sector
READX	RTS


WRITE	JSR FD_ST		;convert sec nr to sector/track
	BCS WRITEX
	LDA wanted_track
	jsr seek_to_track
	BCS WRITEX			;do normal write
	JSR write_sector
WRITEX	RTS


GET_VERSION			;GET VERSION NUMBER

	LDA #VERSION
	RTS


NOFUNC	LDA #ILLFUNC
	SEC
	RTS


;====== SUBROUTINES =======

SWAP_PZ	LDY #PZ_BUF-PZ_TAB-1	;swap page 0 cells
SWPPZ1	LDX PZ_TAB,Y
	LDA 0,X
	PHA
	LDA PZ_BUF,Y
	STA 0,X
	PLA
	STA PZ_BUF,Y
	DEY
	BPL SWPPZ1
	RTS

PZ_TAB	DB $1F,$20,$21,$22,$23,$24,$25,$28,$29,$2A,$2B
	DB $30,$31,$32,$33,$36,$37,$38,$39,$4E,$4F
	DB $EA,$EB,$EC,$ED,$EE
PZ_BUF	DS PZ_BUF-PZ_TAB,$00

; --- Disk handling --------------------------------------


FD_ST	LDA SECS	;calculate SECS _> Track & Sector
	STA wanted_track
	AND #SPT-1	;sector offset
	sta wanted_sector
	LDX #SPTDIV
	LDA SECS+1
FD_ST2	LSR A			;TRACK = SECS/16
	ROR wanted_track
	DEX
	BNE FD_ST2
	LDA wanted_track
	CMP #MAXTRK		;check for last track on disc
	LDA #$FB		;if C=1 sector not found error
	RTS


; Read sector into DMA

read_sector

    ; Start reading sector
	SEI
	; Wait for the next sector header
RTR2	jsr read_header
	cpy #$96
	BNE RTR2
	jsr read_gcr44
	jsr read_gcr44
	jsr read_gcr44
                    
	; Found a sector. Has it already been read?
	; Remember to undo the DOS sector skew.

	tax
	lda reverse_sector_map,X
	CMP wanted_sector
	BNE RTR2

	; Wait for the next data header.

	jsr read_header
	cpy #$ad
	BNE RTR2

	; Reads the first section of the sector data (the twos)
	; into the special buffer

	ldy #$56
	lda #0                  ; accumulated checksum
	ldx DISK_SLOT          ; remains here for the duration
RTR3	sty PTR
RTR4	ldy DISK_SHIFT,X
	BPL RTR4
	eor decode_tab-DECODE_TABLE_START,Y
	ldy PTR
	dey
	sta disk_twos_buffer,Y
	BNE RTR3

            ; Reads the second section (the sixes) into the 
            ; output buffer. Y is 0 on entry. X is DISK_SLOT

RTR5	sty PTR
RTR6	ldy DISK_SHIFT,X
	BPL RTR6
	eor decode_tab-DECODE_TABLE_START,Y
	ldy PTR
	sta (DMAV),Y
	iny
	BNE RTR5

            ; Read the checksum byte.
            ; X is still DISK_SLOT.

RTR7	ldy DISK_SHIFT,X
	BPL RTR7
	eor decode_tab-DECODE_TABLE_START,Y
	BNE RTR2

        ; We now have a successfully read sector
	; We just need to decode it

        ldy #0
        ldx #$56
RTR8	dex
	BPL RTR9
	ldx #$55
RTR9	lda (DMAV),Y
	lsr disk_twos_buffer,X
	rol a
	lsr disk_twos_buffer,X
	rol a
	sta (DMAV),Y
	iny
	BNE RTR8

        ; sector was successfully read
	CLI
	clc
	rts


; Seek to the track number in A with verify

seek_to_track
	PHA
	LDY DRIVE
	LDA PHASE_TAB,Y
	STA CURRENT_PHASE
	jsr motor_on
	PLA
	asl a		; convert to phase number
STT1	cmp current_phase
	BNE STT2
	LDY DRIVE
	STA PHASE_TAB,Y
	LSR A
	JSR VERIFY
	BCS STTX
	rts		;ready

STT2	ldy #$ff	; default to counting down
	BCC STT3
	ldy #1		; A > track, count up
STT3	pha
        jsr change_phase
        jsr change_phase
        pla
	JMP STT1

STTX	ASL A		;store real track nr in PHASE_TAB
	LDY DRIVE
	STA PHASE_TAB,Y
	LDA current_phase ;and try again
	LSR A
	jmp seek_to_track


    ; Takes in Y either +1 to change up, or -1 to change down
    ; Preserves it.
change_phase
	lda current_phase
	and #3
	asl a
	ora DISK_SLOT	; add in the slot offset
	tax
	sta DISK_PH0OFF,X  ; turn off current phase
	tya
	clc
	adc current_phase
	sta current_phase
	and #3
	asl a
	ora DISK_SLOT	; add in the slot offset
	tax
	sta DISK_PH0ON,X   ; turn on new phase

	; Waits the appropriate amount of time for the head to move

WAIT	lda #86
	sec
STT4	pha
STT5	sbc #1
	BNE STT5
        pla
        sbc #1
	BNE STT4
	rts


;Verify track nr in A

VERIFY	STA PTR+1
	jsr read_header
	cpy #$96
	BNE VERIFY
	jsr read_gcr44
	jsr read_gcr44
	CMP PTR+1		;is it the right Track?
	BNE VERIX
	CLC
	RTS

VERIX	SEC
	RTS


; Waits for a sector header. Returns the unencoded ID byte
; immediately following in Y. Preserves A. X = DISK_SLOT

read_header
	ldx DISK_SLOT

RHEAD1	ldy DISK_SHIFT,X
	BPL RHEAD1
	cpy #$d5
	BNE RHEAD1

RHEAD2	ldy DISK_SHIFT,X
	BPL RHEAD2
        cpy #$aa
	BNE RHEAD1

RHEAD3	ldy DISK_SHIFT,X
	BPL RHEAD3
	rts


; Reads and decodes a gcr44 value.
; X must be DISK_SLOT. Preserves and Y. Corrupts ptr

read_gcr44

RGCR1	lda DISK_SHIFT,X
	BPL RGCR1
	rol a
	sta PTR

RGCR2	lda DISK_SHIFT,X
	BPL RGCR2
	and PTR
	rts


motor_on			; Corrupts X, A
	LDX #$FF
	stx motor_countdown
	LDA DISK_SLOT
	ORA DRIVENR
	TAX
	STA DISK_DRIVE1,X	;select drive
	LDX DISK_SLOT
	sta DISK_MOTORON,X	;motor on
	rts


; Write the track buffer to disk.
; The timing in this routine is critical, so it's important 
; that it doesn't cross page boundary. Therefore this must 
; be the last routine in the BIOS so all the
; timing-critical bits are in the last page.

MEM
	DS MEM/256+1*256-MEM,$FF	;page alignment

write_sector
	SEI

    ; Timing here is super-critical. We have 32 cycles
    ; to write each byte, and we have to be on time
    ; Normally we'd just blat out the entire track worth
    ; of data in one go, but we don't have time to compute
    ; the sector encoding on the fly! So we have to do a
    ; normal sector-by-sector write: we compute a sector,
    ; then wait for its header, then write it, then compute
    ; the next sector and wait for its header. Because of
    ; the DOS sector skew we can write the entire track
    ; in two rotations.

write_track1

        ; Precompute the 2s and I/O buffer.

        ldx #0
        ldy #2

WTRK1	dey
	lda (DMAV),Y
	lsr a
	rol disk_twos_buffer,X
	lsr a
	rol disk_twos_buffer,X
	sta disk_sixes_buffer,Y
	inx
	cpx #$56
	BCC WTRK1
	ldx #0
	tya
	BNE WTRK1

        ldx #$55

WTRK2	lda disk_twos_buffer,X
	and #$3f
	sta disk_twos_buffer,X
	dex
	BPL WTRK2

        ; Wait for the right sector header.

WTRK3	jsr read_header
                cpy #$96
	BNE WTRK3
	jsr read_gcr44
	jsr read_gcr44
	jsr read_gcr44
            
            ; Found a sector. Has it already been read?
            ; Remember to undo the DOS sector skew.

	tax
	lda wanted_sector
	cmp reverse_sector_map,X
	BNE WTRK3

        ; Skip the tail of the sector header.

        ldy #4*4
        ; Each loop here is 8 cycles,
	; so four times round gives a byte.

WTRK4	CMP 0           ; 3
	dey             ; 2
	BNE WTRK4	; 3 for every iteration
            
        ldx DISK_SLOT
        lda DISK_LOAD,X    ; prime drive
        lda DISK_READ,X   
        BPL WTRK5
	CLI
	LDA #WRPROT
	sec             ; write protected
	rts

  ; Timing-critical part starts when the first byte is queued!

  ; Write the 40-cycle sync pulses. 40 cycles means that
  ; we actually end up with 0b1111.1111.00 on disk

WTRK5	lda #$ff
	sta DISK_WRITE,X  	; start writing
	cmp DISK_SHIFT,X
	ldy #4			; 2
	CMP 0			; 3
	
WTRK6	cmp (0,X) ; 6
	cmp (0,X) ; 6		; 12
	cmp (0,X) ; 6
	cmp (0,X) ; 6 		; 12
	NOP			; 2
	sta DISK_LOAD,X		; 5
	cmp DISK_SHIFT,X	; 4
	dey			; 2
	BNE WTRK6		; 3 if taken, 2 if not

	PHA		; waste four cycles for the last 40-cycle sync byte
	PLA		; plus five to sync up with the loop below = 9
	NOP

            ; Write prologue. (From here on we're at 32-cycles)
            ; Y is 0.

	ldy #sector_prologue_len ; 2

WTRK7	cmp (0,X) ; 6
	cmp (0,X) ; 6		; 12
	lda sector_prologue-1,Y	; 4
	sta DISK_LOAD,X		; 5
	cmp DISK_SHIFT,X	; 4
	NOP                     ; 2
	dey			; 2
	BNE WTRK7		; 3 if taken, 2 if not

            ; Write out the 2s buffer
            ; Y is 0.

	tya			; 2
	ldy #$56		; 2
WTRK8	eor disk_twos_buffer-1,Y ; 5 (always crosses page boundary)
	tax			; 2
	lda encode_tab,X	; 4
WTRK_SL	ldx #0			; 4  erite slot nr to WTRK_SL+1
	sta DISK_LOAD,X		; 5
	cmp DISK_SHIFT,X	; 4
	lda disk_twos_buffer-1,Y ; 5 (always crosses page boundary)
	dey			; 2
	BNE WTRK8		; 3 if taken, 2 is not

		; Write out the 6s buffer
		;(y is zero)

WTRK9	eor disk_sixes_buffer,Y	; 4
	tax			; 2
	lda encode_tab,X	; 4
	ldx DISK_SLOT		; 4
	sta DISK_LOAD,X		; 5
	ora DISK_SHIFT,X	; 4
	lda disk_sixes_buffer,Y	; 4
	iny			; 2
	BNE WTRK9		; 3 if taken, 2 if not

            ; Write checksum byte

	tax			; 2
	lda encode_tab,X	; 4
	CMP 0
	NOP 			; 5
	ldx DISK_SLOT		; 4
	sta DISK_LOAD,X		; 5
	ora DISK_SHIFT,X 	; 4

            ; Write epilogue.
            ; X is still DISK_SLOT

	CMP (0,X)		; 6
	PHA
	PLA			; 7
	ldy #sector_epilogue_len ; 2

WTRK10	lda sector_epilogue-1,Y	; 4
	ldx DISK_SLOT		; 4
	sta DISK_LOAD,X		; 5
	ora DISK_SHIFT,X	; 4
	PHA
	PLA
	CMP 0			; 10
	dey			; 2
	BNE WTRK10		; 3 if taken, 2 if not

        ; Finished with the timing-critical stuff. Write mode off
        ; X is still DISK_SLOT

        lda DISK_READ,X
        lda DISK_SHIFT,X
	CLI
	clc
	rts

MEM1
	DS MEM1/256+1*256-MEM1,$FF	;page alignment

disk_twos_buffer	DS 86,$55 ; must be aligned
encode_tab		DS 64,$AA ; must be within one page
decode_tab		DS $100-DECODE_TABLE_START,$FF

	END

