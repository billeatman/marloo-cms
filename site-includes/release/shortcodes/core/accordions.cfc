<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">		
	<cfargument name="s_content" required="false" default="">

	<cfset var content = "">

	<cfsavecontent variable="content">
		<dl class="accordion">
			<cfoutput>#s_content#</cfoutput>
		</dl>
	</cfsavecontent>

	<cfreturn content>
</cffunction>

</cfcomponent>
