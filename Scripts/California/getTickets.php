<?php
/**
 * Created by PhpStorm.
 * User: Ryan Bilodeau
 * Date: 2/21/2018
 * Time: 9:40 PM
 */

$servername = "";
$username = "";
$password = "";
$dbname = "";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname;", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $conn->prepare("SELECT ft_price, ft_game_number, ft_game_name, ft_top_prizes_remaining,
    ft_rank FROM formatted_tickets");

    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($result);
}
catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}

$conn = null;
