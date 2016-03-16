<cfcomponent>
	<cffunction name="getConfig" access="public" output="false" returntype="struct" hint="config var for the site">
        <cfset site_config.sitePath = "release">
        
		<!--- CF10 hack --->
		<cfscript>
		if (ListFirst(server.coldfusion.productversion,",") GTE 10) {
			local.sessionManagement = getApplicationMetaData().sessionManagement; // CF10 compatible
		} else {
			local.sessionManagement = application.getApplicationSettings().sessionManagement;
		}
		</cfscript>
		
		<cfif local.sessionManagement EQ true AND isDefined("session.settings.devview")>
			<cfif site_config.admin EQ true AND session.settings.devview EQ true> 
        		<cfset site_config.sitepath = "dev">
    		</cfif>
		</cfif>
	
		<!--- Append CMS configs --->
		<cfset site_config.CMS = getCMSConfig(site_config: site_config)>

		<!--- flush all the cache if it is turned off --->
		<cfif site_config.flushCache EQ true>
			<!--- Remove the Object cache. --->
			<cfloop index="cache" array="#cacheGetAllIds()#">
			    <cfset cacheRemove(cache)>
			</cfloop>

			<!--- Remove the Template cache. --->
			<cfcache action="flush">	
		</cfif>

<!---
		<cfdump var="#site_config#">
		<cfabort>
--->

        <cfreturn site_config>
    </cffunction> 
	
	<cffunction name="getCMSConfig" access="private" returntype="struct" hint="Gets the CMS master config"> 	
		<cfargument name="site_config" type="struct" required="true">
		
		<cfset var qConfig = "">

		<cfif arguments.site_config.useCache EQ true>
			<cfset var myConfig = CacheGet("CMSConfig#site_config.datasource##site_config.cfMappedPath#")>
		</cfif>		

		<cfif NOT isNull(myConfig)>
			<cfreturn myConfig>
		</cfif>
		   
		<!--- read the config from the database --->
	    <cfquery datasource="#arguments.site_config.datasource#" name="qConfig">
	     	select top 1 config from mrl_siteConfig order by [datetime] desc
	    </cfquery>


	    <cfset myConfig = DeserializeJSON(qConfig.config)>

	    <cfset structDelete(myConfig, "site_config")>
	    
		<!--- If in the admin interface, set the correct siteroot --->
		<cfif arguments.site_config.admin eq true>
			<cfset myConfig.web.siteroot = myConfig.web.editorroot & 'site-' & site_config.sitePath & '/'>
		</cfif>

		<cfif arguments.site_config.useCache EQ true>
			<cfset CachePut("CMSConfig#site_config.datasource##site_config.cfMappedPath#", myConfig, createTimeSpan(0,0,5,0))>
		</cfif>		
		
		<cfreturn myConfig>
	</cffunction>
</cfcomponent>


