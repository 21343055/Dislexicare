<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

/* =============================
   HANDLE PREFLIGHT (WAJIB)
   ============================= */
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "config.php";

/* =============================
   AMBIL DATA JSON
   ============================= */
$data = json_decode(file_get_contents("php://input"), true);

$user_id   = $data["user_id"] ?? null;
$id        = $data["id"] ?? null;
$teks_soal = trim($data["teks_soal"] ?? '');
$tingkat   = trim($data["tingkat_kesulitan"] ?? '');

if (!$user_id || !$id || $teks_soal === '' || $tingkat === '') {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Data tidak lengkap"
    ]);
    exit;
}

/* =============================
   CEK ROLE ADMIN
   ============================= */
$stmtRole = $conn->prepare(
    "SELECT role FROM users WHERE id = ? LIMIT 1"
);
$stmtRole->bind_param("i", $user_id);
$stmtRole->execute();
$result = $stmtRole->get_result();

if ($result->num_rows === 0) {
    http_response_code(401);
    echo json_encode([
        "status" => false,
        "message" => "User tidak valid"
    ]);
    exit;
}

$user = $result->fetch_assoc();

if ($user["role"] !== "admin") {
    http_response_code(403);
    echo json_encode([
        "status" => false,
        "message" => "Akses ditolak (admin only)"
    ]);
    exit;
}

/* =============================
   UPDATE SOAL
   ============================= */
$stmt = $conn->prepare(
    "UPDATE soal 
     SET kalimat = ?, tingkat_kesulitan = ? 
     WHERE id_soal = ?"
);
$stmt->bind_param("ssi", $teks_soal, $tingkat, $id);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Soal berhasil diperbarui"
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Gagal memperbarui soal"
    ]);
}

$stmt->close();
$conn->close();
