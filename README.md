## Beaglebone - Controlling a 4x20 LCD (HD44780) in 4-bit mode using Perl

### LCD.pm

To use the LCD package, tell your script to require it.

```perl
require LCD;
```

Create an LCD object instance using the default parameters.  The default parameters are listed below.

* RS connected to Beaglebone pin P8_4
* E connected to Beaglebone pin P8_3
* Data 4 connected to Beaglebone pin P8_5
* Data 5 connected to Beaglebone pin P8_11
* Data 6 connected to Beaglebone pin P8_12
* Data 7 connected to Beaglebone pin P8_14

```perl
$lcd  = LCD->new();
```

To use a custom configuration, supply a hash to the constructor to override any of the defaults. Valid keys are RS, E, D4, D5, D6 and D7.  Here are the sub-keys:

* gpio - GPIO bank label (not actually used for anything)
* header - GPIO header label (not actually used for anything)
* pin - PIN number for exporting
* mode - Declare the mode number of the GPIO pin (typically 7)
* mode0 - Declare the mode 0 name of the GPIO pin

```perl
my %CONFIG = (
        "RS" => {
                "gpio" => "GPIO1_7",
                "header" => "P8_4",
                "pin" => 39,
                "mode" => 7,
                "mode0" => "gpmc_ad7"
        },
        "E" => {
                "gpio" => "GPIO1_6",
                "header" => "P8_3",
                "pin" => 38,
                "mode" => 7,
                "mode0" => "gpmc_ad6"
        }
);

$lcd  = LCD->new(%CONFIG);
```

To display the configuration, use the **configuration** method.

```perl
$lcd->configuration; 
```

Use the **set_position** method to move the character position to a specific row and column (_row, column_).

```perl
$lcd->set_position(0, 0); 
```

Use the **print** method to write a string to LCD display.
```perl
$lcd->print("Beaglebone"); 
```

Use the **close** method to release (unexport) the GPIO configuration.

```perl
$lcd->close; 
```