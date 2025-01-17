<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php');  // Inclut le fichier de connexion à la base de données

// Vérifiez si 'nomchambre' est passé dans la requête POST
if (isset($_POST['nomchambre'])) {
    $nomchambre = $_POST['nomchambre'];

    // Effectuer la requête SQL avec la variable $connect venant de conn.php
    $query = "SELECT Date_reservation, Date_fin FROM reservation WHERE nomchambre = '$nomchambre' AND CURDATE() BETWEEN Date_reservation AND Date_fin LIMIT 1";
    $result = mysqli_query($connect, $query);  // Utilisez $connect ici

    if ($result && mysqli_num_rows($result) > 0) {
        $data = mysqli_fetch_assoc($result);
        echo json_encode([
            'is_reserved' => true,
            'Date_reservation' => $data['Date_reservation'],
            'Date_fin' => $data['Date_fin'],
        ]);
    } else {
        echo json_encode(['is_reserved' => false]);
    }
} else {
    echo json_encode(['error' => 'Nom de chambre manquant']);
}
?>
