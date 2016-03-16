<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="s_content" required="false" default="">
	<cfargument name="url" required="true" default="yellow">

	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="#arguments.url#">

	<cfabort>
</cffunction>

</cfcomponent>