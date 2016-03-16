<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">		
	<cfargument name="s_content" required="false" default="">
	<cfargument name="title" required="true" type="string">
	<cfargument name="name" required="false" type="string">

	<cfoutput>
	<cfsavecontent variable="content">
		<div class="limber-tab">
			<div class="limber-title">#arguments.title#</div>
			#arguments.s_content#
		</div>
	</cfsavecontent>
	</cfoutput>

	<cfreturn content>

</cffunction>

</cfcomponent>
