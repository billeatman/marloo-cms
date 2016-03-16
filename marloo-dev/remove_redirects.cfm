<cfsetting requesttimeout="999999">

<cfset path = "#GetDirectoryFromPath(GetCurrentTemplatePath())#">    
<!--- <cfset webpath = "http:#application.site_config.CMS.web.editorroot#site-release/"> --->
<cfset wpath = "http://www.example.com/">

<cfset datasource = "marloo-ds">

<cfdirectory type="file" recurse="true" filter="index.cfm" name="qIndex" directory="#path#">

<cfloop query="qIndex">
	<cfset webPath = replaceNoCase(qIndex.directory, "#path#", "#wpath#")>
	<cfset webPath = replace(webPath, "\", "/", "all")>


	<cfhttp url="#webPath#/index.cfm" method="head" redirect="false" result="redirect">

	<cfif find("301", redirect.statusCode) EQ 1>
		
		<cfdirectory action="delete" directory="#qIndex.directory#" recurse="yes">
		<cfdump var="#webPath#/index.cfm"><br />

		
	</cfif> 

</cfloop>



