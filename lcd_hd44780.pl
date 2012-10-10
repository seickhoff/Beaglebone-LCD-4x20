use Time::HiRes qw( usleep sleep );
use IO::File;

my %PINS = (
        "RS" => {
                "gpio" => "GPIO1_7",
                "header" => "P8_4",
                "pin" => 39,
                "dir" => "out",
                "mode" => 7,
                "mode0" => "gpmc_ad7",
                "fh" => undef
        },
        "E" => {
                "gpio" => "GPIO1_6",
                "header" => "P8_3",
                "pin" => 38,
                "dir" => "out",
                "mode" => 7,
                "mode0" => "gpmc_ad6",
                "fh" => undef
        },
        "D4" => {
                "gpio" => "GPIO1_2",
                "header" => "P8_5",
                "pin" => 34,
                "dir" => "out",
                "mode" => 7,
                "mode0" => "gpmc_ad2",
                "fh" => undef
        },
        "D5" => {
                "gpio" => "GPIO1_13",
                "header" => "P8_11",
                "pin" => 45,
                "dir" => "out",
                "mode" => 7,
                "mode0" => "gpmc_ad13",
                "fh" => undef
        },
        "D6" => {
                "gpio" => "GPIO1_12",
                "header" => "P8_12",
                "pin" => 44,
                "dir" => "out",
                "mode" => 7,
                "mode0" => "gpmc_ad12",
                "fh" => undef
        },
        "D7" => {
                "gpio" => "GPIO0_26",
                "header" => "P8_14",
                "pin" => 26,
                "dir" => "out",
                "mode" => 7,
                "mode0" => "gpmc_ad10",
                "fh" => undef
        }

);

%h2b = ('0' => "0000",
        '1' => "0001", '2' => "0010", '3' => "0011",
        '4' => "0100", '5' => "0101", '6' => "0110",
        '7' => "0111", '8' => "1000", '9' => "1001",
        'a' => "1010", 'b' => "1011", 'c' => "1100",
        'd' => "1101", 'e' => "1110", 'f' => "1111");



gpio_export();
gpio_open();


lcd_initialize();

# line 1
lcd_goto_line(0, 4);
gpio_value_data("Beaglebone");

# line 2
lcd_goto_line(1, 0);
gpio_value_data('1234567890');

# line 3
lcd_goto_line(2, 10);
gpio_value_data('ABCDEFGHIJ');

lcd_cursor("off");


# line 4
for ($x = 0; $x < 60; $x++) {
        lcd_goto_line(3, 0);
        $date = substr(qx(date), 0, 20); # system call
        gpio_value_data($date);

        sleep(1);
}


gpio_close();
gpio_unexport();

#foreach $pin ( keys %PINS ) {
#       for $field (keys %{ $PINS{$pin} } ) {
#               $value = $PINS{$pin}{$field};
#               print "$pin -> $field -> $value\n";
#       }
#}

exit;

sub lcd_cursor {
        if ($_[0] eq "on") {
                gpio_value("cmd", 0, 0, 0, 0);
                gpio_value("cmd", 1, 1, 1, 1);
        }
        elsif ($_[0] eq "off") {
                gpio_value("cmd", 0, 0, 0, 0);
                gpio_value("cmd", 1, 1, 0, 0);
        }
}

sub lcd_initialize {
        # initialization (8-bit mode x 3, 4-bit mode x1)
        gpio_value("cmd", 0, 0, 1, 1);
        gpio_value("cmd", 0, 0, 1, 1);
        gpio_value("cmd", 0, 0, 1, 1);
        gpio_value("cmd", 0, 0, 1, 0);

        # function set (4-bit mode, 2-line)
        gpio_value("cmd", 0, 0, 1, 0);
        gpio_value("cmd", 1, 0, 0, 0);

        # clear display
        gpio_value("cmd", 0, 0, 0, 0);
        gpio_value("cmd", 0, 0, 0, 1);

        # display on/of (display on, cursor on, blink on)
        gpio_value("cmd", 0, 0, 0, 0);
        gpio_value("cmd", 1, 1, 1, 1);

        gpio_value("cmd", 0, 0, 0, 0);
        gpio_value("cmd", 0, 1, 1, 0);
}

