�N�  	�$ �	��Ȅ��	8�� �	 F�	 ���ɞ� ��� �� � � L�  	 �	�c��  �
 �
� � �J� ������ � �������	����1`��� ��`����
�
���e�� e�LU ��``��` �	�M���  �
 �
 �
�<�������� � �3����� � ��e�� e����
������`ɟ�� ��` ��`� ��  �� �	� ���� � �芅�	@�� �����芅�	@����	��� ���������/�������� �2������� �`��8`�2�`����E�$��� �	�� � � ��`����E�$��� �	�� � � ��`�)�����` �Ġ �  {` �
� � � ��`� ��i����Q$/�  �� 
�. �� 
�  ��4� � � )_�E�/�Y������ ���������$ {� � �����8`����8``�� � �� ����`���� �	�?������`� ���ȱ�����`� ���ȱ�����` {��� ���	���. ��� �����`� � ����8`�� � � �y��Y���8`� � `� �����`�L� � {���ީ�ߠ ���)�� ��� �L( �H X ��ޤ� h	 ��` o8`� J����������� �����Ơ � ��&��	L�  �� �L� ����߱�`�Ϡ � � �y��Y�8``HJJJJ �h)�
�ii0 �` Error $ 
Retry  (Y/N) ?  BIOS BDOS CCP  RSX  USER ��Drive not ready �Invalid Drive �Directory full ݂File not found �File exists �Invalid FCB �Disk full �File is R/O �*** COPY aborted *** �Switch missing �Argument missing
Usage:   COPY d:filename.ext d: /switch
Switch     Y   Y/N request for every filename
 �no file found �file too long to copy  Y�  ^C=abort, E=Exit, Y/N   

COPY V1.4                  (c) D.Lausberg   1995

 

COPY finished
 

Insert source 

Insert destination  disc to drive A: and press any key  
reading ... 
writing ...   File exists, overwrite? (Y/N)  
  PRTSTR
	LDY #_CHRIN		;WAIT FOR KEY
	JSR BIOS
	JSR CRLF
	CLC
	RTS


GETFIL	JSR FCB_CHECK		;GET FILE LIST TO COPY
	LDX #FIRST
	JSR BDOS		;CHECK FOR FILE
	BCC GETFIL1
	JSR ERROR
	BCC GETFIL
	RTS

GETFI