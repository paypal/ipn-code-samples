# IPN Overview :

* PayPal Instant Payment Notification is a call back system that will get initiated once a tranction is completed(eg: When 
ExpressCheckout completed successfully).
* you will receive the transaction related ipn variables on your call back url that you have specified in your request.
*  You have to send this ipn variable back to PayPal system for verification, Upon verification PayPal will send
a response string "VERIFIED" or "INVALID".
* PayPal will continuously resend this ipn, if a wrong ipn is sent.

## How to run?

* Ipn Listener script is provided for different language.
* Deploy IPN Listener script in Cloud environment or you can expose your server port using any third party LocalTunneling software , so that you can receive PayPal IPN call back.
* Make a PayPal api call (eg: DoDirect Payment request), setting the IpnNotificationUrl field of api request class to the url of deployed IPNListener script.
* You will receive ipn call back from PayPal.
    
## IPN Reference

* [Getting started guide] (https://developer.paypal.com/webapps/developer/docs/classic/ipn/integration-guide/IPNIntro/)
