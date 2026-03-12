<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "config.php";

$data = json_decode(file_get_contents("php://input"), true);

// Ambil input
$username = trim($data['username'] ?? '');
$email    = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

// Validasi input
if ($username === '' || $email === '' || $password === '') {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Semua field wajib diisi"
    ]);
    exit;
}

// Ambil role, default ke 'orangtua' jika kosong
$role = strtolower(trim($data['role'] ?? 'orangtua'));

// Validasi role (hanya boleh orangtua atau guru)
if (!in_array($role, ['orangtua', 'guru'])) {
    $role = 'orangtua';
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Cek email sudah terdaftar
$check = $conn->prepare("SELECT id FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    http_response_code(409);
    echo json_encode([
        "status" => false,
        "message" => "Email sudah terdaftar"
    ]);
    exit;
}

// Simpan user baru
$stmt = $conn->prepare(
    "INSERT INTO users (username, email, password, role)
     VALUES (?, ?, ?, ?)"
);
$stmt->bind_param("ssss", $username, $email, $hashedPassword, $role);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Registrasi berhasil"
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Registrasi gagal"
    ]);
}
