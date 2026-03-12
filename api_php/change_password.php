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

// Ambil JSON body
$data = json_decode(file_get_contents("php://input"), true);

$user_id      = $data['user_id'] ?? 0;
$old_password = $data['old_password'] ?? '';
$new_password = $data['new_password'] ?? '';

if ($user_id == 0 || empty($old_password) || empty($new_password)) {
    echo json_encode([
        "status" => false,
        "message" => "Data tidak lengkap"
    ]);
    exit;
}

if (strlen($new_password) < 6) {
    echo json_encode([
        "status" => false,
        "message" => "Password baru minimal 6 karakter"
    ]);
    exit;
}

// ================= AMBIL PASSWORD LAMA =================
$stmt = $conn->prepare("SELECT password FROM users WHERE id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "status" => false,
        "message" => "User tidak ditemukan"
    ]);
    exit;
}

$user = $result->fetch_assoc();

// ================= VERIFIKASI PASSWORD LAMA =================
if (!password_verify($old_password, $user['password'])) {
    echo json_encode([
        "status" => false,
        "message" => "Password lama salah"
    ]);
    exit;
}

// ================= UPDATE PASSWORD BARU =================
$new_password_hash = password_hash($new_password, PASSWORD_DEFAULT);

$update = $conn->prepare("UPDATE users SET password = ? WHERE id = ?");
$update->bind_param("si", $new_password_hash, $user_id);

if ($update->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Password berhasil diubah"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Gagal mengubah password"
    ]);
}
