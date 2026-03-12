<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");
error_reporting(0); // Matikan output error bawaan
ini_set('display_errors', 0);

// Fungsi untuk menangkap error fatal dan mengubahnya jadi JSON
function shutdownHandler() {
    $error = error_get_last();
    if ($error !== NULL && $error['type'] === E_ERROR) {
        http_response_code(500);
        echo json_encode([
            "status" => false,
            "message" => "PHP Fatal Error: " . $error['message'] . " on line " . $error['line']
        ]);
    }
}
register_shutdown_function('shutdownHandler');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "config.php";

$input = file_get_contents("php://input");
$data = json_decode($input, true);

// Debug jika JSON invalid
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode(["status" => false, "message" => "Invalid JSON Input: " . json_last_error_msg()]);
    exit;
}

// Input dari Flutter: user_id, nama_anak, hasil, confidence, soal_id, jawaban
$user_id     = $data['user_id'] ?? 0;
$nama_anak   = $data['nama_anak'] ?? '';
$hasil       = $data['hasil'] ?? '';
$confidence  = $data['confidence'] ?? 0;
$soal_id     = $data['soal_id'] ?? 0; // Default 0 jika null, tapi sebaiknya valid
$jawaban_teks = $data['jawaban'] ?? '';

if ($user_id == 0 || $nama_anak === '' || $hasil === '' || $soal_id == 0) {
    http_response_code(400);
    echo json_encode(["status" => false, "message" => "Data tidak lengkap (User, Nama, Hasil, atau Soal ID kosong)"]);
    exit;
}

// 1. CEK APAKAH ANAK SUDAH ADA?
$stmt_check = $conn->prepare("SELECT id_anak FROM anak WHERE user_id = ? AND nama = ?");
if (!$stmt_check) {
    http_response_code(500);
    echo json_encode(["status" => false, "message" => "SQL Error (Check): " . $conn->error]);
    exit;
}
$stmt_check->bind_param("is", $user_id, $nama_anak);
$stmt_check->execute();
$result_check = $stmt_check->get_result();

$anak_id = 0;

if ($result_check->num_rows > 0) {
    // Anak sudah ada, ambil ID-nya
    $row = $result_check->fetch_assoc();
    $anak_id = $row['id_anak'];
} else {
    // Anak belum ada, BUAT BARU
    // Default usia=0, jenis_kelamin='Laki-laki' (bisa diupdate nanti di profil anak)
    $stmt_insert = $conn->prepare("INSERT INTO anak (user_id, nama, usia, jenis_kelamin) VALUES (?, ?, 0, 'Laki-laki')");
    if (!$stmt_insert) {
        http_response_code(500);
        echo json_encode(["status" => false, "message" => "SQL Error (Insert Anak): " . $conn->error]);
        exit;
    }
    $stmt_insert->bind_param("is", $user_id, $nama_anak);
    
    if ($stmt_insert->execute()) {
        $anak_id = $conn->insert_id;
    } else {
        http_response_code(500);
        echo json_encode(["status" => false, "message" => "Gagal membuat data anak: " . $stmt_insert->error]);
        exit;
    }
}

// 2. SIMPAN HASIL DETEKSI
// Kolom: id_hasill (AI), id_anak, id_soal, jawaban_teks, path_audio, hasil_prediksi, confidence, tanggal
$stmt = $conn->prepare(
    "INSERT INTO hasil_deteksi (id_anak, id_soal, jawaban_teks, hasil_prediksi, confidence)
     VALUES (?, ?, ?, ?, ?)"
);
if (!$stmt) {
    http_response_code(500);
    echo json_encode(["status" => false, "message" => "SQL Error (Insert Hasil): " . $conn->error]);
    exit;
}
$stmt->bind_param("iisss", $anak_id, $soal_id, $jawaban_teks, $hasil, $confidence);

if ($stmt->execute()) {
    echo json_encode(["status" => true, "message" => "Hasil deteksi disimpan", "id_anak" => $anak_id]);
} else {
    http_response_code(500);
    echo json_encode(["status" => false, "message" => "Gagal simpan hasil: " . $stmt->error]);
}
