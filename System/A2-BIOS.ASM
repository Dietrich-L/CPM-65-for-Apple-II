; CP/M-65 Copyright © 2023 David Given
; This file is licensed under the terms of the 2-clause
; BSD license. Please see the COPYING file in the root 
; project directoryfor the full text

;CPM-65 version adapted 2023 by Dietrich Lausberg
;CPM-65 BIOS for Apple II

;D. LAUSBERG	(C) 2023
;V0.1	06.04.23	initial version

VERSION	= $01		;VERSION NUMBER

;PAGE 00 CELLS

PREG	= $48		;Monitor status reg

DMAV	= $FE		;DMA-VECTOR
DIRBFV	= $FC		;DIRBF-VECTOR
PTR	= $FA		;BIOS Pointer
DPHV	= $F8		;DPH-VECTOR
PTR1	= $E2		;temporary BIOS pointer
JPBDOS	= $F0


;SYSTEM CONSTANTS

CCP	= $9800
BEGIN	= $A700		;BIOS cold start
DMABF	= BEGIN-256	;default DMA buffer at $B500
DIRBF	= DMABF-256	;dir sector buffer at $B400

;APPLE I/O adresses

KBD_READ	= $C000		;Keyboard key, bit 7 =1
KBD_STROBERESET	= $C010		;Keyboard strobe

;Apple ROM adresses

RDKEY	= $FD0C
COUT	= $FDED

;CONTROL CODES

BREAKC	= $03		;BREAK CODE
CLS	= $0C		;CLEAR SCREEN
ESC	= $1B		;ESC

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
	DS BATSIZ+1	;17 Bytes

;--- SLOT TABLE Floppy Drives ---

SLOTTAB	DB 6*16, 5*16
SECS	DS 3, $00
DRIVE	DB 0
DISK_SLOT DB 0
DRIVENR DB 0
motor_countdown DB 0
current_phase	DB 0

wanted_track	DB 1
wanted_trackoffset DS 2
buffered_track	DB 1
buffer_dirty	DB 1
track_flags	DS 16

sector_prologue		DB $ad, $aa, $d5 ; REVERSED
sector_prologue_len = 2
sector_epilogue		DB $ff, $eb, $aa, $de ; REVERSED
sector_epilogue_len = 3

reverse_sector_map	DB $00,$07,$0E,$06,$0D,$05,$0C,$04
			DB $0B,$03,$0A,$02,$09,$01,$08,$0F

;--- BIOS data area ---

YBUF	DB 0	;Y buffer for CHRIN & CHROUT
CHARBUF	DB 0
CHR	DB 0

;==================================

BOOT	JSR DISK_INIT
	LDA #$4C		;SET JMP BDOS
	STA JPBDOS
	LDA #CCP
	STA JPBDOS+1
	LDA #CCP/256
	STA JPBDOS+2
	JSR HOME		;HOME BOOT DISK, initialize disk driver
	LDA #0
	STA DRIVE		;always A:
	LDX #$0E		;VIA BDOS
	JSR JPBDOS
	LDX #0 			;WARM BOOT
	JMP JPBDOS


WBOOT	LDA DRIVE		;SELECT DEFAULT DRIVE
	JMP SELDSK


CONST	STY YBUF
	ldx motor_countdown	
	BEQ CONST3
CONST1	dec motor_countdown
	BNE CONST3
CONST2	ldx DISK_SLOT
	lda DISK_MOTOROFF,X
CONST3	ldy #0
	ldx KBD_READ
	BPL CONST4
        dey
CONST4	tya
	STA CHARBUF
	LDY YBUF
	clc
	rts
	

CONIN	STY YBUF	;CHR input; CHR in A, 8 bit transparent
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
	LDY YBUF
	RTS


CONOUT	STY YBUF	;PRINTS CHR in A TO CON
	CMP #$60	;lower case to upper case
	BCC CONOU2
	AND #%01011111
CONOU2	ORA #$80	;set bit 7
	JSR COUT
	BIT KBD_READ    ;Check Keyboard Input Reg for a Key Press
	BPL CHROU1      ;Branch if No Key has been Pressed
        LDA KBD_READ    ;Read Keyboard Input Reg; Get Key Pressed
	BIT KBD_STROBERESET	;Clear KBD Strobe (KBD<128) for Next Key
	CMP #ESC+$80	;CHECK FOR ESC KEY
	BNE CHROU1
	LDA #BREAKC	;^C TO CHARACTER BUFFER
	STA CHARBUF
CHROU1	LDY YBUF
	RTS


