�� � ���� u
� ���� � 8i@�� �
 �
� � � �
�Ȱ)�  @	�� ��� ��  c	���� � ����� �
��t� ` u
��
��� Lc � u
��  W	 	L� j	��	 j	���� �	�V� �� 1
�p� Lc �� ���ȱ� ��� ��	ȱ�
 	L�$0�`���
��i ��i˅��`8������������`� ȱ�	�0�	��
�`�0�`�� ������`�� �ȥ��e���`� ��ȱ�`���` K	 W	���L�	 �	L	� � h
 h
 h
 h
   c	� �	�. "� �	 ��� ���JJJH�)�8hi e���`��He���hL�	�� � " c	���`� �� H�� H�)HFfFfFfh������ 1
��	�  `� `���� �����&�e��e��e����ؠ�  H��`
H�0��1 "h`�˅���˅��`���E���� � �  `���� �	�?������`� ���ީ�ߠ ���)�� '�� 'L�
 'H �
 '�ޤ� h	 0�` 8`� J����������� "����i� � H����	L�   � �L� ����߱�`�r� � � �y��Y�8``HJJJJ Sh)$0� ����
�ii0 "` Error $ 
Retry  (Y/N) ?  BIOS BDOS CCP  RSX  USER ��Drive not ready �Invalid Drive ݂File not found �File exists �Invalid FCB  
 
D.COM V2.0      (c) D.Lausberg
 
Attr filename.ext   rec    kB    Attr filename.ext   rec    kB
 

total diskspace used   kB 

Directory finished

 
no file
 
Insert disc to drive B:
and press any key 
 FPNT),Y
	JSR PRT_BIT		;FLAG BITS
	JSR PRT_BIT
	JSR B:
and press any key 
 C	LDY #FCB_REC
	LDA (BUFPNT),Y
	PHA
	CLC
	ADC RECBUF
	STA RECBUF
	BCC ADDREC1
	INC RECBUF+1
ADDREC1	PLA
	JSR ADD_SF
	RTS


PRT	STA CNT
PRT1	LDY #0
	LDA (BUFPNT),Y
	JSR PRTCHR
	JSR INC_BUFPNT
	DEC CNT
	BNE PRT1
