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

<cfset hisDate = '01-01-2015'>

<cfquery datasource="#application.datasource#" name="qHistory">
	select * from (
		select usedDate, id, idHistory, title, 'current' as [type]
		from mrl_siteHistory 
		where usedDate >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#hisDate#">
		and state = 'approved'

		<!--- UNION

		select (
			select top 1 usedDate 
			from mrl_siteHistory as sa
			where sa.idHistory = mrl_siteAdmin.idHistory
		) as [usedDate], id, idHistory, title, 'old' as [type]
		from mrl_siteAdmin
		where id not in (
			select distinct id
			from mrl_siteHistory 
			where usedDate >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#hisDate#">
		) and approvedDate is not null --->

		UNION

		select [datetime] as usedDate, id, (
			select top 1 idHistory
			from mrl_siteHistory 
			where id = pm.id
			and usedDate < pm.[datetime]
			order by usedDate desc
		), '' as title, 'pagemove' as [type]
		from mrl_pageMoveLog as pm
		where [datetime] >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#hisDate#">
		and oldParent <> newParent
	) as pm
	order by usedDate asc
</cfquery>

<cfset dispInterval = int(qHistory.recordcount / 100)>

<cfset root_id = 0>

<cfset i = 0>
<cfloop query="qHistory">
	<cfset t2 = getTickCount()>
	<cfset i = i + 1>  

	<cfif debug neq true>
	    <cfthread action="run" name="t#i#" history_id="#qHistory.idHistory#" usedDate="#qHistory.usedDate#" type="#qHistory.type#"> 
	        <cfinvoke component="redirectso" method="addHistoryId">
	        	<cfinvokeargument name="history_id" value="#history_id#">
		        <cfinvokeargument name="date" value="#usedDate#">
		       	<cfinvokeargument name="type" value="#type#">
	        </cfinvoke>
	    </cfthread>
	    
	    <cfthread action="join" name="t#i#" timeout="600000" />       
	    <cfthread action="terminate" name="t#i#" />       
	<cfelse>
		<cfinvoke component="redirectso" method="addHistoryId">
	       	<cfinvokeargument name="history_id" value="#qHistory.idHistory#">
	       	<cfinvokeargument name="date" value="#qHistory.usedDate#">
	       	<cfinvokeargument name="type" value="#qHistory.type#">
	    </cfinvoke>
	</cfif>
	
	<cfif debug neq true AND i mod 2 eq 1>
		<script language="javaScript">
	    loadingBlock = document.getElementById('loading');
	    loadingBlock.innerHTML = '<cfoutput>history_id: #qHistory.idHistory#, #getTickCount() - t2# ms</cfoutput>';
	    document.getElementById('percent').innerHTML = '<cfoutput>#int((100 / qHistory.recordCount) * i)#%</cfoutput>';
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
<h2>Done! #tt# ms, #tt / qHistory.recordCount# ms/rev</h2>
</cfoutput>

</body>
</html>

