<!--- read post from PayPal --->
<!--- if you find that the body gets corrupted, first call getHTTPRequestData( false ), then call again without false ---> 
<cfset requestData = getHTTPRequestData() />

<!--- add 'cmd' and post back to PayPal system to validate --->
<cfhttp url="https://ipnpb.paypal.com/cgi-bin/webscr?cmd=_notify-validate&#requestData.content#" >
	<cfhttpparam type="header" name="Host" value="ipnpb.paypal.com"> 
</cfhttp>

<!--- if form.fieldnames is defined, we have a good post --->
<cfif isdefined("form.fieldNames")>
	<!--- I want to capture what PayPal send back from the CFHTTP get. It will be VERIFIED or INVALID so I add a new field --->
	<!--- If you get a lot of INVALID yoiu should try the CFHTTP wih &#URLEncodedFormat(requestData.content)#" --->  
	<cfset myFields = "return_status" />
	<cfset myValues="'#cfhttp.FileContent#'" />
	<!--- I wwant to capture all the formfields and the data so I never have to worry about the table missing a field. --->
	<!--- I use the two strings I created to save the fieldnames and the data --->
	<cfset theValue = '' />
	<cfset theValueAlert = '' />
	<cfloop list="#form.fieldNames#" index="i">
		<cfset myFields = myFields & "," & #lcase(i)# />
		<!--- check the length of the value because I set the varchar fields to 50 --->
		<cfif Len(form[i]) gt 50>
			<cfset theValue = Left(form[i], 50) />
			<!--- I want to know if a field was over 50 characters so this will be added to the email to myself--->
			<cfset theValueAlert = theValueAlert & lcase(i) & ' = ' & form[i] & '<br />' />
		<cfelse>
			<cfset theValue = form[i] />
		</cfif>

		<cfset myValues = myValues & ",'" & #theValue# & "'"/>
	</cfloop>
	<!--- Now an easy way to get just the columns from MySQL so I can check against the fieldnames from PayPal --->
	<cfquery name="columns" datasource="data">
		SELECT
			*
		FROM
			paypal
		WHERE
			id = 0
	</cfquery>	
	<!--- Put the fieldnames from MySQL into a list --->
	<cfset colList = columns.columnList />
	<!--- Now loop through the fieldnames from PayPay and see if the same fieldnames are in MySQL --->
	<cfloop list="#myFields#" index="name" delimiters=",">
		<cfset aa = ListContainsNoCase(colList, name, ',') />
		<!--- If a fieldname is missing, add it to MySQL and move on --->
		<!--- You can optimize the field size and tpyes later --->
		<cfif aa eq 0>
			<cfquery name="alt" datasource="data">
				ALTER TABLE 
					paypal 
				ADD 
					#name# varchar(50) NULL
			</cfquery>
		</cfif>
	</cfloop>
	<!--- Now all the data is inserted into the table --->
	<cfquery name='i' datasource='data'>
		INSERT INTO
			paypal
			(#myFields#)
		VALUES
			(#PreserveSingleQuotes(myValues)#)
	</cfquery>

	<!--- here is where yoiu do YOUR processing to verify the purchase and send an email to the customer --->

	<cfmail
		to = "#customer.email#"
		from = "Your Shop Name <support@domain.com>"
		subject = "WSebsite Purchase"
		server = "#application.mailserver#" 
		type="html">
		#mailText#
	</cfmail>
			
</cfif>

<!--- To be on the same side, I send an email to myself with the data from PayPal in case there is an error. --->
<!--- You will want to do some checking and turn this off if you are not having any issues. --->

<!--- #CFHTTP.FileContent# will be VERIFIED or INVALID so you may want to limit it to INVALID. --->
<!--- requestData.content is the RAW data sent from PayPal so you can examine it. --->
<!--- I have it send the myFields and myValues so it's easy to paste into a SQL statment for testing. --->

<!--- I hope you all find this useful --->
<cfmail
	to = "your.email@domain.com"
	from = "Your Website <support@domain.com>"
	subject = "#CFHTTP.FileContent#" 
	server = "#application.mailserver#" 
	type="html">
	<cfif isdefined("form.fieldNames")>
		<cfloop list="#form.fieldNames#" index="i">
		#lcase(i)# = #form[i]#<br />
		</cfloop>
	</cfif>
	<br />
	<br />
	#requestData.content#<br /><br />
	#theValueAlert#<br /><br />
	#myFields#<br /><br />
	#myValues#<br /><br />
</cfmail>
