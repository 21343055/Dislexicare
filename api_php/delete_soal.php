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

$user_id = $data['user_id'] ?? null;
$id      = $data['id'] ?? null;

if (!$user_id || !$id) {
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
   DELETE SOAL
   ============================= */
$stmt = $conn->prepare("DELETE FROM soal WHERE id_soal = ?");
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Soal berhasil dihapus"
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Gagal menghapus soal"
    ]);
}

$stmt->close();
$conn->close();
