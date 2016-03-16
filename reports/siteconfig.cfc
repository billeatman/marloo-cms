<cfcomponent>
	<cffunction name="getConfig" access="public" output="false" returntype="struct" hint="config var for the site">
    	<cfset var site_config = application.site_config>

        <cfreturn site_config>
    </cffunction> 	
</cfcomponent>
