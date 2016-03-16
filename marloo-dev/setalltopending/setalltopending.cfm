Sets all pages to pending!<br />
There is a cfabort below this line that will need to be remarked out. DO NOT RUN THIS UNLESS YOU KNOW WHAT YOU ARE DOING!!!!!!!!
<cfabort>
<!--- walk the site --->
<cfquery datasource="#application.datasource#" name="qPages">
select * from mrl_siteAdmin where state = 'approved' and deleted = 'F'
</cfquery>

<cfdump var="#qPages#" expand="no">

<cfloop query="qPages">
	<!--- set 'approved' to 'pending' in mrl_page --->
    <cfquery datasource="#application.datasource#">
    update mrl_page
    set state = 'pending' 
    where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qPages.id#">
    </cfquery>
    
    <!--- set 'approved' to 'pending' in the history table --->
    <cfquery datasource="#application.datasource#">
    update mrl_pageRevision
    set state = 'pending' 
    where idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#qPages.idHistory#">
    </cfquery>
    
    <!--- create row in the action table --->
    <cfquery datasource="#application.datasource#">
    insert into mrl_pageState (action, actionBy, actionDate, idHistory, id) 
    values ('pending', 'user@example.com', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#qPages.idHistory#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#qPages.id#">)
    </cfquery>
</cfloop>



<!--- 


set 'pending' to corresponding page in globalHistory

Set a 'pending' action in the mrl_pageState table
actionBy user@example.com


--->