<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="s_content" required="false" default="">

	<cfset var content = "">

	<cfsavecontent variable="content">
	<div class="truncate">
		<cfoutput>#s_content#</cfoutput>
	</div>
	</cfsavecontent>

	<cfreturn content>
</cffunction>

</cfcomponent>