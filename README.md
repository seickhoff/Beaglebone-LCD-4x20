## Beaglebone - Controlling a 4x20 LCD (HD44780) using Perl

### 1 - LCD.pm & example.pl

This is the Perl LCD package and example usage.  For wiring, review the constructor in LCD.pm.


2 - lcd_hd44780.pl
-------------
This was the original proof of concept in a single file.  Review the %PINS hash for the LCD to 
Beaglebone wiring or see below. 

#### LCD Signal, Connection

* VSS, Ground
* VDD, +5V
* VO, Attach to potentiometer wiper to adjust contrast
* RS, Beaglebone pin P8_4
* R/W, Ground
* E, BeagleBone pin P8_3
* Data4, Beaglebone pin P8_5
* Data5, Beaglebone pin P8_11
* Data6, Beaglebone pin P8_12
* Data7, Beaglebone pin P8_14

