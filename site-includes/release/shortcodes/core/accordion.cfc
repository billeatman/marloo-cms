<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">		
	<cfargument name="s_content" required="false" default="">
	<cfargument name="title" required="true">

	<cfset var content = "">

	<cfset arguments.s_content = filterWhiteSpace(arguments.s_content)>

	<cfoutput>
	<cfsavecontent variable="content">
		<dt>#arguments.title#</dt>
		<dd>#arguments.s_content#</dd>
	</cfsavecontent>
	</cfoutput>

	<cfreturn content>
</cffunction>

</cfcomponent>
