<cfcomponent output="false" displayname="liveSearch">
	<cffunction name="search" access="remote" output="false" returntype="array" returnformat="json">
		<cfargument name="value">
		<cfset var searchResults = "">

		<cfquery datasource="marloo-ds" name="searchResults">
        select rtrim(menu) as pageName, rtrim(securityGroup) as pageGroup, ID as page_ID 
        from mrl_sitePublic 
		where title like <cfqueryparam cfsqltype="cf_sql_varchar" value="#value#%">
		ORDER BY title
        </cfquery>

		<cfset myResult = ArrayNew(1)>

		<cfloop query="searchResults">
		<cfSet rs = structnew()>
		<cfset rs.page_name = '#pageName#'>
		<cfset rs.page_ID = '#page_ID#'>
		<cfset ArrayAppend(myResult, rs)>
		</cfloop>

        <cfreturn myResult>
	</cffunction>
</cfcomponent>