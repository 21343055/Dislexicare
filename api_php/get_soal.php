<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require_once "config.php";

$query = "
    SELECT 
        id_soal, 
        kalimat, 
        tingkat_kesulitan 
    FROM soal
    ORDER BY id_soal DESC
";

$result = $conn->query($query);

$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = [
        "id_soal" => $row["id_soal"],
        "kalimat" => $row["kalimat"],
        "tingkat_kesulitan" => $row["tingkat_kesulitan"]
    ];
}

echo json_encode([
    "status" => true,
    "message" => "Berhasil mengambil data soal",
    "data" => $data
]);
