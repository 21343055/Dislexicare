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

$user_id = intval($data['user_id'] ?? 0);
$teks_soal = trim($data['teks_soal'] ?? '');
$tingkat   = trim($data['tingkat_kesulitan'] ?? '');

/* ================= VALIDASI DASAR ================= */
if ($user_id === 0 || $teks_soal === '' || $tingkat === '') {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Data tidak lengkap"
    ]);
    exit;
}

/* ================= CEK ROLE ADMIN ================= */
$stmtRole = $conn->prepare("SELECT role FROM users WHERE id = ?");
$stmtRole->bind_param("i", $user_id);
$stmtRole->execute();
$resultRole = $stmtRole->get_result();

if ($resultRole->num_rows === 0) {
    http_response_code(403);
    echo json_encode([
        "status" => false,
        "message" => "User tidak ditemukan"
    ]);
    exit;
}

$user = $resultRole->fetch_assoc();

if ($user['role'] !== 'admin') {
    http_response_code(403);
    echo json_encode([
        "status" => false,
        "message" => "Akses ditolak. Hanya admin yang dapat menambahkan soal"
    ]);
    exit;
}

/* ================= INSERT SOAL ================= */
$stmt = $conn->prepare(
    "INSERT INTO soal (kalimat, tingkat_kesulitan) VALUES (?, ?)"
);
$stmt->bind_param("ss", $teks_soal, $tingkat);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Soal berhasil ditambahkan"
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Gagal menambahkan soal"
    ]);
}
