CPM-65 APPLE II Port
===========
Dietrich Lausberg <lausbergd@gmail.com>
https://github.com/dietrich-l

This repository contains the Apple II Port of CPM-65, a CP/M-80 analogue operating system for 6502 based microcomputers

System Requirements
--------------------------
Apple II
80 Column card in Slot 3
min 1 Floppy drive

My system is a vanilla Apple II clone

System Structure
--------------------
CPM-65 consists of 3 layers:
- BIOS Basic I/O system - Drives can be A-H non consecutive. 
- BDOS Basic disc operating system - this is the CPM-65 kernal. Size 2 kB
- CCP Console command program - a simple console which only allows to invoke CPM-65 programs. No resident commands. Size 1 kB

File & Disc Format
----------------------
Filenames are CP/M-style d:filename.ext with d <Drive A-H>
Programs must have .COM as extension and are loaded to $0800 and started there.

The directory structure is CP/M-compatible. Disk images can be read with appropriate  tools like CPMTOOLS

The Disc format is 35 tracks/ 16 sectors/ 256 byte/sector. It is defined in the BIOS. The BDOS operates on sector numbers. 

Software List
---------------------
Name		Version
ALLOC		2.9
ASM		2.6
BDOS		2.3*
BIOS		0.1*
BOOT		0.1*
BROWSE		1.0
CCP		1.5*
COPY		1.4
D		2.0
DEBUG		1.7
DUTIL		1.5
EDIT		1.0
ERASE		1.5
FORMAT		2.4
FORTH		1.6a
RENAME		1.1
SYS 		1.5
SYSGEN		1.0
TYPE		1.6
XMODEM		2.2

*available

All software is supplied as assembler files to be assembled with the CPM-65 assembler. In case you wish to use a different assembler, the syntax has to be adapted accordingly.

Documentation
--------------------
Currently the documentation of CPM-65 is sparse and only for my personal needs. I plan to write appropriate docs over time. If there are any whishes, please open a DISCUSSION

Errors
--------------------
The Apple port of CPM-65 is currently work in progress. Expect errors and crashes.

The CPM-65 system itself has now seen more than 30 years of service. Currently there are no known errors. 

However, since an error free software does not exist, please report any errors in the ISSUE section

Other related systems
---------------------
When I started the development of cpm-65, I was blissfully unaware of any other aproaches. However there are some, most notably:
- DOS/65 by Richard Leary. There is a limited compatibility
- OUP/M  by Jiang - Xiong Shao. Published 1983, no further development
- CPM65 by David Given, published 2022


Redistribution
--------------
Source code, and all documents, are freely redistributable in
any form. Please see the the COPYRIGHT file included in this
Repository.