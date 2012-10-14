package LCD;

# author: S. Eickhoff
# version: 1.01 
# date: 10/10/2012

use strict;
use IO::File;
use Time::HiRes qw( usleep sleep );

##################################################
# Hash table for for converting hex characters   #
# to binary strings.                             #
##################################################

my %h2b = (
	'0' => "0000", '1' => "0001", '2' => "0010", '3' => "0011",
	'4' => "0100", '5' => "0101", '6' => "0110", '7' => "0111", 
	'8' => "1000", '9' => "1001", 'a' => "1010", 'b' => "1011", 
	'c' => "1100", 'd' => "1101", 'e' => "1110", 'f' => "1111"
);	

##################################################
# LCD object constructor. Supply a               #
# configuration Hash or use the default          #
# configuration.                                 #
##################################################

sub new {
	my ($class)  = shift;
	my (%config) = @_;
	
	my $self  = {};

	$self->{RS}{gpio} 	= $config{RS}{gpio} || "GPIO1_7";
	$self->{RS}{header} 	= $config{RS}{header} || "P8_4";
	$self->{RS}{pin} 	= $config{RS}{pin} || 39;
	$self->{RS}{dir} 	= $config{RS}{dir} || "out";
	$self->{RS}{mode} 	= $config{RS}{mode} || 7;
	$self->{RS}{mode0} 	= $config{RS}{mode0} || "gpmc_ad7";		
	$self->{RS}{fh} 	= undef;

	$self->{E}{gpio} 	= $config{E}{gpio} || "GPIO1_6";
	$self->{E}{header} 	= $config{E}{header} || "P8_3";
	$self->{E}{pin} 	= $config{E}{pin} || 38;
	$self->{E}{dir} 	= $config{E}{dir} || "out";
	$self->{E}{mode} 	= $config{E}{mode} || 7;
	$self->{E}{mode0} 	= $config{E}{mode0} || "gpmc_ad6";		
	$self->{E}{fh} 		= undef;		
	
	$self->{D4}{gpio} 	= $config{D4}{gpio} || "GPIO1_2";
	$self->{D4}{header} 	= $config{D4}{header} || "P8_5";
	$self->{D4}{pin} 	= $config{D4}{pin} || 34;
	$self->{D4}{dir} 	= $config{D4}{dir} || "out";
	$self->{D4}{mode} 	= $config{D4}{mode} || 7;
	$self->{D4}{mode0} 	= $config{D4}{mode0} || "gpmc_ad2";		
	$self->{D4}{fh} 	= undef;
	
	$self->{D5}{gpio} 	= $config{D5}{gpio} || "GPIO1_13";
	$self->{D5}{header} 	= $config{D5}{header} || "P8_11";
	$self->{D5}{pin} 	= $config{D5}{pin} || 45;
	$self->{D5}{dir} 	= $config{D5}{dir} || "out";
	$self->{D5}{mode} 	= $config{D5}{mode} || 7;
	$self->{D5}{mode0} 	= $config{D5}{mode0} || "gpmc_ad13";		
	$self->{D5}{fh} 	= undef;
	
	$self->{D6}{gpio} 	= $config{D6}{gpio} || "GPIO1_12";
	$self->{D6}{header} 	= $config{D6}{header} || "P8_12";
	$self->{D6}{pin} 	= $config{D6}{pin} || 44;
	$self->{D6}{dir} 	= $config{D6}{dir} || "out";
	$self->{D6}{mode} 	= $config{D6}{mode} || 7;
	$self->{D6}{mode0} 	= $config{D6}{mode0} || "gpmc_ad12";		
	$self->{D6}{fh} 	= undef;
	
	$self->{D7}{gpio} 	= $config{D7}{gpio} || "GPIO0_26";
	$self->{D7}{header} 	= $config{D7}{header} || "P8_14";
	$self->{D7}{pin} 	= $config{D7}{pin} || 26;
	$self->{D7}{dir} 	= $config{D7}{dir} || "out";
	$self->{D7}{mode} 	= $config{D7}{mode} || 7;
	$self->{D7}{mode0} 	= $config{D7}{mode0} || "gpmc_ad10";		
	$self->{D7}{fh} 	= undef;
	
	bless($self);
	
	$self->_gpio_export();
	$self->_gpio_open();
	#$self->_gpio_export();
	$self->_lcd_initialize();
	
	return $self;
}

##################################################
# Set the cursor position by supplying a zero    #
# index row and column.                          #
##################################################