sub lcd_goto_line {
        # line 1
        if ($_[0] == 0) {
                $address = sprintf("%x", (128 + $_[1])); # hex 80
        }
        # line 2
        elsif ($_[0] == 1) {
                $address = sprintf("%x", (192 + $_[1])); # hex C0
        }
        # line 3
        elsif ($_[0] == 2) {
                $address = sprintf("%x", (148 + $_[1])); # hex 94
        }
        # line 4
        elsif ($_[0] == 3) {
                $address = sprintf("%x", (212 + $_[1])); # hex D4
        }

        @chars = split(//, $address);
        foreach $char (@chars) {
                $binary = $h2b{$char};
                @bits = split(//, $binary);
                gpio_value("cmd", $bits[0], $bits[1], $bits[2], $bits[3]);
        }
}

sub gpio_unexport {
        foreach $pin ( keys %PINS ) {
                open (FH, '>>/sys/class/gpio/unexport');
                print FH $PINS{$pin}{"pin"};
                close(FH);
        }
}

sub gpio_export {
        foreach $pin ( keys %PINS ) {
                # set mode i.e. 7
                open (FH, '>>/sys/kernel/debug/omap_mux/' . $PINS{$pin}{"mode0"});
                print FH $PINS{$pin}{"mode"};
                close(FH);

                # export
                open (FH, '>>/sys/class/gpio/export');
                print FH $PINS{$pin}{"pin"};
                close(FH);

                # set direction
                my $dir = '/sys/class/gpio/gpio' . $PINS{$pin}{"pin"} . '/direction';
                open (FH, ">$dir");
                print FH $PINS{$pin}{"dir"};
                close(FH);
        }
}

sub gpio_open {
        foreach $pin ( keys %PINS ) {
                $val = '/sys/class/gpio/gpio' . $PINS{$pin}{"pin"} . '/value';
                $PINS{$pin}{"fh"} = IO::File->new("> $val");
                open ($PINS{$pin}{"fh"} , ">", $val) or warn "Issue opening $val [$!]\n";
        }
}

sub gpio_close {
        foreach $pin ( keys %PINS ) {
                close ($PINS{$pin}{"fh"});
        }
}

sub ascii_to_binary ($) {

        (my $str = shift) =~ s/(.|\n)/sprintf("%02lx", ord $1)/eg;

        $binary = "";
        @arr = split(//, $str);
        foreach $ele (@arr) {
                $binary .= $h2b{$ele};
        }
        return $binary;
}

sub gpio_value_data {

        $string = $_[0];
        @chars = split(//, $string);

        foreach $char (@chars) {
                $binary = ascii_to_binary($char);
                @bits = split(//, $binary);

                gpio_value("data", $bits[0], $bits[1], $bits[2], $bits[3]);

                gpio_value("data", $bits[4], $bits[5], $bits[6], $bits[7]);
        }
}

sub gpio_value {

        $RS_value = ($_[0] eq "cmd") ? 0 : 1;

        $v_D7 = $_[1];
        $v_D6 = $_[2];
        $v_D5 = $_[3];
        $v_D4 = $_[4];

        #print $_[0] . " ($RS_value) | $v_D7 $v_D6 $v_D5 $v_D4\n";

        syswrite($PINS{"E"}{"fh"}, 1, 1);
        syswrite($PINS{"RS"}{"fh"}, $RS_value, 1);
        syswrite($PINS{"D4"}{"fh"}, $v_D4, 1);
        syswrite($PINS{"D5"}{"fh"}, $v_D5, 1);
        syswrite($PINS{"D6"}{"fh"}, $v_D6, 1);
        syswrite($PINS{"D7"}{"fh"}, $v_D7, 1);

        syswrite($PINS{"E"}{"fh"}, 0, 1);
        sleep(0.003);
}
