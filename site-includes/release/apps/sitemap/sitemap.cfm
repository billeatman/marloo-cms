<!--- get the Site Map --->

<cfinvoke component="sitemap" method="getHTMLMap" returnvariable="ctxMap">
	<cfinvokeargument name="pageId" value="#variables.sc.cms.tree.rootid#">
	<cfinvokeargument name="datasource" value="#variables.sc.datasource#">
	<cfinvokeargument name="rootTitle" value="Home">
	<cfinvokeargument name="rootURL" value="http://www.example.com">
    <cfinvokeargument name="cacheHours" value="12">
    <cfinvokeargument name="useCache" value="#variables.sc.useCache#">
</cfinvoke>

<cfoutput>#siteMap#</cfoutput>
