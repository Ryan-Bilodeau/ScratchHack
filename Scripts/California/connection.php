<?php
/**
 * Created by PhpStorm.
 * User: Ryan Bilodeau
 * Date: 2/21/2018
 * Time: 9:42 PM
 */

include "config.php";

$con = new mysqli(DB_HOST, DB_USER, DB_PASS);

if ($con->connect_error) {
    echo("\n\nCould not connect: ERROR NO. " .
        $con->connect_errno . " : " .
        $con->connect_error);
    die ("<br/><br/> Could not connect to db. Further Script processing terminated ");
}

$con->select_db(DEFAULT_DB_NAME);
