<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">		
	<cfargument name="video" type="numeric" required="true">
	<cfargument name="title" type="string" required="false">
	<cfargument name="width" type="numeric" required="false" default="350">
	<cfargument name="height" type="numeric" required="false">

	<cfset var content = "">
	<cfoutput>
	<cfsavecontent variable="content">
	<iframe src="//player.vimeo.com/video/#arguments.video#" width="#arguments.width#" 
	<cfif isDefined("arguments.height")>
		height="#arguments.height#"
	</cfif> frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="http://vimeo.com/#arguments.video#"></p>
	</cfsavecontent>
	</cfoutput>

	<cfreturn content>
</cffunction>

</cfcomponent>
