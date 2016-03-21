<cfcomponent extends="coldbox.system.Interceptor">

<cfproperty name="messagebox" inject="messagebox@cbmessagebox">

<cffunction name="preProcess" returntype="void" output="false">
	<cfargument name="event" type="any">
	<cfargument name="interceptData" type="struct">	

	<cfset var prc = event.getCollection(private=true)>
	<cfset var authenticated = false>

	<!--- login check --->
	<cflogin>
		<!--- authenticate user based on ModuleConfig --->
		<cfset auth = getInstance("authenticate@marlooauth")>

		<cfif isDefined("cflogin")>
			<!--- authenticate the user --->
			<cfset authenticated = auth.authenticate(
				username: cflogin.name,
				password: cflogin.password)>
			<cfif authenticated>
				<cfset getInstance("authorize@marlooauth").login(username: cflogin.name, password: cflogin.password)>
				<cfset setNextEvent(event: getSetting('defaultEvent'))>
			<cfelse>
				<!--- Set the reset flag and log in for pwreset --->
				<cfif auth.getErrorStruct().code EQ 7>
					<cfset getInstance("authorize@marlooauth").login(username: cflogin.name, password: cflogin.password)>
					<cfset session.marlooauth.reset = true>
					<cfset variables.messagebox.info(auth.getErrorStruct().message)>		
					<cfset event.overrideEvent("marlooauth:auth.pwreset")>
					<cfreturn>
				</cfif>
				<cfset event.overrideEvent("marlooauth:auth.login")>

				<cfset variables.messagebox.error(auth.getErrorStruct().message)>		
			</cfif>
		</cfif>
		
		<cfset event.overrideEvent("marlooauth:auth.login")>
	</cflogin>

	<!--- Force a user to reset a password after login --->	
	<cfif IsUserLoggedIn() AND session.marlooauth.reset AND event.getCurrentEvent() NEQ "marlooauth:auth.logout">	
		<cfset event.overrideEvent("marlooauth:auth.pwreset")>		
	</cfif>

</cffunction>

</cfcomponent>