<?php namespace Listener;

// Set this to true to use the sandbox endpoint during testing:
$enable_sandbox = true;

// Use this to specify all of the email addresses that you have attached to paypal:
$my_email_addresses = array("my_email_address@gmail.com", "my_email_address2@gmail.com", "my_email_address3@gmail.com");

// Set this to true to send a confirmation email:
$send_confirmation_email = true;
$confirmation_email_name = "My Name";
$confirmation_email_address = "my_email_address@gmail.com";
$from_email_name = "My Name";
$from_email_address = "my_email_address@gmail.com";

// Set this to true to save a log file:
$save_log_file = true;
$log_file_dir = __DIR__ . "/logs";

// Here is some information on how to configure sendmail:
// http://php.net/manual/en/function.mail.php#118210



require("PaypalIPN.php");
use PaypalIPN;
$ipn = new PaypalIPN();
if ($enable_sandbox) {
    $ipn->useSandbox();
}
$verified = $ipn->verifyIPN();

if (is_array($verified)) {
    $DATA = $verified;
} else {
    $DATA = $_POST;
}

$data_text = "";
foreach ($DATA as $key => $value) {
    $data_text .= $key . " = " . $value . "\r\n";
}

$test_text = "";
if ($DATA["test_ipn"] == 1) {
    $test_text = "Test ";
}

// Check the receiver email to see if it matches your list of paypal email addresses
$receiver_email_found = false;
foreach ($my_email_addresses as $a) {
    if (strtolower($DATA["receiver_email"]) == strtolower($a)) {
        $receiver_email_found = true;
        break;
    }
}

date_default_timezone_set("America/Los_Angeles");
list($year, $month, $day, $hour, $minute, $second, $timezone) = explode(":", date("Y:m:d:H:i:s:T"));
$date = $year . "-" . $month . "-" . $day;
$timestamp = $date . " " . $hour . ":" . $minute . ":" . $second . " " . $timezone;
$dated_log_file_dir = $log_file_dir . "/" . $year . "/" . $month;

function send_email($name = "", $address = null, $subject = "", $body = "", $from_name = null, $from_address = null, $html = true) {
    if (is_null($address)) {
        return false;
    }
    if (is_null($from_name)) {
        $from_name = $GLOBALS["from_email_name"];
    }
    if (is_null($from_address)) {
        $from_address = $GLOBALS["from_email_address"];
    }
    $send_email_to = "=?UTF-8?B?" . base64_encode($name) . "?= <" . $address . ">";
    $send_email_header  = "MIME-Version: 1.0" . "\r\n";
    if ($html) {
        $body = "<html><head><title>" . $subject . "</title></head><body>" . $body . "</body></html>";
        $send_email_header .= "Content-type: text/html; charset=UTF-8" . "\r\n";
    } else {
        $send_email_header .= "Content-type: text/plain; charset=UTF-8" . "\r\n";
    }
    $send_email_header .= "To: " . $send_email_to . "\r\n";
    $send_email_header .= "From: " . "=?UTF-8?B?" . base64_encode($from_name) . "?= <" . $from_address . ">" . "\r\n";
    return mail($send_email_to, "=?UTF-8?B?" . base64_encode($subject) . "?=", $body, $send_email_header);
}

function send_plain_email($name = "", $address = null, $subject = "", $body = "", $from_name = null, $from_address = null, $html = false) {
    return send_email($name, $address, $subject, $body, $from_name, $from_address, $html);
}

$paypal_ipn_status = "VERIFICATION FAILED";
if ($verified) {
    $paypal_ipn_status = "RECEIVER EMAIL MISMATCH";
    if ($receiver_email_found) {
        $paypal_ipn_status = "Completed Successfully";


        // Process IPN
        // A list of variables are available here:
        // https://developer.paypal.com/webapps/developer/docs/classic/ipn/integration-guide/IPNandPDTVariables/

        // This is an example for sending an automated email to the customer when they purchases an item for a specific amount:
        if ($DATA["item_name"] == "Example Item" && $DATA["mc_gross"] == 49.99 && $DATA["mc_currency"] == "USD" && $DATA["payment_status"] == "Completed") {
            $email_name = $DATA["first_name"] . " " . $DATA["last_name"];
            $email_address = $DATA["payer_email"];
            $email_subject = $test_text . "Completed order for: " . $DATA["item_name"];
            $email_body = "<p>Thank you for purchasing " . $DATA["item_name"] . ".<BR><BR>This is an example email only.<BR><BR>Thank you.</p>";
            send_email($email_name, $email_address, $email_subject, $email_body);
        }


    }
} elseif ($enable_sandbox) {
    if ($DATA["test_ipn"] != 1) {
        $paypal_ipn_status = "RECEIVED FROM LIVE WHILE SANDBOXED";
    }
} elseif ($DATA["test_ipn"] == 1) {
    $paypal_ipn_status = "RECEIVED FROM SANDBOX WHILE LIVE";
}

if ($save_log_file) {
    // Create log file directory
    if (!is_dir($dated_log_file_dir)) {
        if (!file_exists($dated_log_file_dir)) {
            mkdir($dated_log_file_dir, 0777, true);
            if (!is_dir($dated_log_file_dir)) {
                $save_log_file = false;
            }
        } else {
            $save_log_file = false;
        }
    }
    // Restrict web access to files in the log file directory
    $htaccess_body = "RewriteEngine On" . "\r\n" . "RewriteRule .* - [L,R=404]";
    if ($save_log_file && (!is_file($log_file_dir . "/.htaccess") || file_get_contents($log_file_dir . "/.htaccess") !== $htaccess_body)) {
        if (!is_dir($log_file_dir . "/.htaccess")) {
            file_put_contents($log_file_dir . "/.htaccess", $htaccess_body);
            if (!is_file($log_file_dir . "/.htaccess") || file_get_contents($log_file_dir . "/.htaccess") !== $htaccess_body) {
                $save_log_file = false;
            }
        } else {
            $save_log_file = false;
        }
    }
    if ($save_log_file) {
        // Save data to text file
        file_put_contents($dated_log_file_dir . "/" . $test_text . "paypal_ipn_" . $date . ".txt", "paypal_ipn_status = " . $paypal_ipn_status . "\r\n" . "paypal_ipn_date = " . $timestamp . "\r\n" . $data_text . "\r\n", FILE_APPEND);
    }
}

if ($send_confirmation_email) {
    // Send confirmation email
    $email_name = $confirmation_email_name;
    $email_address = $confirmation_email_address;
    $email_subject = $test_text . "PayPal IPN : " . $paypal_ipn_status;
    $email_body = "paypal_ipn_status = " . $paypal_ipn_status . "\r\n" . "paypal_ipn_date = " . $timestamp . "\r\n" . $data_text;
    send_plain_email($email_name, $email_address, $email_subject, $email_body);
}

// Reply with an empty 200 response to indicate to paypal the IPN was received correctly
header("HTTP/1.1 200 OK");
