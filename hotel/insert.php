<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupération des données du formulaire, en les protégeant contre les attaques XSS
$nom = htmlspecialchars($_POST["nom"]);
$postnom = htmlspecialchars($_POST["postnom"]);
$sexe = htmlspecialchars($_POST["sexe"]);
$numero = htmlspecialchars($_POST["numero"]);
$nomchambre = htmlspecialchars($_POST["nomchambre"]);
$datereser = htmlspecialchars($_POST["Date_reservation"]);
$datefin = htmlspecialchars($_POST["Date_fin"]);

// Requête SQL pour insérer les données dans la table 'users' 
$sql = "INSERT INTO reservation (nom, postnom, sexe, numero, nomchambre, Date_reservation, Date_fin) 
        VALUES ('$nom', '$postnom', '$sexe', '$numero', '$nomchambre', '$datereser', '$datefin')";

if(mysqli_query($connect, $sql)){
    echo json_encode("success");
}else{
    echo json_encode("failed");
}
?>
