<?php 
$serverName = "noahdb\SQLEXPRESS"; //serverName\instanceName
$connectionInfo = array("Database"=>"NOAH","UID" => "SA","PWD" => "11586985851756998150",);
$conn = sqlsrv_connect( $serverName, $connectionInfo);
if( $conn ) {    
}else{
     echo "La connexion n'a pu être établie.<br />";
     die(); // print_r( sqlsrv_errors(), true));
}