 @� 	`  � 	���� s	 ���` �� 	L� �	 	 y���� s	`�r� s	� 	��� � ���������� q`��8`��8`� � ����� �� �
�� ��	�
�
���`� 	` � �	�J��Y�8``��
 	$0
� 	���`� 	��`�0�����`� ���� � 8i@���F�)��� ��� s	� �  o	`��8`�L� � o	�%�ީ
�ߠ ���)�� �	�� �	L	 �	H L	 �	�ޤ� s	h	 �	�` c	8`� J���������
� }	�����	 s	� �	�-��	L�  {	� �L� ����߱�`�a���)_`���	 s	� �  �	�Y�`8` �	H� �	H� �	h �	h	0L}	� 8�
����i
`HJJJJ �	h)�
�ii0 }	`����@�� Error $ 
Retry (Y/N) ?  BIOS BDOS CCP  RSX  USER ��Seek Error, record not found ��CRC Error ��Drive not ready ��Disk write protected ��Sector not found ��Lost data on writing track �Invalid Drive ނDirectory full ݂File not found �File exists �Invalid FCB ؂Disk full ւFile is R/O �No System on this Drive �BIOS Version lower than 2.2 �Illegal Parameter �Missing Parameter  SYSGEN V1.0                    (c) D. Lausberg 2021

 
Diskette in Drive B: einlegen
und Taste druecken

Abbruch mit <CTRL-C>

 
System kopiert 
Eine weitere Diskette?  <Y/N>  
 C
	SBC #10
	BCC COMNU2
	INY
	BNE COMNU1

COMNU2	ADC #10
	RTS


PRTHEX	PHA		;PRINTS A HEX NUMBER
	LSR A
	LSR A
	LSR A
	LSR A
	JSR PRTNIB	;PRINT NIBBLE
	PLA
	AND #$0F

PRTNIB	CMP #$0A
	BCC P