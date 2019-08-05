/**
 * Sample PayPal IPN Listener implemented for Firebase Functions.
 */

const axios = require('axios');
const functions = require('firebase-functions');

/**
 * @const {boolean} sandbox Indicates if the sandbox endpoint is used.
 */
const sandbox = true;

/** Production Postback URL */
const PRODUCTION_VERIFY_URI = 'https://ipnpb.paypal.com/cgi-bin/webscr';
/** Sandbox Postback URL */
const SANDBOX_VERIFY_URI = 'https://ipnpb.sandbox.paypal.com/cgi-bin/webscr';

/**
 * Determine endpoint to post verification data to.
 *
 * @return {String}
 */
function getPaypalURI() {
  return sandbox ? SANDBOX_VERIFY_URI : PRODUCTION_VERIFY_URI;
}

/**
 * @param {Object} req Firebase Function request context for IPN notification event.
 * @param {Object} res Firebase Function response context.
 */
exports.ipnHandler = functions.https.onRequest(async (req, res) => {
  console.log('IPN Notification Event Received');

  if (req.method !== 'POST') {
    console.error('Request method not allowed.');
    res.status(405).send('Method Not Allowed');
  } else {
    // Return empty 200 response to acknowledge IPN post success.
    console.log('IPN Notification Event received successfully.');
    res.status(200).end();
  }

  // JSON object of the IPN message consisting of transaction details.
  const ipnTransactionMessage = req.body;

  // Build the body of the verification post message by prefixing 'cmd=_notify-validate'.
  const verificationBody = `cmd=_notify-validate&${req.rawBody}`;

  console.log(`Verifying IPN: ${verificationBody}`);

  const verifyResponse = await axios({
    method: 'post',
    url: getPaypalURI(),
    data: verificationBody,
  });

  if (verifyResponse.status !== 200) {
    console.log(
      `Invalid IPN: IPN message for ID: ${ipnTransactionMessage.txn_id} failed with code ${verifyResponse.status}`
    );

    return;
  }

  if (verifyResponse.data !== 'VERIFIED') {
    console.error(
      `Invalid IPN: Message for ID: ${ipnTransactionMessage.txn_id} is invalid (${verifyResponse.data}).`,
    );

    return;
  }

  console.log(
    `Verified IPN: IPN message for ID: ${ipnTransactionMessage.txn_id} was verified.`
  );

  // TODO: Implement your custom post verification logic to handle this event here
});
