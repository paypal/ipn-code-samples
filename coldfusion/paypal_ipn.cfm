<cfparam name="paypalIpnUrl" default="https://ipnpb.paypal.com/cgi-bin/webscr" />
<cfset isTest = true />
<cfif isTest>
  <cfset paypalIpnUrl = "https://ipnpb.sandbox.paypal.com/cgi-bin/webscr" />
</cfif>

<!--- read post from PayPal system --->
<cfset requestData=getHTTPRequestData() />
<!--- Test Output --->
<cffile action="write" file="#expandPath('./request_data.txt')#" output="#URLEncodedFormat(requestData.content)#" />

<!--- add 'cmd' and post back to PayPal system to validate --->
<cfhttp url="#paypalIpnUrl#?cmd=_notify-validate&#requestData.content#">
  <cfhttpparam type="header" name="Host" value="www.paypal.com" />
</cfhttp>


<!--- check notification validation --->
<cfif CFHTTP.FileContent is "VERIFIED">
  
  <!--- assign posted variables to local variables --->
  <cfif IsDefined("FORM.item_name")>
    <cfset item_name=FORM.item_name />
  </cfif>
  <!--- check that payment_status=Completed --->
  <cfif IsDefined("FORM.payment_status")>
    <cfset payment_status=FORM.payment_status />
  </cfif>
  <cfif IsDefined("FORM.mc_gross")>
    <cfset payment_amount=FORM.mc_gross />
  </cfif>
  <!--- check that payment_amount/payment_currency are correct --->
  <cfif IsDefined("FORM.mc_currency")>
    <cfset payment_currency=FORM.mc_currency />
  </cfif>
  <cfif IsDefined("FORM.txn_id")>
    <cfset txn_id=FORM.txn_id />
  </cfif>
  <!--- check that txn_id has not been previously processed --->
  <!--- check that receiver_email is your Primary PayPal email --->
  <cfif IsDefined("FORM.receiver_email")>
    <!--- IMPORTANT!!! The sandbox version of IPN Simulator does not encode the email.
    When you switch to production, it does! You need to decode the email address if you 
    are to validate it in a production setting.) --->
    <cfset receiver_email=URLDecode(FORM.receiver_email) />
  </cfif>
  <cfif IsDefined("FORM.payer_email")>
    <cfset payer_email=FORM.payer_email />
  </cfif>
  <cfif IsDefined("FORM.item_number")>
    <cfset item_number=FORM.item_number />
  </cfif>
  <!--- Test Output --->
  <cffile action="append" file="#expandPath('./valid_log.txt')#" output="#now()#-#CFHTTP.FileContent#" />
<cfelseif CFHTTP.FileContent is "INVALID">
   <!--- log for investigation --->
   <cffile action="append" file="#expandPath('./invalid_log.txt')#" output="#now()#-#CFHTTP.FileContent#" />
<cfelse>
  <!--- error --->
  <!--- Test Output --->
  <cffile action="append" file="#expandPath('./error_log.txt')#" output="#now()#-#CFHTTP.FileContent#" />
</cfif>
