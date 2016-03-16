<cfcomponent displayname="Template Manager">
	<cffunction name="getTemplates" access="public" returntype="query">
		<cfquery datasource="#application.datasource#" name="qTemplates">
        	select * from mrl_template
        	order by templateName asc
        </cfquery>
    <cfreturn qTemplates>
	</cffunction>
</cfcomponent>