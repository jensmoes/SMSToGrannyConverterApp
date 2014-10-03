<?php
//Generates a temporary capability token for clients
include 'Services/Twilio/Capability.php';

// put your Twilio API credentials here
$accountSid = <>;
$authToken  = <>;
$appSid     = <>;
$clientName = 'Jens';

// get the Twilio Client name from the page request parameters, if given
if (isset($_REQUEST['client'])) {
    $clientName = $_REQUEST['client'];
}

$capability = new Services_Twilio_Capability($accountSid, $authToken);
$capability->allowClientOutgoing($appSid,array(),$clientName);
$capability->allowClientIncoming($clientName);
$token = $capability->generateToken();

echo $token;
?>