HOME	lda #0		;move to track 0
	jsr seek_to_track
	CLC			;always ok
HOMEX	RTS


SELDSK	CMP #4			;TEST FOR DRIVE A to D
	BCS SELDS3
	STA DRIVE
	LSR A
	TAY
	LDA SLOTTAB,Y		;set SLOT
	STA DISK_SLOT
	LDA DRIVE
	AND #$01
	STA DRIVENR		;SELECT DISK LOGICAL
	LDA #DPHA		;SET DPHVEC
	STA DPHV
	LDA #DPHA/256
	STA DPHV+1
	CLC
	RTS

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
	JSR EREAD
READX	RTS


WRITE	JSR FD_ST		;convert sec nr to sector/track
	BCS WRITEX
	JSR EWRITE
WRITEX	RTS


GET_VERSION			;GET VERSION NUMBER

	LDA #VERSION
	RTS


NOFUNC	LDA #ILLFUNC
	SEC
	RTS


;====== SUBROUTINES =======

DISK_INIT		;init disk driver
	ldx #$03	; Build the GCR tables.
	ldy #0
BGCR2	stx PTR
        txa
        asl a               ; check for double ones
        bit PTR
        beq reject
        ora PTR           ; check for double zeros
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

    ; Initialise the disk.

	ldx #0
	stx current_phase
	stx buffer_dirty
	dex
	stx buffered_track

    ; set Boot disk


DSKIN1	LDA #0		;Slot#6, D0 is boot drive
	JSR SELDSK 	;set Disk to current drive

    ; Read the BDOS & CCP from track 1 into the track buffer..

RELOAD	lda #1
	jsr seek_to_track
	jsr read_track
    
    ; Copy it to the beginning of CCP

	lda #0
	sta PTR
	sta PTR1
	lda #track_buffer/256
	sta ptr1+1
	lda #CCP/256
	sta ptr+1

MOVE1	ldy #0
MOVE2	lda (ptr1),Y
	sta (ptr),Y
	dey
	BNE MOVE2
        inc ptr+1
        inc ptr1+1
        lda ptr+1
        CMP #BEGIN/256	;BIOS reached?
	BNE MOVE1
	RTS


; --- Disk handling --------------------------------------


FD_ST	LDA SECS	;calculate SECS _> Track & Sector
	AND #SPT-1	;sector offset
	ORA #track_buffer/256
	sta wanted_trackoffset+1
	lda #0
	sta wanted_trackoffset+0 ;always full pages
	LDX #SPTDIV
	LDA SECS+1
FD_ST2	LSR A			;TRACK = SECS/16
	ROR SECS
	DEX
	BNE FD_ST2
	CMP #MAXTRK
	BCS FD_ST1
	sta wanted_track
	rts

FD_ST1	LDA #$FB		;sector not found error
	RTS


; Reads the current sector to the DMA address

EREAD
	jsr change_tracks
	BCS EREADX
        lda wanted_trackoffset+0
        sta PTR
        lda wanted_trackoffset+1
        sta ptr+1
        ldy #255	;write 1 page
READ1	lda (ptr),Y
	sta (DMAV),Y
	dey
	BPL READ1
        clc
EREADX	rts


; A=0 for a normal write; A=1 to always flush to disk

EWRITE
	pha
	jsr change_tracks
	pla
	BCS EWRITX
        pha

	lda wanted_trackoffset+0
        sta PTR
        lda wanted_trackoffset+1
        sta ptr+1
        ldy #255	;write 1 page
WRIT1	lda (DMAV),Y
	sta (ptr),Y
	dey
	BPL WRIT1
        pla
	BEQ WRIT2
	jmp write_track
WRIT2	lda #1
        sta buffer_dirty
        clc
EWRITX	rts


; Changes the track in the buffer.

change_tracks
	lda wanted_track
	cmp buffered_track
	BNE CTRK1
        ; If we're changing to the same track, do nothing
        clc
        rts

CTRK1	lda buffer_dirty
	BEQ CTRK2
        jsr write_track
CTRK2	lda wanted_track
	sta buffered_track
	jsr seek_to_track

	; fall through

; Read the current track into the track buffer.

read_track
	jsr motor_on

    ; No sectors have been read.

	ldx #15
	lda #1
