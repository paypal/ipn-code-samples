function doPost(e) {
  var isProduction = false;
  
  var strSimulator  = "https://www.sandbox.paypal.com/cgi-bin/webscr";
  var strLive = "https://www.paypal.com/cgi-bin/webscr";
  var paypalURL = strSimulator;
  
  if (isProduction)  paypalURL = strLive;
  
  var payload = "cmd=_notify-validate&" + e.postData.contents;

  var options =
    {
      "method" : "post",
      "payload" : payload,
    };
    
  var resp = UrlFetchApp.fetch(paypalURL, options); //Handshake with PayPal - send acknowledgement and get VERIFIED or INVALID response
  
  if (resp == 'VERIFIED') {
    if (e.parameter.payment_status  == 'Completed') {
      if (e.parameter.receiver_email == 'receiver@email.com') {
        //Implement paid amount validation. If accepting payments in multiple currencies, use e.parameter.exchange_rate to convert to reference currency (USD) if paid in any other currency
        if (amountValid) {
        
          //All validated - can process the payment here

          if (!(processSuccess)) {
            //Process of payment failed - raise notification to check it out
          }
        } else {
          //Payment does not equal expected purchase value
        }
      } else {
       //Request did not originate from my PayPal account 
      }
    } else {
     //Payment status not Completed 
    }
  } else
  {
   //PayPal response INVALID 
  }
}
