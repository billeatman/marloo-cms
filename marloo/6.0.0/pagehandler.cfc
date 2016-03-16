<cfcomponent displayname="sitehandler">

<cffunction name="RenderPageByID">
	<cfargument name="page_id" type="any" default="">
	<cfargument name="history_id" type="any" default="">
	<cfargument name="site_config" type="struct" required="true">
	
	<cfset variables.page_id = arguments.page_id>
	<cfset variables.history_id = arguments.history_id>
	<cfset variables.site_config = arguments.site_config>

	<cfset t1 = GetTickCount()>

	<!--- if the siteroot is a page id, and the siteroot is NOT a page id Ex: default.cfm, then redirect to the actual root --->
	<cfif isdefined("url.page_id") and page_id EQ site_config.cms.tree.rootid AND findNoCase("page.cfm?page_id", site_config.cms.web.siteroot) EQ 0>
		<cfheader statuscode="301" statustext="Moved Permanently">
		<cfheader name="location" value="#site_config.cms.web.siteroot#">
		<cfabort>
	</cfif> 

	<cfif site_config.URLrewriter EQ true>
		<!--- SEO rewritter logic --->
		<cfif history_id NEQ "" AND siteConfig.admin EQ true>   
	        <cfinvoke component="marloo.core.pageHelper" method="pageIdToURL" returnvariable="urlPath">
	            <cfinvokeargument name="history_id" value="#history_id#">
	           	<cfinvokeargument name="datasource" value="#site_config.datasource#">
	           	<cfinvokeargument name="URLrewriter" value="true">
	           	<cfinvokeargument name="site_config" value="#site_config#">
	        </cfinvoke>
	    <cfelse>
	        <cfinvoke component="marloo.core.pageHelper" method="pageIdToURL" returnvariable="urlPath">
	            <cfinvokeargument name="page_id" value="#page_id#">
	           	<cfinvokeargument name="datasource" value="#site_config.datasource#">    
	           	<cfinvokeargument name="URLrewriter" value="true">
	           	<cfinvokeargument name="site_config" value="#site_config#">
	        </cfinvoke>
	    </cfif>
		
	    <cfif len(urlPath) NEQ 0 AND NOT isNumeric(urlPath)>
			<cfinvoke component="marloo.core.pageHelper" method="getQueryString" returnvariable="query_string">
				<cfinvokeargument name="useRedirectTable" value="true">
			</cfinvoke>
	        <cfheader statuscode="301" statustext="Moved Permanently">
		    <cfif query_string EQ "">
			    <cfheader name="location" value="#urlPath#">
		    <cfelse>
			    <cfheader name="location" value="#urlPath#?#query_string#">
		    </cfif>
	        <cfabort>    
	    <cfelseif isNumeric(urlPath)>
			<cfset standardPageLogic()>	
		<cfelse>		
	    	<!--- 410 --->
			<cfset notFound410()>
	    </cfif>
	<cfelse>
		<cfset standardPageLogic()>
	</cfif>

</cffunction>

<cffunction name="RenderPageByURL" hint="Renders a page by the requested rewrite url">
	<cfargument name="page_url" type="string" required="true">
	<cfargument name="site_config" type="struct" required="true">

	<!--- page_url format "graduate-degrees/" --->
	
	<cfset variables.site_config = arguments.site_config>

	<cfset t1 = GetTickCount()>
	<cfinvoke component="marloo.core.pageHelper" method="pageUrlToId" returnvariable="page">
		<cfinvokeargument name="page_url" value="#arguments.page_url#">
	    <cfinvokeargument name="root_id" value="#variables.site_config.rootId#">
		<cfinvokeargument name="datasource" value="#variables.site_config.datasource#"> 
		<cfinvokeargument name="useRedirectTable" value="#variables.site_config.useRedirectTable#">       
	</cfinvoke>

	<!--- if the page exists, put the url into the request scope.
	pageHelper.getCurrentURL() needs this --->
	<cfif page.id NEQ ''>
		<cfset request.URI = arguments.page_url> 	
	</cfif>

	<!--- if the page exists and it's not a redirect --->
	<cfif page.id NEQ "" AND page.redirect NEQ true>
	    <cfinvoke component="marloo.core.pageservice" method="getPageById" returnvariable="pageHTML">
	        <cfinvokeargument name="page_id" value="#page.id#">
	        <cfinvokeargument name="site_config" value="#variables.site_config#">
	    </cfinvoke>
	    
	    <cfif pageHTML eq ''>
			<cfset notFound410()>
		</cfif>		
	<cfelseif page.redirect EQ true>
		<cfinvoke component="marloo.core.pageHelper" method="getQueryString" returnvariable="query_string">
			<cfinvokeargument name="useRedirectTable" value="true">
		</cfinvoke>

		<cfheader statuscode="301" statustext="Moved Permanently">
	    <cfif query_string EQ "">
		    <cfheader name="location" value="#page.redirectUrl#">
	    <cfelse>
		    <cfheader name="location" value="#page.redirectUrl#?#query_string#">
	    </cfif>
		<cfabort>
	<cfelse>
		<!--- page not found.  render the error page --->
		<cfset notFound410()>
	</cfif>

	<cfoutput>#pageHTML#</cfoutput>
	<cfif site_config.showTime EQ true>
	<cfoutput>#GetTickCount() - t1#</cfoutput>
	</cfif>
	<cfabort>
</cffunction>

<cffunction name="standardPageLogic">
	<!--- Standard page_id logic --->
	<cfinvoke component="marloo.core.pageService" method="getPageById" returnvariable="pageHTML">
        <cfinvokeargument name="page_id" value="#page_id#">
        <cfinvokeargument name="history_id" value="#history_id#">
    	<cfinvokeargument name="site_config" value="#variables.site_config#">
    </cfinvoke>

    <cfif pageHTML neq "">
	    <cfoutput>#pageHTML#</cfoutput>
		<cfif site_config.showTime EQ true>
		<cfoutput>#GetTickCount() - t1#</cfoutput>
		</cfif>
        <cfabort>
    <cfelse>
		<!--- 410 --->
		<cfset notFound410()>
    </cfif>
</cffunction>

<cffunction name="notFound410">
	<!--- page not found.  render the error page --->
	<cfinvoke component="marloo.core.pageservice" method="renderStaticTemplate">
	    <cfinvokeargument name="template_name" value="410">
	    <cfinvokeargument name="site_config" value="#variables.site_config#">
	</cfinvoke>
	<cfabort>
</cffunction>

</cfcomponent>