RTR1	sta track_flags,X
        dex
	BPL RTR1

    ; Low byte of ptr1 remains 0 throughout.

	lda #0
	sta PTR1

    ; Start reading sectors

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
	tax
	ldy track_flags,X
	BEQ RTR2

	; Set up ptr1 to point to this sector's buffer.

	and #$0f
	ora #track_buffer/256
	sta ptr1+1

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
	sta (ptr1),Y
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
RTR9	lda (ptr1),Y
	lsr disk_twos_buffer,X
	rol a
	lsr disk_twos_buffer,X
	rol a
	sta (ptr1),Y
	iny
	BNE RTR8

        ; Mark this sector as having been successfully read

        lda ptr1+1
        and #$0f           ; recover the sector number
        tax
        lda #0
        sta track_flags,X  ; clear sector marker

        ; Find out if we've read all the sectors yet.

        ldx #15
        lda #0
        clc
RTR10	adc track_flags,X
	dex
	BPL RTR10
        tax
	BNE RTR11
	clc
	rts

RTR11	JMP RTR2


; Seek to the track number in A.

seek_to_track
	jsr motor_on
	asl a		; convert to phase number
STT1	cmp current_phase
	BNE STT2
	rts		;ready

STT2	ldy #$ff	; default to counting down
	BCC STT3
	ldy #1		; A > track, count up
STT3	pha
        jsr change_phase
        jsr change_phase
        pla
	JMP STT1

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

	lda #86
	sec
STT4	pha
STT5	sbc #1
	BNE STT5
        pla
        sbc #1
	BNE STT4
	rts

; Waits for a sector header. Returns the unencoded ID byte
; immediately following in Y. Preserves A

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
	BPL RGCR1
	and PTR
	rts



motor_on			; Corrupts X
	ldx #$ff
	stx motor_countdown
	ldx DISK_SLOT
	sta DISK_MOTORON,X
	rts


; Write the track buffer to disk.
; The timing in this routine is critical, so it's important 
; that it doesn't cross page boundary. Therefore this must 
; be the last routine in the BIOS so all the
; timing-critical bits are in the last page.

MEM
	DS MEM/256+1*256-MEM,$FF		;page alignment

write_track
    jsr motor_on
    clc

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

    lda #track_buffer/256  ; low nibble is DOS sector number
    sta ptr1+1
    lda #0
    sta PTR1          ; remains zero for the duration

write_track1
        lda ptr1+1
        and #$0f
        tax		;X is sector#

        ; Precompute the 2s and I/O buffer.

        ldx #0
        ldy #2

WTRK1	dey
	lda (ptr1),Y
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
	lda ptr1+1
	and #$0f
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
	NOP			; 3
	sta DISK_LOAD,X	; 5
	cmp DISK_SHIFT,X	; 4
	dey			; 2
	BNE WTRK6		; 3 if taken, 2 if not

	PHA		; waste four cycles for the last 40-cycle sync byte
	PLA		; plus five to sync up with the loop below
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
	ldx DISK_SLOT		; 2
	sta DISK_LOAD,X		; 5
	cmp DISK_SHIFT,X	; 4
	lda disk_twos_buffer-1,Y ; 5 (always crosses page boundary)
	dey			; 2
	BNE WTRK8		; 3 if taken, 2 is not

            ; Write out the 6s buffer
            ; (y is zero)

WTRK9	NOP                     ; 2
	eor disk_sixes_buffer,Y	; 4
	tax			; 2
	lda encode_tab,X	; 4
	ldx DISK_SLOT		; 2
	sta DISK_LOAD,X		; 5
	ora DISK_SHIFT,X	; 4
	lda disk_sixes_buffer,Y	; 4
	iny			; 2
	BNE WTRK9		; 3 if taken, 2 if not

            ; Write checksum byte

	tax			; 2
	lda encode_tab,X	; 4
	PHA
	PLA 			; 7
	ldx DISK_SLOT		; 2
	sta DISK_LOAD,X		; 5
	ora DISK_SHIFT,X 	; 4

            ; Write epilogue.
            ; X is still DISK_SLOT

	CMP (0,X)		; 6
	PHA
	PLA			; 7
	ldy #sector_epilogue_len ; 2

WTRK10	lda sector_epilogue-1,Y	; 4
	NOP			; 2
	ldx DISK_SLOT		; 2
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

        ; Advance to the next sector and go again

        inc ptr1+1
        lda ptr1+1
        and #$0f
        BNE WTRK_L
	lda #0
	sta buffer_dirty
	clc
	rts

WTRK_L	JMP write_track1



; DPH for drive 0 (our only drive)

disk_twos_buffer	DS 86,$55 ; must be aligned
encode_tab		DS 64,$AA ; must be within one page

directory_buffer	DS 256,$00
decode_tab		DS $100-DECODE_TABLE_START,$FF


	END

