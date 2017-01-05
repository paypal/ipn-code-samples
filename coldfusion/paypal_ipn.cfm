<!--- COLDFUSION   --->

<!--- read post from PayPal system --->
<CFSET requestData = getHTTPRequestData() />

<!--- add 'cmd' and post back to PayPal system to validate --->
<CFHTTP url="https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate&#URLEncodedFormat(requestData.content)#" >
	<cfhttpparam type="header"  name="Host" value="www.paypal.com"> 
</CFHTTP>

 
<!--- check notification validation --->
<CFIF #CFHTTP.FileContent# is "VERIFIED">
    <!--- assign posted variables to local variables --->
    <CFIF IsDefined("FORM.item_name")>
        <CFSET item_name=FORM.item_name>
    </CFIF>    
    <!--- check that payment_status=Completed --->
    <CFIF IsDefined("FORM.payment_status")>
        <CFSET payment_status=FORM.payment_status>
    </CFIF>    
    <CFIF IsDefined("FORM.mc_gross")>
        <CFSET payment_amount=FORM.mc_gross>
    </CFIF> 
    <!--- check that payment_amount/payment_currency are correct --->
    <CFIF IsDefined("FORM.mc_currency")>
        <CFSET payment_currency=FORM.mc_currency>
    </CFIF>        
    <CFIF IsDefined("FORM.txn_id")>
        <CFSET txn_id=FORM.txn_id>
    </CFIF>
    <!--- check that txn_id has not been previously processed --->
    <!--- check that receiver_email is your Primary PayPal email --->	
    <CFIF IsDefined("FORM.receiver_email")>
        <CFSET receiver_email=FORM.receiver_email>
    </CFIF>        
    <CFIF IsDefined("FORM.payer_email")>
        <CFSET payer_email=FORM.payer_email>
    </CFIF>    
    <CFIF IsDefined("FORM.item_number")>
		<CFSET item_number=FORM.item_number>
    </CFIF>
	
<CFELSEIF #CFHTTP.FileContent# is "INVALID">
	<!--- log for investigation --->
<CFELSE>	
	<!--- error --->
</CFIF>
