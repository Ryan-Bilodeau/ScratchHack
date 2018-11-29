<?php
/**
 * Created by PhpStorm.
 * User: Ryan Bilodeau
 * Date: 2/21/2018
 * Time: 9:40 PM
 */

class CaliforniaTicket {
    public $name;
    public $number;
    public $price;
    public $odds;
    public $score;
    public $topPrizesRemaining;
    public $prizes = array();
}
class CaliforniaPrize {
    public $prizeAmount;
    public $prizeOdds;
    public $prizesPrinted;
    public $prizesRemaining;
}

$servername = "";
$username = "";
$password = "";
$dbname = "";

$date = date('Ymd', time() - (3600 * 5));

try {
    $getConnection = new PDO("mysql:host=$servername;dbname=$dbname;", $username, $password);
    $getConnection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $insertConnection = new mysqli($servername, $username, $password);
    $insertConnection->select_db($dbname);
    $insertConnection->set_charset('utf8');

    $stmt = $getConnection->prepare("SELECT * FROM (SELECT * FROM scraped_tickets WHERE st_date = '$date')
    AS tickets INNER JOIN (SELECT *FROM scraped_prizes WHERE sp_date = '$date') AS prizes ON
    tickets.st_game_number = prizes.sp_game_number");

    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $tickets = array();
    $newTicket = true;
    $lastTicketNumber = 0;
    $ticket = new CaliforniaTicket();
    $prize = new CaliforniaPrize();
    foreach ($result as $row) {
        $prize = new CaliforniaPrize();
        $name = "";
        $name = $row["st_game_name"];
        $name = str_replace("\r", "", $name);
        $name = str_replace("\n", "", $name);

        $number = "";
        $number = $row["st_game_number"];
        $price = "";
        $price = $row["st_price"];
        $odds = "";
        $odds = $row["st_odds"];
        $prizeAmount = "";
        $prizeAmount = $row["sp_prize_amount"];
        $prizeOdds = "";
        $prizeOdds = $row["sp_prize_odds"];
        $prizesPrinted = "";
        $prizesPrinted = $row["sp_prizes_printed"];
        $prizesRemaining = "";
        $prizesRemaining = $row["sp_prizes_remaining"];

        if ($lastTicketNumber != $number && $newTicket == false) {
            $tickets[] = $ticket;
            $prizes = new CaliforniaPrize();
            $ticket = new CaliforniaTicket();

            $newTicket = true;
        }
        if ($newTicket) {
            $ticket->name = str_replace("'", "''", $name);
            $ticket->number = $number;
            $ticket->price = $price;
            $ticket->odds = $odds;

            $prize->prizeAmount = $prizeAmount;
            $prize->prizeOdds = $prizeOdds;
            $prize->prizesPrinted = $prizesPrinted;
            $prize->prizesRemaining = $prizesRemaining;

            $ticket->prizes[] = $prize;

            $newTicket = false;
        } else {
            $prize->prizeAmount = $prizeAmount;
            $prize->prizeOdds = $prizeOdds;
            $prize->prizesPrinted = $prizesPrinted;
            $prize->prizesRemaining = $prizesRemaining;

            $ticket->prizes[] = $prize;
        }

        $lastTicketNumber = $number;
    }
    $tickets[] = $ticket;

    foreach ($tickets as $tik) {
        $totalPrizes = 0;
        $totalWinnings = 0;

        foreach ($tik->prizes as $prize) {
            $totalPrizes += $prize->prizesRemaining;
            $totalWinnings += $prize->prizesRemaining * $prize->prizeAmount;
        }

        $tik->score = ($totalWinnings * $totalPrizes) / $tik->price;
        $tik->topPrizesRemaining = (int)$totalPrizes;
    }

    usort($tickets, function($a, $b) {
        return $a->score < $b->score;
    });

    for ($i = 0; $i < count($tickets); $i++) {
        $tickets[$i]->score = $i + 1;
    }

    $stmt = $getConnection->prepare("DELETE FROM formatted_tickets");
    $stmt->execute();

    foreach ($tickets as $tik) {
        $sql = "INSERT INTO formatted_tickets(ft_price, ft_game_number, ft_game_name,
        ft_top_prizes_remaining, ft_rank)
        VALUES('$tik->price', '$tik->number', '$tik->name', '$tik->topPrizesRemaining', '$tik->score')";
        $insertConnection->query($sql);
    }
    echo json_encode($tickets);
}
catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}

$insertConnection = null;
$getConnection = null;
