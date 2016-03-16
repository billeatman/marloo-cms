<cfcomponent>
	<cffunction name="getConfig" access="public" output="false" returntype="struct" hint="config var for the site">
    	<cfset var site_config = structNew()>
        
        <cfscript>
			// General
			site_config.admin = true;				// true for CMS, false for release
			site_config.datasource = application.datasource;		// datasource for the site
			site_config.cfMappedPath = replace(application.path.assetsMapping, '/', '', 'all');	// mapped path 
			site_config.displayErrors = true;
			
			// SEO
			site_config.URLrewriter = false;
			site_config.useRedirectTable = false;
// This is now set below //
//			site_config.rootId = 0;
			site_config.useCache = false;
		</cfscript>
        
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
		<cfset site_config.CMS = getCMSConfig(site_config: site_config, admin: true)>
		<cfset site_config.rootId = site_config.CMS.tree.rootid>

        <cfreturn site_config>
    </cffunction> 
	
    <cffunction name="getCMSConfig" access="public" returntype="struct" hint="Gets the CMS master config">
		<cfargument name="admin" type="boolean" default="true">
		<cfset var myConfig = StructCopy(application)>    	

		<cfset structDelete(myConfig, "site_config")>

		<cfreturn myConfig>
    </cffunction>

</cfcomponent>

