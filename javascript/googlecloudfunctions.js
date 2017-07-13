/**
 * Sample PayPal IPN Listener implemented for Google Clound Functions.
 */

const querystring = require("querystring");
const request = require("request");

/**
 * @const {boolean} sandbox Indicates if the sandbox endpoint is used.
 */
const sandbox = true;

/** Production Postback URL */
const PRODUCTION_VERIFY_URI = "https://ipnpb.paypal.com/cgi-bin/webscr";
/** Sandbox Postback URL */
const SANDBOX_VERIFY_URI = "https://ipnpb.sandbox.paypal.com/cgi-bin/webscr";

/**
 * Determine endpoint to post verification data to.
 * 
 * @return {String}
 */
function getPaypalURI() {
  return sandbox ? SANDBOX_VERIFY_URI : PRODUCTION_VERIFY_URI;
}

/**
 * @param {Object} req Cloud Function request context for IPN notification event.
 * @param {Object} res Cloud Function response context.
 */
exports.ipnHandler = function ipnHandler(req, res) {
  console.log("IPN Notification Event Received");

  if (req.method !== "POST") {
    console.error("Request method not allowed.");
    res.status(405).send("Method Not Allowed");
  } else {
    // Return empty 200 response to acknowledge IPN post success.
    console.log("IPN Notification Event received successfully.");
    res.status(200).end();
  }

  // JSON object of the IPN message consisting of transaction details.
  let ipnTransactionMessage = req.body;
  // Convert JSON ipn data to a query string since Google Cloud Function does not expose raw request data.
  let formUrlEncodedBody = querystring.stringify(ipnTransactionMessage);
  // Build the body of the verification post message by prefixing 'cmd=_notify-validate'.
  let verificationBody = `cmd=_notify-validate&${formUrlEncodedBody}`;

  console.log(`Verifying IPN: ${verificationBody}`);

  let options = {
    method: "POST",
    uri: getPaypalURI(),
    body: verificationBody,
  };

  // POST verification IPN data to paypal to validate.
  request(options, function callback(error, response, body) {
    if (!error && response.statusCode == 200) {
      // Check the response body for validation results.
      if (body === "VERIFIED") {
        console.log(
          `Verified IPN: IPN message for Transaction ID: ${ipnTransactionMessage.txn_id} is verified.`
        );
        // TODO: Implement post verification logic on ipnTransactionMessage
      } else if (body === "INVALID") {
        console.error(
          `Invalid IPN: IPN message for Transaction ID: ${ipnTransactionMessage.txn_id} is invalid.`
        );
      } else {
        console.error("Unexpected reponse body.");
      }
    } else {
      // Error occured while posting to PayPal.
      console.error(error);
      console.log(body);
    }
  });
};
