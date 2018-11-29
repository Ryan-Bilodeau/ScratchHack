<?php
/**
 * Created by PhpStorm.
 * User: Ryan Bilodeau
 * Date: 2/24/2018
 * Time: 10:16 AM
 */

ini_set('max_execution_time', 1000000);
include "../simplehtmldom_1_5/simple_html_dom.php";
include "connection.php";

echo "<h2>Unclaimed Prizes...</h2>";

$url = "http://www.calottery.com/play/scratchers-games/top-prizes-remaining";
$curl = curl_init();
curl_setopt($curl, CURLOPT_HEADER, false);
curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($curl, CURLOPT_URL, $url);
curl_setopt($curl, CURLOPT_REFERER, $url);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$result = curl_exec($curl);
curl_close($curl);

$page = new simple_html_dom();
$page->load($result);

$table = $page->find('table[class="tablesorter about tag_even"]', 0);
$links = array();
foreach ($table->find('a[href^="/LotteryHome/play/scratchers-games/"]') as $l) {
    if ($l->parent()->tag != 'nobr') {
        $links[] = "http://www.calottery.com" . $l->href;
    }
}
foreach ($links as $link) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_URL, $link);
    curl_setopt($ch, CURLOPT_REFERER, $link);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $res = curl_exec($ch);
    curl_close($ch);

    $pg = new simple_html_dom();
    $pg->load($res);

    $gameName = "";
    $price = "";
    $odds = "";
    $gameNumber = "";
    $date = date('Ymd', time() - (3600 * 5));

    $prizeAmount = "";
    $prizeOdds = "";
    $prizesPrinted = "";
    $prizesRemaining = "";

    $gameName = $pg->find('div[class="heroContentBox"]', 0)->find('h1', 0)->plaintext;
    $gameName = str_replace("'", "''", $gameName);
    $gameName = html_entity_decode($gameName);
    $gameName = trim($gameName);
    $gameName = str_replace("®", "", $gameName);
    $gameName = str_replace("™", "", $gameName);

    $row = $pg->find('p[class="scratchers-full-width"]', 0)->plaintext;
    $row = trim($row);
    $temp = explode("|", $row);

    $price = $temp[0];
    $price = str_replace("Ticket Price: $", "", $price);
    $price = preg_replace("/\D/", "", $price);

    $odds = $temp[1];
    $odds = str_replace("Overall odds: 1 in ", "", $odds);
    $odds = str_replace(",", "", $odds);
    $odds = trim($odds);

    $gameNumber = $temp[3];
    $gameNumber = str_replace("Game Number: ", "", $gameNumber);
    $gameNumber = preg_replace("/\D/", "", $gameNumber);

    $con->set_charset('utf8');
    $sql = "insert into scraped_tickets(st_game_name, st_game_number, st_price, st_odds, st_date)
            values ('$gameName', '$gameNumber', '$price', '$odds', '$date')";
    $con->query($sql);

    $cells = array();
    foreach ($pg->find('table[class="draw_games tag_even"]', 0)->find('td') as $td) {
        $cells[] = $td;
    }
    for ($i = 0; $i < 25 && $i + 5 <= count($cells); $i+=5) {
        $prizeAmount = $cells[$i]->plaintext;
        $prizeAmount = preg_replace("/\D/", "", $prizeAmount);

        $prizeOdds = $cells[$i + 1]->plaintext;
        $prizeOdds = preg_replace("/\D/", "", $prizeOdds );

        $prizesPrinted = $cells[$i + 2]->plaintext;
        $prizesPrinted = preg_replace("/\D/", "", $prizesPrinted);

        $prizesRemaining = $cells[$i + 4]->plaintext;
        $prizesRemaining = preg_replace("/\D/", "", $prizesRemaining);

        $sql = "insert into scraped_prizes(sp_game_number, sp_prize_amount, sp_prize_odds, sp_prizes_printed,
                sp_prizes_remaining, sp_date)
                values ('$gameNumber', '$prizeAmount', '$prizeOdds', '$prizesPrinted',
                '$prizesRemaining', '$date')";
        $con->query($sql);

        echo "|" . $gameName . "|" . $price .  "|" . $odds . "|" . $gameNumber . "|" .
            $prizeAmount . "|" . $prizeOdds . "|" . $prizesPrinted . "|" . $prizesRemaining . "|" . '<br>';
    }

    $pg->clear();
    unset($pg);
}

$con = null;
$page->clear();
unset($page);
