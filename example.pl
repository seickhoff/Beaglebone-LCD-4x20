require LCD;

# initialize LCD, clear screen and set cursor to upper left
# you can supply your own configuration in this constructor

$lcd  = LCD->new();

# print the gpio configuration; for debugging

$lcd->configuration; 

# row, column

$lcd->set_position(0, 0); 

# write string to LCD display

$lcd->print("Beaglebone"); 

$lcd->set_position(2, 0);
$lcd->print("LCD 4x20 HD77480");

# cleanup

$lcd->close; 

exit;

