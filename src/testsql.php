<?php 
$serverName = "noahdb\SQLEXPRESS"; //serverName\instanceName
$connectionInfo = array("Database"=>"master","UID" => "SA","PWD" => "11586985851756998150",);
$conn = sqlsrv_connect( $serverName, $connectionInfo);
if( $conn ) {
     echo "Connection established.<br />";
}else{
     echo "Connection could not be established.<br />";
     die( print_r( sqlsrv_errors(), true));
}