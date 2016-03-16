<!--- only way to tell if we are / or /default.cfm!!!  --->
<cfif NOT isNumeric(cgi.CONTENT_LENGTH)> 
	<cfinvoke component="marloo.core.pageHelper" method="getBasePath" returnvariable="basePath" />
	
    <cfheader statuscode="301" statustext="Moved Permanently">
    <cfheader name="location" value="#basepath#">
	<cfabort>
</cfif>

<!--- Use for static roots --->
<!---
<cfinvoke component="marloo.core.pageService" method="renderStaticTemplate">
    <cfinvokeargument name="template_name" value="homepage">
    <cfinvokeargument name="site_config" value="#request.site_config#">
</cfinvoke>
--->

<!--- Use for dynamic roots --->
<cfinvoke component="marloo.core.pageService" method="getPageById" returnvariable="pageHTML">
    <cfinvokeargument name="page_id" value="2835">
    <cfinvokeargument name="site_config" value="#request.site_config#">
</cfinvoke>

<cfoutput>#pageHTML#</cfoutput>

<cfabort>
