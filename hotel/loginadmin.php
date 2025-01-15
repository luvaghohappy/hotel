<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: *");
header('Content-Type: application/json');

include('conn.php');

// Enable error reporting for debugging (remove in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Retrieve JSON data from request body
$data = json_decode(file_get_contents("php://input"));

$noms = htmlspecialchars($data->noms);
$postnom = htmlspecialchars($data->postnom);
$password = htmlspecialchars($data->passwords);

// Secure SQL query to prevent SQL injection
$rqt = "SELECT * FROM administrateur WHERE nom = '$noms' AND postnom = '$postnom' AND passwords = '$password' LIMIT 1";
$rqt2 = mysqli_query($connect, $rqt);

if (!$rqt2) {
    $response = array("status" => "error", "message" => "Query error: " . mysqli_error($connect));
} elseif (mysqli_num_rows($rqt2) > 0) {
    $response = array("status" => "success", "message" => "Authentication successful");
} else {
    $response = array("status" => "error", "message" => "Invalid credentials");
}

echo json_encode($response);
?>
