<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "config.php";

$user_id = $_GET['user_id'] ?? 0;

if ($user_id == 0) {
    echo json_encode([
        "status" => false,
        "message" => "User ID tidak valid"
    ]);
    exit;
}

$stmt = $conn->prepare("
    SELECT 
        username,
        email,
        no_hp,
        tanggal_lahir,
        jenis_kelamin,
        kota
    FROM users
    WHERE id = ?
");
$stmt->bind_param("i", $user_id);
$stmt->execute();

$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "status" => false,
        "message" => "Data user tidak ditemukan"
    ]);
    exit;
}

$data = $result->fetch_assoc();

echo json_encode([
    "status" => true,
    "data" => $data
]);
