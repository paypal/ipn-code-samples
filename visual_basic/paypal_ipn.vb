' ASP.NET VB

Imports System.Net
Imports System.IO

Partial Class vbIPNexample
Inherits System.Web.UI.Page

Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
'Post back to either sandbox or live
Dim strSandbox As String = "https://www.sandbox.paypal.com/cgi-bin/webscr"
Dim strLive As String = "https://www.paypal.com/cgi-bin/webscr"
Dim req As HttpWebRequest = CType(WebRequest.Create(strSandbox), HttpWebRequest)

'Set values for the request back
req.Method = "POST"
req.ContentType = "application/x-www-form-urlencoded"
Dim Param() As Byte = Request.BinaryRead(HttpContext.Current.Request.ContentLength)
Dim strRequest As String = Encoding.ASCII.GetString(Param)
strRequest = strRequest + "&cmd=_notify-validate"
req.ContentLength = strRequest.Length

'for proxy
'Dim proxy As New WebProxy(New System.Uri("http://url:port#"))
'req.Proxy = proxy

'Send the request to PayPal and get the response
Dim streamOut As StreamWriter = New StreamWriter(req.GetRequestStream(), Encoding.ASCII)
streamOut.Write(strRequest)
streamOut.Close()
Dim streamIn As StreamReader = New StreamReader(req.GetResponse().GetResponseStream())
Dim strResponse As String = streamIn.ReadToEnd()
streamIn.Close()

If strResponse = "VERIFIED" Then
'check the payment_status is Completed
'check that txn_id has not been previously processed
'check that receiver_email is your Primary PayPal email
'check that payment_amount/payment_currency are correct
'process payment
ElseIf strResponse = "INVALID" Then
'log for manual investigation
Else
'Response wasn't VERIFIED or INVALID, log for manual investigation
End If
End Sub
End Class
