<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="s_content" required="false" default="">
	<cfargument name="color" required="false" default="yellow">

	<cfreturn "<span style='background-color: #arguments.color#'>#arguments.s_content#</span>">
</cffunction>

</cfcomponent>