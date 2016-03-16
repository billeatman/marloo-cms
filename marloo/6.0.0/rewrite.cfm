<!--- get the config for the site --->
<cfinvoke component="siteConfig" method="getConfig" returnvariable="site_config" />

<cfset baseCFCPath = "#site_config.cfMappedPath#.#site_config.sitepath#">

<cfset t1 = GetTickCount()>

<!--- initialize the page helper --->
<cfinvoke component="#baseCFCPath#.core.pageHelper" method="pageUrlToId" returnvariable="page">
	<cfinvokeargument name="page_url" value="#url.rewriteitem#">
    <cfinvokeargument name="root_id" value="#site_config.rootId#">
	<cfinvokeargument name="datasource" value="#site_config.datasource#"> 
	<cfinvokeargument name="useRedirectTable" value="#site_config.useRedirectTable#">       
</cfinvoke>

<!--- url.rewriteitem format "graduate-degrees/" --->

<cfif page.id NEQ ''>
	<cfset request.URI = url.rewriteitem> 	
</cfif>

<cfif page.id NEQ "" AND page.redirect NEQ true>
    <cfinvoke component="#baseCFCPath#.core.pageservice" method="getPageById" returnvariable="pageHTML">
        <cfinvokeargument name="page_id" value="#page.id#">
        <cfinvokeargument name="site_config" value="#site_config#">
    </cfinvoke>
    
    <cfif pageHTML eq ''>
		<cfset notFound410()>
	</cfif>		
	
<cfelseif page.redirect EQ true>
	<cfinvoke component="#baseCFCPath#.core.pageHelper" method="getQueryString" returnvariable="query_string">
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

<cffunction name="notFound410">
	<!--- page not found.  render the error page --->
	<cfinvoke component="#baseCFCPath#.core.pageservice" method="renderStaticTemplate">
	    <cfinvokeargument name="template_name" value="410">
	    <cfinvokeargument name="site_config" value="#site_config#">
	</cfinvoke>
	<cfabort>
</cffunction>
