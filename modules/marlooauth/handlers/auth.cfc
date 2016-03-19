/**
* A normal ColdBox Event Handler
*/
<cfcomponent>

	<cffunction name="index">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset event.setView( "home/index" )>

	</cffunction>

	<cffunction name="login">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		
		<cfset event.setView( "auth/login" )>
	</cffunction>

	<cffunction name="logout">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		
		<cfset StructClear(session)>
		<cflogout>
		
		<cfset setNextEvent(event: "marloo-auth:auth.login")>	
	</cffunction>

</cfcomponent>
