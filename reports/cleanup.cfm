<!--- clean up database --->
<cfparam name="url.removeCache" default="false">
<cfparam name="url.removeLogs" default="false">
<cfparam name="url.removePreviews" default="false">

<cfif url.removeCache EQ true>
	<cfquery datasource="#application.datasource#">
		delete from mrl_dataCache
		where [dateTime] < <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd("m", -6, now())#">
	</cfquery>	
</cfif>

<cfif url.removeLogs EQ true>
	<cfquery datasource="#application.datasource#">
		delete from mrl_errorLog
		where [dateTime] < <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd("m", -6, now())#">
	</cfquery>	
</cfif>

<cfif url.removePreviews EQ true>
	<cfquery datasource="#application.datasource#">
		delete from mrl_pageState 
		where action = 'preview' and [actionDate] < <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd("m", -6, now())#">

		delete from mrl_pageRevision 
		where state = 'preview' and [modifiedDate] < <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd("m", -6, now())#">
	</cfquery>
</cfif>

<!--- Site Cache --->
<cfquery datasource="#application.datasource#" name="qDataCacheAll">
	select count(*) as count from mrl_dataCache 
</cfquery>

<cfquery datasource="#application.datasource#" name="qDataCacheMonth">
	select count(*) as count from mrl_dataCache 
	where [dateTime] < <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd("m", -6, now())#">
</cfquery>

<!--- Error Logs --->
<cfquery datasource="#application.datasource#" name="qErrorLogAll">
	select count(*) as count from mrl_errorLog 
</cfquery>

<cfquery datasource="#application.datasource#" name="qErrorLogMonth">
	select count(*) as count from mrl_errorLog 
	where [dateTime] < <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd("m", -6, now())#">
</cfquery>

<!--- Preview Pages --->
<cfquery datasource="#application.datasource#" name="qPreviewAll">
	select count(*) as count from mrl_pageRevision
	where state = 'preview' 
</cfquery>

<cfquery datasource="#application.datasource#" name="qPreviewMonth">
	select count(*) as count from mrl_pageRevision
	where state = 'preview' and [modifiedDate] < <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd("m", -6, now())#">
</cfquery>


<h1>Database Cleanup</h1>

<cfoutput>
<h2>DB Site Cache</h2>
Total Records:  #qDataCacheAll.count#<br />
Older Than 6 Month:  #qDataCacheMonth.count#<br />
<a href="cleanup.cfm?removeCache=true">Clean</a><br />

<h2>DB Error Log</h2>
Total Records:  #qErrorLogAll.count#<br />
Older Than 6 Month:  #qErrorLogMonth.count#<br />
<a href="cleanup.cfm?removeLogs=true">Clean</a><br />

<h2>DB Preview Views</h2>
Total Records:  #qPreviewAll.count#<br />
Older Than 6 Month:  #qPreviewMonth.count#<br />
<a href="cleanup.cfm?removePreviews=true">Clean</a><br />

</cfoutput>
