<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=windows-1252">
    <link rel="alternate stylesheet" type="text/css" href="resource://gre-resources/plaintext.css">
  </head>
  <body>
    <pre>CPM-65 APPLE II Port
===========
Dietrich Lausberg &lt;lausbergd@gmail.com&gt;
https://github.com/dietrich-l

This repository contains the Apple II Port of CPM-65, <br>a CP/M-80 analogue operating system for 6502 based microcomputers

<br>![Apple II-1](https://github.com/Dietrich-L/CPM-65/assets/83355183/6d946487-f3c6-4fc6-a930-0c7e1b2a7a81)


System Requirements
--------------------------
Apple II
80 Column card in Slot 3
min 1 Floppy drive

My system is a vanilla Apple II clone

Emulation
--------------------
AppleWin emulator, APPLE IIe emulation due to the 80 col card

![CPM-65 Apple II Version](https://github.com/Dietrich-L/CPM-65/assets/83355183/dfc8af17-442d-441a-96ec-6f0cbbf5ddcf)<br><br>&nbsp; System Structure
--------------------
CPM-65 consists of 3 layers:
- BIOS Basic I/O system - Drives can be A-D non consecutive. 
- BDOS Basic disc operating system - this is the CPM-65 kernel. Size 2 kB
- CCP Console command program - a simple console which only allows to invoke CPM-65 programs. <br>    No resident commands. Size 1 kB<br><br>In track 0, sector 0 resides a 256 bytes BOOT program, which loads CPM-65 to memory <br>and starts the CCP. <br><br>The system can boot from Slot# 6 or 5 (Drives A: or C:)<br><br><br>&nbsp; File &amp; Disc Format
----------------------
Filenames are CP/M-style d:filename.ext with d &lt;Drive A-H&gt;
Programs must have .COM as extension and are loaded to $0800 and started there.

The directory structure is nearly CP/M-compatible. <br>Disk images can be read with appropriate tools <br>like CPMTOOLS, <a href="https://github.com/ProgrammingHobby/CPM_Image-File_Explorer">CIFE (CPM Image File Explorer)</a> or CpmtoolsGUI. 
A disdefs file is in the IMAGES section. <br>Please use an actual version as parameter 'extentsize 4096' is needed.<br>For the transfer of larger files, see separate documentation.

The Disc format is 35 tracks/ 16 sectors/ 256 byte/sector. <br>It is defined in the BIOS. The BDOS operates on sector numbers. 

<br>Software List
</pre>
    <table style="width: 809px;" border="1">
      <tbody>
        <tr>
          <td style="width: 140.383px;"><span style="font-family: Courier New,Courier,monospace;">Program<br>
            </span></td>
          <td style="margin-left: 90px; width: 83.65px;"><span style="font-family: Courier New,Courier,monospace;">Version<br>
            </span></td>
          <td style="width: 575px; margin-left: -100px;"><span style="font-family: Courier New,Courier,monospace;">Description<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">ALLOC<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">2.9<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">shows
              disc allocation map<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">ASM<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">2.8<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">native
              6502 Assembler<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">BASIC<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.5<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">Microsoft
              Basic interpreter<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">BDOS<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">2.4<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">CPM-65
              BDOS<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">BIOS<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">0.7<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">APPLE II
              CPM-65 BIOS</span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">BOOT<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">0.4<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">APPLE II
              CPM-65 BOOT program in track 0, sector 0<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">BROWSE<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.2<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">text
              file browser<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">CCP<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.5<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">CPM-65
              CCP<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">COPY<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.4<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">multi
              file copy utility<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">D<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">2.3<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">show
              directory alphabetically sorted<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">DEBUG<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.8<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">Debugger,
              8 breakpoints, stepping, disassembler,...<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">DUTIL<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.5<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">disc
              sector editor<br>
            </span></td>
        </tr>
        <tr>
          <td style="height: 28.8167px;"><span style="font-family: Courier New,Courier,monospace;">EDIT<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.1<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">Simple
              editor for text files &amp; FORTH screens<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">ERASE<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.5<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">erase
              files<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">FDISK<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.0<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">Converts
              a DOS 3.3 disc to a bootable CPM-65 disc<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">FORTH<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.6<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">FIG
              FORTH including module for standalone applications<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">RENAME<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.1<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">rename
              files<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">SYS<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.6<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">puts
              code for BOOT, BIOS, BDOS, CCP into the system tracks<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">SYSGEN<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.0<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">copy
              operating system to another disc<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;">TYPE<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">1.6<br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;">prints
              text file to screen<br>
            </span></td>
        </tr>
        <tr>
          <td><span style="font-family: Courier New,Courier,monospace;"><br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;"><br>
            </span></td>
          <td><span style="font-family: Courier New,Courier,monospace;"><br>
            </span></td>
        </tr>
      </tbody>
    </table>
    <pre>
All software is supplied as assembler files to be assembled with the CPM-65 assembler. <br>In case you wish to use a different assembler, the syntax has to be adapted accordingly.

Documentation
--------------------
Currently the documentation of CPM-65 is sparse and only for my personal needs. <br>I plan to write appropriate docs over time. If there are any whishes, please open a DISCUSSION

Errors
--------------------
The Apple port of CPM-65 is currently work in progress. Expect errors and crashes.

The CPM-65 system itself has now seen more than 30 years of service. <br>Currently there are no known errors. 
However, since an error free software does not exist, <br>please report any errors in the ISSUE section

Other related systems
---------------------
When I started the development of cpm-65, I was blissfully unaware of any other aproaches. <br>However there are some, most notably:
- DOS/65 by Richard Leary. There is a limited compatibility
- OUP/M  by Jiang - Xiong Shao. Published 1983, no further development
- CPM65 by David Given, published 2022


Redistribution
--------------
Source code, and all documents, are freely redistributable in
any form. Please see the the COPYRIGHT file included in this
Repository.</pre>
  </body>
</html>
