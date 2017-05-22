<?php namespace Listener;

require('PaypalIPN.php');

use PaypalIPN;

$ipn = new PaypalIPN();

// Use the sandbox endpoint during testing.
$ipn->useSandbox();
$verified = $ipn->verifyIPN();

// Reply with an empty 200 response to indicate to paypal the IPN was received correctly.
// Reply as soon as possible to keep Paypal from sending more POSTs than nescessary
header("HTTP/1.1 200 OK");

if ($verified) {
    /*
     * Process IPN
     * A list of variables is available here:
     * https://developer.paypal.com/webapps/developer/docs/classic/ipn/integration-guide/IPNandPDTVariables/
     */
}
