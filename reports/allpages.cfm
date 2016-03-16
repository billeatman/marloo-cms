<cfparam name="reportType" default="VISIBLE"> <!--- Options - VISIBLE, HIDDEN, DELETED --->
<!--- All pages report --->
<!--- Author: William Eatman --->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<cfswitch expression="#reportType#">
<cfcase value="VISIBLE">
<cfset mytitle = 'Visible'>
</cfcase>
<cfcase value="HIDDEN">
<cfset mytitle = 'Hidden'>
</cfcase>
<cfcase value="DELETED">
<cfset mytitle = 'Deleted'>
</cfcase>
<cfcase value="PENDING">
<cfset mytitle = 'Pending Approval'>
</cfcase>
<cfcase value="APPS">
<cfset mytitle = 'Application Pages'>
</cfcase>
</cfswitch>

<title><cfoutput>#mytitle# #application.pagedesc#</cfoutput>s</title>
<style>
.main{
	font-family:"Courier New", Courier, monospace;
	font-size:12px;
}
</style>
</head>
<body class="main">

<CFIF NOT isDefined("SESSION.Auth.groups.toplevel")>
  <cflocation url="search.cfm" >
</CFIF>

<cfquery datasource="#application.datasource#" name="queryAllPages">
<cfswitch expression="#reportType#">
<cfcase value="VISIBLE">
SELECT id, title, modifiedDate, modifiedBy, gModifiedDate, gModifiedBy, submittedBy, submittedDate FROM mrl_sitePublic
ORDER BY submittedDate DESC
</cfcase>
<cfcase value="HIDDEN">
SELECT id, title, modifiedDate, modifiedBy, gModifiedDate, gModifiedBy, submittedBy, submittedDate FROM mrl_siteAdmin 
WHERE (deleted = 'F' or deleted IS NULL) AND (visible = 'F')
ORDER BY modifiedDate DESC
</cfcase>
<cfcase value="DELETED">
SELECT id, title, modifiedDate, modifiedBy, gModifiedDate, gModifiedBy, submittedBy, submittedDate FROM mrl_siteAdmin 
WHERE (deleted = 'T' or deleted IS NULL)
ORDER BY gModifiedDate DESC
</cfcase>
<cfcase value="PENDING">
<!--- this query gives us the correct submitted dates for non-approved pages
	This could be cleaned up with a join to the action table
 --->
SELECT id, title, modifiedDate, modifiedBy, gModifiedDate, gModifiedBy, (SELECT TOP (1) actionBy FROM mrl_pageState
WHERE (id = mrl_siteAdmin.id) AND ([action] = 'pending') ORDER BY actionDate desc) as submittedBy, (SELECT TOP (1) actionDate FROM mrl_pageState
WHERE (id = mrl_siteAdmin.id) AND ([action] = 'pending') ORDER BY actionDate desc) as submittedDate
FROM mrl_siteAdmin
WHERE (deleted = 'F' or deleted IS NULL) AND (state = 'pending')
ORDER BY submittedDate DESC  
</cfcase>
<cfcase value="APPS">
SELECT id, title, modifiedDate, modifiedBy, gModifiedDate, gModifiedBy, submittedBy, submittedDate FROM mrl_sitePublic
WHERE (app != '') AND (app IS NOT NULL)
ORDER BY submittedDate DESC
</cfcase>
</cfswitch>
</cfquery>


<SCRIPT LANGUAGE="JavaScript"> 
// This script was supplied free by Hypergurl 
// http://www.hypergurl.com 
<!-- hide script and begin 
if (window.print) { 
	document.write('<form><input type=button name=print value="Print"' + 'onClick="javascript:window.print()">&nbsp;&nbsp;<strong>Total <cfoutput>#mytitle# #application.pagedesc#</cfoutput>s: <cfoutput>#queryAllPages.getRowCount()#</cfoutput></strong></form>'); 
} 
// End hide --> 
</script>


<table cellpadding="2px">
<thead>
<th>
<cfoutput>#application.pagedesc# #application.idname#</cfoutput>
</th>
<th>
Title
</th>
<th>
<cfif reportType eq "DELETED" or reportType eq "HIDDEN">
Modified Date
<cfelse>
Submitted Date
</cfif>
</th>
<th>
<cfif reportType eq "DELETED" or reportType eq "HIDDEN">
Modified By
<cfelse>
Submitted By
</cfif>
</th>
</thead>

<cfoutput query="queryAllPages">
<tr>
<td>
#id#
</td>
<td>
<cfswitch expression="#reportType#">
<cfcase value="VISIBLE">
<a href="#application.web.siteroot##application.pagename#?#application.idvar#=#ID#">#title#</a>
</cfcase>
<cfcase value="PENDING">
<a href="##" onclick="top.pageEdit('#id#', 'pending'); return false;">#title#</a>
</cfcase>
<cfdefaultcase>
<a href="##" onclick="top.pageEdit('#id#'); return false;">#title#</a>
</cfdefaultcase>
</cfswitch>
</td>
<td>
<cfif reportType eq "DELETED" or reportType eq "HIDDEN">
#dateformat(gModifiedDate)#
<cfelse>
	<cfif reportType eq "PENDING">
 		#dateformat(submittedDate)# - #TimeFormat(submittedDate)#
    <cfelse>
    	#dateformat(submittedDate)#
    </cfif>
</cfif>
</td>
<td>
<cfif reportType eq "DELETED" or reportType eq "HIDDEN">
#gModifiedBy#
<cfelse>
#submittedBy#
</cfif>
</td>
</tr>
</cfoutput>
</table>
</body>
</html>
