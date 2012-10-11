require LCD;

$lcd  = LCD->new();

$lcd->configuration;

$lcd->set_position(0, 0);
$lcd->print("Beaglebone");

$lcd->set_position(2, 0);
$lcd->print("LCD 4x20 HD77480");

$lcd->close;

exit;

