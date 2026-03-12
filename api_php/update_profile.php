<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "config.php";

$data = json_decode(file_get_contents("php://input"), true);

$user_id        = $data['user_id'] ?? 0;
$username       = $data['username'] ?? '';
$no_hp          = $data['no_hp'] ?? '';
$tanggal_lahir  = $data['tanggal_lahir'] ?? '';
$jenis_kelamin  = $data['jenis_kelamin'] ?? '';
$kota           = $data['kota'] ?? '';

if ($user_id == 0) {
    echo json_encode([
        "status" => false,
        "message" => "User ID tidak valid"
    ]);
    exit;
}

if ($username == '' || $no_hp == '') {
    echo json_encode([
        "status" => false,
        "message" => "Username dan No HP wajib diisi"
    ]);
    exit;
}

$stmt = $conn->prepare("
    UPDATE users 
    SET 
        username = ?,
        no_hp = ?,
        tanggal_lahir = ?,
        jenis_kelamin = ?,
        kota = ?
    WHERE id = ?
");

$stmt->bind_param(
    "sssssi",
    $username,
    $no_hp,
    $tanggal_lahir,
    $jenis_kelamin,
    $kota,
    $user_id
);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Profil berhasil diperbarui"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Gagal memperbarui profil"
    ]);
}

$stmt->close();
$conn->close();
