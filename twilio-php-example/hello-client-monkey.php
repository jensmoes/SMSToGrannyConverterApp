<?php
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
$capability->allowClientOutgoing($appSid);
$capability->allowClientIncoming($clientName);
$token = $capability->generateToken();
?>

<!DOCTYPE html>
<html>
  <head>
    <title>Hello World</title>
    <script type="text/javascript"
      src="//static.twilio.com/libs/twiliojs/1.2/twilio.min.js"></script>
    <script type="text/javascript"
      src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js">
    </script>
    <link href="http://static0.twilio.com/packages/quickstart/client.css"
      type="text/css" rel="stylesheet" />
    <script type="text/javascript">

      Twilio.Device.setup("<?php echo $token; ?>");
      var connection=null;

      Twilio.Device.ready(function (device) {    
        $("#log").text("Client '<?php echo $clientName ?>' is ready");
      });

      Twilio.Device.error(function (error) {
        $("#log").text("Error: " + error.message);
      });

      Twilio.Device.connect(function (conn) {
        $("#log").text("Successfully established call");
      });

      Twilio.Device.disconnect(function (conn) {
        $("#log").text("Call ended");
	connection=null;
      });

      Twilio.Device.incoming(function (conn) {
        $("#log").text("Incoming connection from " + conn.parameters.From);
        // accept the incoming connection and start two-way audio
        conn.accept();
      });

      function call() {
        // get the phone number to connect the call to
        params = {"PhoneNumber": $("#number").val()};
	$("#log").text("Calling " + $("#number").val());
        connection = Twilio.Device.connect(params);
      }
      function hangup() {
        Twilio.Device.disconnectAll();
      }
      function any() {
      if(connection){
	connection.sendDigits('1');
	}
      }

    </script>
  </head>
  <body>
    <button class="call" onclick="call();">
      Call
    </button>
    <button class="hangup" onclick="hangup();">
      Hangup
    </button>

    <button class="call" onclick="any();">
      Any Key
    </button>
    <input type="text" id="number" name="number"
      placeholder="Enter a phone number or name to call"/>

    <div id="log">Loading pigeons...</div>
  </body>
</html>