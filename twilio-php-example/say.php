<?php
require 'Services/Twilio.php';
if (isset($_REQUEST['say'])) {
    $say = $_REQUEST['say'];
}
$response = new Services_Twilio_Twiml();
$response->say($say);
$response->hangup();
header('Content-Type: text/xml');
print $response;
?>