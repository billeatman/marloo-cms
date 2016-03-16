<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>

<cfset debug = false>

<cfif debug neq true>
<style>
	body {
		font: "Courier New", Courier, monospace;
		font-family:"Courier New", Courier, monospace;
		background: #006;
		color: #CCC;
	}
</style>
</cfif>

</head>

<body>

<cfif debug neq true>
<strong>Working...  </strong><span id="percent"></span><br />
<p id="loading">
<cfoutput>#repeatString(" ", 250)#</cfoutput>
</p>
</cfif>
<cfflush>

<cfsetting requesttimeout="200000">

<cfset maxcount = 20>
<cfset t1 = getTickCount()>

<!---
<cfquery datasource="#application.datasource#" name="qPages">
	select * from (
		select modifiedDate as usedDate, id, idHistory, title, 'current' as [type]
		from mrl_siteAdmin

		UNION

		select [datetime] as usedDate, id, (
			select top 1 idHistory
			from mrl_siteHistory 
			where id = pm.id
			and usedDate < pm.[datetime]
			order by usedDate desc
		), '' as title, 'pagemove' as [type]
		from mrl_pageMoveLog as pm
		where oldParent != newParent
	) as pm
	order by usedDate asc
</cfquery>
--->

<cfquery datasource="#application.datasource#" name="qPages">
	select modifiedDate as usedDate, id, idHistory, title, 'current' as [type]
	from mrl_sitePublic where deleted = 'F'
	order by usedDate asc
</cfquery>


<!---
<cfquery datasource="#application.datasource#" name="qPages">
	select id, (select top 1 usedDate from mrl_siteHistory where id = mrl_siteAdmin.id order by usedDate desc) as usedDate
    from mrl_siteAdmin
    order by usedDate asc
</cfquery>
--->

<cfset dispInterval = int(qPages.recordcount / 100)>

<cfset i = 0>
<cfloop query="qPages">
	<cfset t2 = getTickCount()>
	<cfset i = i + 1>  

	<cfif debug neq true>
	    <cfthread action="run" name="t#i#" page_id="#qPages.id#"> 
	        <cfinvoke component="redirects" method="optimizeID">
	        	<cfinvokeargument name="page_id" value="#page_id#">
	        	<cfinvokeargument name="ignore_subs" value="#true#">
	        </cfinvoke>
	    </cfthread>
	    
	    <cfthread action="join" name="t#i#" timeout="600000" />       
	    <cfthread action="terminate" name="t#i#" />       
	<cfelse>
		<cfinvoke component="redirects" method="optimizeID">
	       	<cfinvokeargument name="page_id" value="#qPages.id#">
        	<cfinvokeargument name="ignore_subs" value="#true#">
	    </cfinvoke>
	</cfif>.
	
	<cfif debug neq true AND i mod 2 eq 1>
		<script language="javaScript">
	    loadingBlock = document.getElementById('loading');
	    loadingBlock.innerHTML = '<cfoutput>page_id: #qPages.id#, #getTickCount() - t2# ms</cfoutput>';
	    document.getElementById('percent').innerHTML = '<cfoutput>#int((100 / qPages.recordCount) * i)#%</cfoutput>';
	    </script>
		<cfflush>
 	</cfif> 
</cfloop>

<cfif debug neq true>
	<script language="javaScript">
	document.getElementById('percent').innerHTML = '100%';
	</script>
</cfif>

<cfset tt = getTickCount() - t1>

<cfoutput>
<h2>Done! #tt# ms, #tt / qPages.recordCount# ms/rev</h2>
</cfoutput>

</body>
</html>

