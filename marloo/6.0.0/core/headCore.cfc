<cfcomponent displayname="headCore">

<cfset variables.isRendered = false>

<cffunction name="init" returntype="headCore">
	<cfreturn this>
</cffunction>

<cffunction name="addHTMLHead">
	<cfargument name="text" type="string" required="true">
	<cfargument name="override" type="boolean" required="false" default="false">

	<cfif variables.isRendered EQ true>
		
	</cfif>


</cffunction>

<cffunction name="renderHead">
	

<cfset variables.isRendered = true>
</cffunction>

</cfcomponent>