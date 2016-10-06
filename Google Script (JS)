function doPost(e) {
  
  var isProduction = false;
  
  //if(typeof e == 'undefined')
    //return ContentService.createTextOutput(JSON.stringify(e.parameter));
  
  var strSimulator  = "https://www.sandbox.paypal.com/cgi-bin/webscr"
  var strLive = "https://www.paypal.com/cgi-bin/webscr"
  var paypalURL = strSimulator
  
  if (isProduction)  paypalURL = strLive;
  var payload = "cmd=_notify-validate&" + e.postData.contents;
  payload = payload.replace("+", "%2B");

  var options =
    {
      "method" : "post",
      "payload" : payload,
    };
    
  var resp = UrlFetchApp.fetch(paypalURL, options); //Handshake with PayPal - send acknowledgement and get VERIFIED or INVALID response
  
  if (resp == 'VERIFIED') {
    if (e.parameter.payment_status  == 'Completed') {
      if (e.parameter.receiver_email == 'receiver@email.com') {
        //Convert to reference currency (USD) if paid in any other currency
        var exchangeRate = 1; 
        if ((e.parameter.exchange_rate)) {
          exchangeRate = parseFloat(e.parameter.exchange_rate);
        }  
        var paidUSD = isPaymentValid(parseFloat(e.parameter.mc_gross), e.parameter.mc_currency, exchangeRate); //Convert paid amound to reference currency (USD)
        if (paidUSD == 0.0) {
          //My function returns 0.0 if product cost not found in my DB. I raise some notification here to check it out
          return false;
        }
        if (paidUSD > 0.0) {
          //All validated - can process the payment
          var processSuccess = processDownloadRequest(e);
    
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
