<?php 
$serverName = "noahdb\SQLEXPRESS"; //serverName\instanceName
$connectionInfo = array("Database"=>"master","UID" => "SA","PWD" => "5c4_fdc6a50+1864b89d8a6576bd9dbb-90",);
$conn = sqlsrv_connect( $serverName, $connectionInfo);

if( $conn ) {
     echo "Connection established.<br />";
}else{
     echo "Connection could not be established.<br />";
     die( print_r( sqlsrv_errors(), true));
}
