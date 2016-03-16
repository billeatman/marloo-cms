<cfcomponent>

<!---
<cfscript>
	this.mappings['/marloo'] = "c:\inetpub\webadmin\marloo\5.3.0\";
</cfscript>
--->

<!---
<cffunction name="onRequest" returntype="void">
	<cfdump var="#this.mappings#">
	<cfabort>
</cffunction>
--->

<!---
<cffunction
	name="OnRequestStart"
	access="public"
	returntype="boolean"
	output="true"
	hint="Fires at the beginning of a page requested before the requested template is processed.">
 

	<!--- Set header code. --->
	<cfheader
		statuscode="503"
		statustext="Service Temporarily Unavailable"
		/>
	 
	<!--- Set retry time. --->
	<cfheader
		name="retry-after"
		value="3600"
		/>
	 
	<h1>
		Down For Maintenance
	</h1>
	 
	<p>
		The web site is current down for maintenance and will
		be back up shortly. Sorry for the inconvenience.
	</p>
	 
	<cfreturn false />
</cffunction> 
--->

<!---
<cffunction name="onRequest" returnType="void"> 
    <cfargument name="targetPage" type="String" required=true/> 
	
    <cfheader statuscode="503" statustext="Service Temporarily Unavailable">

    
<!---       
    <cfdump var="#arguments.targetPage#">
    <cfdump var="#url#">
    <cfdump var="#cgi#">
--->

</cffunction>
--->

<!--- 
<cffunction name="onMissingTemplate" returnType="boolean">
    <cfargument type="string" name="targetPage" required=true/>
    	<cfdump var="#arguments.targetPage#">
		<cfabort>
    <cfreturn BooleanValue />
</cffunction>
--->
 
<cffunction name="onError">
    <!--- The onError method gets two arguments:
            An exception structure, which is identical to a cfcatch variable.
            The name of the Application.cfc method, if any, in which the error
			  happened. --->
    <cfargument name="Except" required=true/>
    <cfargument type="String" name = "EventName" required=true/>

    <!--- get the config for the site --->
	<cfinvoke component="siteConfig" method="getConfig" returnvariable="site_config" />
   
    <cfif site_config.displayErrors EQ true>
		<cfthrow object="#except#">
	</cfif>
    
    <cfset baseCFCPath = "#site_config.cfMappedPath#.#site_config.sitepath#">

	<!--- Add the error to the log --->
	<!---
	<cfquery datasource="#site_config.datasource#">
		insert into mrl_errorLog (datetime, message, detail, error, cgi, hash)
		values (
			<cfqueryparam cfsqltype="cf_sql_timestamp"value="#now()#">
			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#except.message#">
			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#except.detail#">
			,<cfqueryparam cfsqltype="cf_sql_blob" value="#toBinary(toBase64(SerializeJSON(arguments.except)))#"> 
			,<cfqueryparam cfsqltype="cf_sql_blob" value="#toBinary(toBase64(SerializeJSON(cgi)))#">
			,<cfqueryparam cfsqltype="cf_sql_varchar" value="">   	     
		<!---	,<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(SerializeJSON(arguments.except))#"> --->   	     
		)
	</cfquery>
	--->

    <!--- Error.  render the error page --->
<!---    <cfcache action="cache" timeSpan="#CreateTimeSpan(1,0,0,0)#">
---><cfheader statuscode="500" statustext="Internal Server Error">
	<cfinvoke component="marloo.core.pageservice" method="renderStaticTemplate">
	    <cfinvokeargument name="template_name" value="500">
	    <cfinvokeargument name="site_config" value="#site_config#">
	</cfinvoke>
<!---	</cfcache>
--->
	<cfabort>
</cffunction>

</cfcomponent>