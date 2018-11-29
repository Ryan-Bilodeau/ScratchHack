<?php
/**
 * Created by PhpStorm.
 * User: Ryan Bilodeau
 * Date: 2/21/2018
 * Time: 9:40 PM
 */

class OregonTicket {
    public $name;
    public $price;
    public $number;

    public $score;
    public $topPrizesRemaining;
    public $prizes = array();
}
class OregonPrize {
    public $prizeAmount;
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
    AS tickets INNER JOIN (SELECT * FROM scraped_prizes WHERE sp_date = '$date') AS prizes ON
    tickets.st_game_number = prizes.sp_game_number");

    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $tickets = array();
    $newTicket = true;
    $lastTicketNumber = 0;
    $ticket = new OregonTicket();
    $prize = new OregonPrize();
    foreach ($result as $row) {
        $prize = new OregonPrize();

        $name = $row["st_game_name"];
        $name = str_replace("\r", "", $name);
        $name = str_replace("\n", "", $name);
        $name = str_replace("'", "''", $name);
        $price = $row["st_price"];
        $number = $row["st_game_number"];

        $prizeAmount = $row["sp_prize_amount"];
        $prizesRemaining = $row["sp_prizes_remaining"];

        if ($lastTicketNumber != $number && $newTicket == false) {
            $contains = false;
//            foreach ($tickets as $tik) {
//                if ($tik->number == $ticket->number) {
//                    $contains = true;
//                }
//            }
//            if (!$contains) {
//                $tickets[] = $ticket;
//            }
            $tickets[] = $ticket;

            $prizes = new OregonPrize();
            $ticket = new OregonTicket();

            $newTicket = true;
        }
        if ($newTicket) {
            $ticket->name = $name;
            $ticket->price = $price;
            $ticket->number = $number;

            $prize->prizeAmount = $prizeAmount;
            $prize->prizesRemaining = $prizesRemaining;

            $ticket->prizes[] = $prize;

            $newTicket = false;
        } else {
            $prize->prizeAmount = $prizeAmount;
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
        $sql = "INSERT INTO formatted_tickets(ft_price, ft_game_number,ft_game_name,
        ft_top_prizes_remaining, ft_rank)
        VALUES('$tik->price', '$tik->number','$tik->name', '$tik->topPrizesRemaining', '$tik->score')";
        $insertConnection->query($sql);
    }
    echo json_encode($tickets);
}
catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}

$insertConnection = null;
$getConnection = null;
