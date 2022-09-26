<?php
header("Content-Type: application/json");

if (isset($_GET["command"]))
{
	$command = $_GET["command"];
	$cmd = "i2ctransfer -y 1 " . $command . " 2>&1";
	$return = `$cmd`;
}
else
{
	$cmd = "i2cdetect -y 1";
	$return = `$cmd`;
}

echo json_encode([
	"return" => $return
], JSON_PRETTY_PRINT);
