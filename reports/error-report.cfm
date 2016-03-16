<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Error Log</title>
<style>
.main{
	font-family:"Courier New", Courier, monospace;
	font-size:12px;
}
</style>
</head>

<body class="main">
<cfquery datasource="#application.datasource#" name="qErrorLogs">
	select * from mrl_errorLog
	order by dateTime desc
</cfquery> 

<table>
	<thead>
		<th>Exception Date</th>
		<th>Error</th>
	</thead>
<cfloop query="qErrorLogs">
	<cfoutput>
	<tr>
		<td style="padding: 15px;">#dateformat(qErrorLogs.datetime)# - #TimeFormat(qErrorLogs.datetime)#</td>
		<td>#qErrorLogs.message#<br />#qErrorLogs.detail#</td>		
	</tr>
	</cfoutput>
</cfloop>
</table>

</body>
</html>