���
 z	� ��'���� ���� � 8i@� ����� �� � � 	��`�ՠ
 z	L�� �i����Y� ��Ȅ)@��*Ld�  �	� ��. �	� ��  �	�s�
 z	� � )_�E�,�Y������ ��������� v	� � �����L	�0%�� � ������ ��� �� � �� 	��`� 
 z	`�� � �� �	���`��E����
 z	� �  v	`� v	���ީ	�ߠ ���)�� �	�� �	L#	 �	H S	 �	�ޤ� z	h	 �	�` j	8`� J����������	� �	������	 z	� �	�p�
�	L�  �	� �L� ����߱�`�ʠ	 z	� � �y��Y�8``HJJJJ �	h)�
�ii0 �	` Error $ 
Retry  (Y/N) ?  BIOS BDOS CCP  RSX  USER ��Drive not ready �Invalid Drive �Directory full ݂File not found �File exists �Invalid FCB �Disk full �File is R/O  
   ^C=abort (nothing deleted), E=Exit, Y/N   
ERASE V1.5      (c) D.Lausberg
 
ERASE finished
 
 usage d:ERASE d:filename.ext
 
Insert disc to drive B:
and press any key 
 

ERRTAB  DB $FD,$81,'Drive not ready',EOT
	DB $F9,$01,'Invalid Drive',EOT
	DB $DE,$02,'Directory full',EOT
	DB $DD,$82,'File not found',EOT
	DB $DC,$02,'File exists',EOT
	DB $D9,$02,'Invalid FCB',EOT
	DB $D8,