<?php
header("Content-Type: text/plain");

$password = "admin123";

echo password_hash($password, PASSWORD_DEFAULT);
