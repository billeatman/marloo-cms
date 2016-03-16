<cfcomponent displayname="Application Manager">
	<cffunction name="getApplications" access="public" returntype="query">
		<cfquery datasource="#application.datasource#" name="qApplications">
        	select distinct app from mrl_siteAdmin where app is not null and app != ''
        </cfquery>
    	<cfreturn qApplications>
	</cffunction>
</cfcomponent>