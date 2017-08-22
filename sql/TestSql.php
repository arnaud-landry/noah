<?php 
$serverName = "localhost\SQLEXPRESS"; //serverName\instanceName
$connectionInfo = array("Database"=>"testdb","UID" => "testuser","PWD" => "SA-PWD-CHANGEME-723387667",);
$conn = sqlsrv_connect( $serverName, $connectionInfo);

if( $conn ) {
     echo "Connection established.<br />";
}else{
     echo "Connection could not be established.<br />";
     die( print_r( sqlsrv_errors(), true));
}
