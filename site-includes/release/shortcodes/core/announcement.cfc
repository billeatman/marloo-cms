<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="type" required="true" default="400">
	<cfargument name="s_content" required="false" default="">

	<cfsavecontent variable="local.html">
		<div class="announcement"><cfoutput>#arguments.s_content#</cfoutput></div>
	</cfsavecontent>

	<cfreturn local.html>
</cffunction>

</cfcomponent>