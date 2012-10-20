Beaglebone - Controlling a 4x20 LCD (HD44780) using Perl
==========

1 - LCD.pm & example.pl
-------------
This is the Perl LCD package and example usage.  For wiring, review the constructor in LCD.pm.


2 - lcd_hd44780.pl
-------------
This was the original proof of concept in a single file.  Review the %PINS hash for the LCD to 
Beaglebone wiring or see below. 


  LCD Signal, Connection

  1. VSS, Ground
  2. VDD, +5V
  3. VO, Attach to potentiometer wiper to adjust contrast
  4. RS, Beaglebone pin P8_4
  5. R/W, Ground
  6. E, BeagleBone pin P8_3
  11. Data4, Beaglebone pin P8_5
  12. Data5, Beaglebone pin P8_11
  13. Data6, Beaglebone pin P8_12
  14. Data7, Beaglebone pin P8_14

