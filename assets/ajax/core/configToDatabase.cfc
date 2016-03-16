<cfcomponent displayname="configToDatabase" output="false">

<cffunction name="isConfigCurrent" returntype="boolean">
	<cfargument name="applicationName" type="string" required="true">

	<cfquery datasource="#application.datasource#" name="local.qConfig">
		select top 1 config from mrl_siteConfig order by [datetime] desc
	</cfquery>		

	<cfif local.qConfig.recordCount NEQ 0>
		<cfset local.config = DeserializeJSON(qConfig.config)>
	<cfelse>
		<cfreturn false>
	</cfif>

	<cfif arguments.applicationName NEQ local.config.applicationName>
		<cfreturn false>
	</cfif>

	<cfreturn true>
</cffunction>

<cffunction name="configToDatabase">
	<cfinvoke component="siteconfig" method="getCMSconfig" returnvariable="local.config">
		<cfinvokeargument name="admin" value="false">
	</cfinvoke>
	
	<cfset local.config = SerializeJSON(local.config)>

	<cfquery datasource="#application.datasource#">
	    insert into mrl_siteConfig (config, datetime)
	    values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.config#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">)    
	</cfquery>

	<!--- clear front end cache --->
	<cfset cacheRemove("CMSConfig#lcase(application.datasource)##lcase(application.path.assetsmapping)#")>
</cffunction>

</cfcomponent>