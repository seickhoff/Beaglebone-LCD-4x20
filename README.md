Beaglebone - Controlling a 4x20 LCD (HD44780) using Perl
==========
Enclosed is a working demo in a single file.  Review the %PINS hash for the LCD to Beaglebone wiring or see below. 

<LCD pin, Description, Connection>

1, VSS, Ground

2, VDD, +5V

3, VO, Attach to potentiometer wiper to adjust contrast

4, RS, BeagleBone pin P8_4

5, R/W, Ground

6, E, BeagleBone pin P8_3

7, Data0, Unconnected

8, Data1, Unconnected

9, Data2, Unconnected

10, Data3, Unconnected

11, Data4, BeagleBone pin P8_5

12, Data5, BeagleBone pin P8_11

13, Data6, BeagleBone pin P8_12

14, Data7, BeagleBone pin P8_14



Next on the agenda is to separate the LCD functions into its own module.