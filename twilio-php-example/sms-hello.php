<?php

$sid = <Your Id>;
$token  = <Your token>;
require 'Services/Twilio.php';
$client = new Services_Twilio($sid, $token);
    $people = array(
        "+1234567890"=>"Benny Hill",

    );
 
    $body = $_REQUEST['Body'];
    preg_match("/^[\d\(\)\-\+ ]+/",$body, $matches);

    preg_match("/[^\d\(\)\-\+ ].*/",$body, $text);
    if($text[0]){
    $destination = preg_replace( '/[^0-9|+]/', '', $matches[0] );
    $saynumber = implode(' ', str_split($destination));
    $saythis = urlencode($saynumber." has sent you a text message. It reads as follows:  ".$text[0]);
    $cbUrl = 'http://raspberry.troest.com/say.php?say=';
    $completeUrl = $cbUrl.$saythis; 
   try{
	$call = $client->account->calls->create(
            '6197223236',                                 // Caller ID
            strval($destination),                          // Number to call
	    strval($completeUrl)                          // Callback
        );
	} catch (Exception $e) {
	  echo 'Error starting phone call: ' . $e->getMessage() . "\n";
	  }
    }	

    header("content-type: text/xml");
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
?>
<Response>
    <Message>Ahoy hoy <?php echo $name ?>, your message will be read to <?php echo $matches[0] ?></Message>
</Response>