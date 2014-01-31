# IPN Overview :

* PayPal Instant Payment Notification is a call back system that will get initiated once a transaction is completed(eg: When 
ExpressCheckout completed successfully).
* You will receive the transaction related IPN variables on your IPN url that you have specified in your request.
*  You have to send these IPN variables back to PayPal system for verification. Upon verification, PayPal will send
a response string with "VERIFIED" or "INVALID".
* If your server fails to respond with a successful HTTP response, PayPal will resend this IPN either until a success is received or up to 16 times.

## How to run?

* IPN Listener script samples are provided for different languages.
* Deploy IPN Listener script in Cloud environment or you can expose your server port using any third party LocalTunneling software, so that you can receive PayPal IPN call back.
* Make a PayPal API call (eg: DoDirect Payment request), setting the IpnNotificationUrl field of the API request class to the url of deployed IPN Listener script.
* You will receive IPN call back from PayPal.
    
## IPN Reference

* [Getting started guide] (https://developer.paypal.com/webapps/developer/docs/classic/ipn/integration-guide/IPNIntro/)
