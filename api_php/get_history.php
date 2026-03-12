<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require_once "config.php";

$user_id = $_GET['user_id'] ?? 0;

if ($user_id == 0) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "User ID tidak valid"
    ]);
    exit;
}

$stmt = $conn->prepare(
    "SELECT 
        h.id_hasil AS id,
        a.nama AS nama,
        h.hasil_prediksi AS status,
        h.confidence AS confidence,
        h.tanggal AS tanggal
     FROM hasil_deteksi h
     JOIN anak a ON h.id_anak = a.id_anak
     WHERE a.user_id = ?
     ORDER BY h.tanggal DESC"
);

$stmt->bind_param("i", $user_id);
$stmt->execute();

$result = $stmt->get_result();
$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "status" => true,
    "data" => $data
]);
