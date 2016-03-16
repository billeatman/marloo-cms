<!--- re-lint all the pages for fb --->
<h1>Page Linter!</h1>

<cfquery datasource="#application.datasource#" name="qID">
	select id from mrl_sitePublic
</cfquery>

<cfloop query="qID">

<cfhttp url="%linter_url%" method="head">
</cfhttp>

<cfoutput>Page_ID: #qID.id# - #cfhttp.statuscode#</cfoutput><br />
</cfloop>

<br /><br />
Total Pages: <cfoutput>#qID.getRowCount()#</cfoutput><br />
Date: <cfoutput>#dateformat(now(), "medium")#</cfoutput><br />