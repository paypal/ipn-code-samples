' ASP .NET/VBScript (requires MSXML)

<%@LANGUAGE="VBScript"%>
<%
Dim Item_name, Item_number, Payment_status, Payment_amount
Dim Txn_id, Receiver_email, Payer_email
Dim objHttp, str

' read post from PayPal system and add 'cmd'
str = Request.Form & "&cmd=_notify-validate"

' post back to PayPal system to validate
set objHttp = Server.CreateObject("Msxml2.ServerXMLHTTP")
' set objHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.4.0")
' set objHttp = Server.CreateObject("Microsoft.XMLHTTP")
objHttp.open "POST", "https://www.paypal.com/cgi-bin/webscr", false
objHttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
objHttp.Send str

' assign posted variables to local variables
Item_name = Request.Form("item_name")
Item_number = Request.Form("item_number")
Payment_status = Request.Form("payment_status")
Payment_amount = Request.Form("mc_gross")
Payment_currency = Request.Form("mc_currency")
Txn_id = Request.Form("txn_id")
Receiver_email = Request.Form("receiver_email")
Payer_email = Request.Form("payer_email")

' Check notification validation
if (objHttp.status <> 200 ) then
' HTTP error handling
elseif (objHttp.responseText = "VERIFIED") then
' check that Payment_status=Completed
' check that Txn_id has not been previously processed
' check that Receiver_email is your Primary PayPal email
' check that Payment_amount/Payment_currency are correct
' process payment
elseif (objHttp.responseText = "INVALID") then
' log for manual investigation
else
' error
end if
set objHttp = nothing
%>
