;======	MESSAGES ======

ERR1M	DB CR,LF,'Line ',EOT
ERR2M	DB '	Pos $',EOT
ERRM1	DB ' Error $',EOT
RTYMES	DB CR,LF,'Retry	(Y/N) ? ',EOT

ETYPTB	DB 'BIOS',$00,'BDOS',$00,'CCP',$00,$00
	DB 'RSX',$00,$00,'ASM',$00,$00

ERRTAB	DB $F9,$01,'Invalid drive',EOT
	DB $DE,$82,'Directory full',EOT
	DB $DD,$82,'File not found',EOT
	DB $DC,$02,'File exists',EOT
	DB $D9,$02,'Invalid FCB',EOT
	DB $D8,$82,'Disk full',EOT
	DB $D6,$82,'File is R/O',EOT
	DB $B6,$10,'Illegal filename',EOT
	DB $B5,$10,'Out of memory',EOT
	DB $B4,$10,'Line counter overflow',EOT
	DB $B3,$10,'Line too long',EOT
	DB $B2,$10,'Too many errors',EOT
	DB $B1,$10,'Extension must be omitted',EOT
	DB $87,$10,'WARNING: Zero page adressing conflict',EOT
	DB $88,$10,'Branch out of range',EOT
	DB $89,$10,'Label missing',EOT
	DB $8A,$10,'Word missing',EOT
	DB $8B,$10,'Argument missing',EOT
	DB $8C,$10,'Numerical overflow',EOT
	DB $8D,$10,'Illegal opcode',EOT
	DB $8E,$10,'Syntax error',EOT
	DB $8F,$10,'Illegal adressing mode',EOT
	DB $90,$10,'No value assigned to label',EOT
	DB $91,$10,'JMP (ind) WARNING',EOT
	DB $92,$10,'Word too long',EOT
	DB $93,$10,'Illegal decimal',EOT
	DB $94,$10,'Duplicate label',EOT
	DB $95,$10,'Label previsiously assigned',EOT
	DB $98,$10,'Division by 0',EOT
	DB $00

CRLFM	DB CR,LF,EOT
PASS1M	DB CR,LF,'ASM-65   
	DB ' V',VERSION/16+$30,'.',VERSION*$1000/$1000+$30
	DB '    (c) D. Lausberg'
	DB CR,LF,CR,LF,'... PASS 1 ...',CR,LF,EOT
PASS2M	DB CR,LF,CR,LF,'... PASS 2 ...',CR,LF,EOT
PRTAB	DB $1B,'!',4,$1B,$4E,$06,$1B,'l',10,CR,LF,'ASM-65   '
	DB ' V',VERSION/16+$30,'.',VERSION*$1000/$1000+$30
	DB '      (c) D. Lausberg  1991-2021',CR,LF,CR,LF,EOT
SCOMM	DB CR,LF,'*.COM-File saved',EOT
SLBLM	DB CR,LF,'*.LBL-File saved',EOT
PRST1M	DB CR,LF,CR,LF,'end of assembly'
	DB CR,LF,'bytes free $',EOT

FCBA			;FCB FOR APPEND
LBEG	= FCBA+32	;line Buffer
CODBEG	= LBEG+128	;code begins here

	END
