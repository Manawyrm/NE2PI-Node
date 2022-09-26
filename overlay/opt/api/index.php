<?php
header("Content-Type: application/json");
echo json_encode([
	"mem" => `free -h`,
	"ps aux" => `ps aux`,
	"temp" => trim(str_replace("temp=", "", `sudo vcgencmd measure_temp 2>&1`)),
], JSON_PRETTY_PRINT);
