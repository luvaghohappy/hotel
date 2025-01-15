<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Sanitize inputs
$nomchambre = htmlspecialchars($_POST["nomchambre"]);
$description = htmlspecialchars($_POST["descriptions"]);
$prix = htmlspecialchars($_POST["prix"]);

// Validate required fields
if (empty($nomchambre) || empty($description) || empty($prix)) {
    echo json_encode(array("status" => "failed", "error" => "All fields are required."));
    exit;
}

// Handle image upload
$upload_dir = "uploads/";
if (!file_exists($upload_dir)) {
    mkdir($upload_dir, 0777, true);
}

$imageName = uniqid() . '_' . basename($_FILES["profil"]["name"]);
$target_file = $upload_dir . $imageName;
$imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

// Validate file type
$check = getimagesize($_FILES["profil"]["tmp_name"]);
if ($check === false) {
    echo json_encode(array("status" => "failed", "error" => "File is not an image."));
    exit;
}

// Move uploaded file
if (!move_uploaded_file($_FILES["profil"]["tmp_name"], $target_file)) {
    echo json_encode(array("status" => "failed", "error" => "Failed to upload image."));
    exit;
}

// Insert into database
try {
    $stmt = $connect->prepare("INSERT INTO rooms (nomchambre, descriptions, prix, profil) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $nomchambre, $description, $prix, $target_file);
    $stmt->execute();

    echo json_encode(array("status" => "success", "image_path" => $target_file));
} catch (Exception $e) {
    echo json_encode(array("status" => "failed", "error" => $e->getMessage()));
}

$connect->close();
?>