sub set_position {
	my $self = shift;
	
	my $row = shift;
	my $col = shift;
	my $address;
	
	# line 1
	if ($row == 0) {
		$address = sprintf("%x", (128 + $col)); # hex 80
	}
	# line 2
	elsif ($row == 1) {
		$address = sprintf("%x", (192 + $col)); # hex C0
	}
	# line 3
	elsif ($row == 2) {
		$address = sprintf("%x", (148 + $col)); # hex 94
	}
	# line 4
	elsif ($row == 3) {
		$address = sprintf("%x", (212 + $col)); # hex D4
	}

	my @chars = split(//, $address);
	foreach my $char (@chars) {
		my $binary = $h2b{$char};
		my @bits = split(//, $binary);
		$self->_gpio_write("cmd", $bits[0], $bits[1], $bits[2], $bits[3]);
	}
	return;
}	

##################################################
# Print a string of text to LCD at current       #
# position.                                      #
##################################################

sub print {
	my $self = shift;
	
	my $string = shift;
	my @chars = split(//, $string);

	foreach my $char (@chars) {
		my $binary = _ascii_to_binary($char);
		my @bits = split(//, $binary);

		$self->_gpio_write("data", $bits[0], $bits[1], $bits[2], $bits[3]);
		$self->_gpio_write("data", $bits[4], $bits[5], $bits[6], $bits[7]);
	}
	return;
}	

##################################################
# Object destructor.                             #
##################################################

sub close {
	my $self = shift;
	
	$self->DESTROY;
}

##################################################
# Perform the cleanup and object destruction.    #
##################################################

sub DESTROY {
	my $self = shift;
	
	foreach my $lcd_pin ( keys %$self ) {
		# close the file handles used for writing gpio values
		close ($self->{$lcd_pin}->{"fh"});
		
		# unexport the gpio pin
		open (FH, '>>/sys/class/gpio/unexport');
		print FH $self->{$lcd_pin}->{"pin"};
		close(FH);		
	}

	undef %$self ;
	return;
}

##################################################
# Printout the configuration data structure.     #
##################################################

sub configuration {
	my $self = shift;
	
	foreach my $lcd_pin ( keys %$self ) {

		printf "\n%-10s %-10s %-20s\n", "LCD_PIN", "BB_PARAM", "BB_VALUE"; 
		printf "%-10s %-10s %-20s\n", "---------", "---------", "-------------------"; 		
	
		for my $field (keys %{ $self->{$lcd_pin} } ) {
			my $value = $self->{$lcd_pin}->{$field};
			printf "%-10s %-10s %-20s\n", $lcd_pin, $field, $value; 
		}
	}
	return;
}

##################################################
# Convert ASCII character to a binary string.    #
##################################################

sub _ascii_to_binary ($) {
	(my $str = shift) =~ s/(.|\n)/sprintf("%02lx", ord $1)/eg;
 
	my $binary = "";
	my @arr = split(//, $str);
	foreach my $ele (@arr) {
		$binary .= $h2b{$ele};
	}
	return $binary;
}	
 
##################################################
# Open the GPIO pins for writing values.         #
##################################################

sub _gpio_open {
	my $self = shift;
	
	foreach my $lcd_pin ( keys %$self ) {
		my $val = '/sys/class/gpio/gpio' . $self->{$lcd_pin}->{"pin"} . '/value';
		$self->{$lcd_pin}->{"fh"} = IO::File->new("> $val");
		open ($self->{$lcd_pin}->{"fh"} , ">", $val) or warn "Opening $val [$!]\n";
	}
	return;
}	

##################################################
# Set omap_mux modes, export the GPIO pins  and  #
# set the direction.                             #
##################################################

sub _gpio_export {
	my $self = shift;
	
	foreach my $lcd_pin ( keys %$self ) {
		# set mode i.e. 7
		open (FH, '>>/sys/kernel/debug/omap_mux/' . $self->{$lcd_pin}->{"mode0"}) 
			or warn "Setting mode " . $self->{$lcd_pin}->{"mode"} . " for " . $self->{$lcd_pin}->{"mode0"} . " [$!]\n";
		print FH $self->{$lcd_pin}->{"mode"};
		close(FH);

		# export
		open (FH, '>>/sys/class/gpio/export') 
			or warn "Exporting pin " . $self->{$lcd_pin}->{"pin"} . " [$!]\n";
		print FH $self->{$lcd_pin}->{"pin"};
		close(FH);

		# set direction
		my $dir = '/sys/class/gpio/gpio' . $self->{$lcd_pin}->{"pin"} . '/direction';
		open (FH, ">$dir") 
			or warn "Direction $dir [$!]\n";
		print FH $self->{$lcd_pin}->{"dir"};
		close(FH);
	}
	return;
}

##################################################
# Issue HD44780 commands to initialize the       #
# LCD screen and place it in 4-bit mode.         #
##################################################

sub _lcd_initialize {
	my $self = shift;

	# initialization (8-bit mode x 3, 4-bit mode x1)
	$self->_gpio_write("cmd", 0, 0, 1, 1);
	$self->_gpio_write("cmd", 0, 0, 1, 1);
	$self->_gpio_write("cmd", 0, 0, 1, 1);
	$self->_gpio_write("cmd", 0, 0, 1, 0);

	# function set (4-bit mode, 2-line)
	$self->_gpio_write("cmd", 0, 0, 1, 0);
	$self->_gpio_write("cmd", 1, 0, 0, 0);

	# clear display
	$self->_gpio_write("cmd", 0, 0, 0, 0);
	$self->_gpio_write("cmd", 0, 0, 0, 1);

	# display on/of (display on, cursor on, blink on)
	$self->_gpio_write("cmd", 0, 0, 0, 0);
	$self->_gpio_write("cmd", 1, 1, 1, 1);

	$self->_gpio_write("cmd", 0, 0, 0, 0);
	$self->_gpio_write("cmd", 0, 1, 1, 0);
	
	return;
}	

##################################################
# Send the values the GPIO pins.                 #
##################################################

sub _gpio_write {
	my $self = shift;

	my $RS_type = shift;
	my $RS_value = ($RS_type eq "cmd") ? 0 : 1;

	my $v_D7 = shift;
	my $v_D6 = shift;
	my $v_D5 = shift;
	my $v_D4 = shift;

	# debugging
	#print "$RS_type ($RS_value) | $v_D7 $v_D6 $v_D5 $v_D4\n";

	syswrite($self->{"E"}->{"fh"}, 1, 1);
	syswrite($self->{"RS"}->{"fh"}, $RS_value, 1);
	syswrite($self->{"D4"}->{"fh"}, $v_D4, 1);
	syswrite($self->{"D5"}->{"fh"}, $v_D5, 1);
	syswrite($self->{"D6"}->{"fh"}, $v_D6, 1);
	syswrite($self->{"D7"}->{"fh"}, $v_D7, 1);

	syswrite($self->{"E"}{"fh"}, 0, 1);
	sleep(0.003);
	
	return;
}

1;  # so the require or use succeeds
