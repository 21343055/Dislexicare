<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once "config.php";

$data = json_decode(file_get_contents("php://input"), true);

// Ambil input
$username = trim($data['username'] ?? '');
$password = $data['password'] ?? '';

// Validasi
if ($username === '' || $password === '') {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Username dan password wajib diisi"
    ]);
    exit;
}

// Ambil user berdasarkan username
$stmt = $conn->prepare(
    "SELECT id, username, email, password, role 
     FROM users 
     WHERE username = ? 
     LIMIT 1"
);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    http_response_code(401);
    echo json_encode([
        "status" => false,
        "message" => "Username atau password salah"
    ]);
    exit;
}

$user = $result->fetch_assoc();

// Verifikasi password
if (!password_verify($password, $user['password'])) {
    http_response_code(401);
    echo json_encode([
        "status" => false,
        "message" => "Username atau password salah"
    ]);
    exit;
}

// Login berhasil
echo json_encode([
    "status" => true,
    "message" => "Login berhasil",
    "user" => [
        "id"       => $user['id'],
        "username" => $user['username'],
        "email"    => $user['email'],
        "role"     => $user['role']
    ]
]);
