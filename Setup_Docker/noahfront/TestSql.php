<?php 
$serverName = "noahdb\SQLEXPRESS"; //serverName\instanceName
$connectionInfo = array("Database"=>"master","UID" => "SA","PWD" => "C01aL({L7lnqGtu5pe1Mqbu1FSQN>U_U",);
$conn = sqlsrv_connect( $serverName, $connectionInfo);

if( $conn ) {
     echo "Connection established.<br />";
}else{
     echo "Connection could not be established.<br />";
     die( print_r( sqlsrv_errors(), true));
}
