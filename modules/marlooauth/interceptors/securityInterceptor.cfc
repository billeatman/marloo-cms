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
		<cfset auth = getInstance("auth@marlooauth")>

		<cfif isDefined("cflogin")>
			<!--- authenticate the user --->
			<cfset authenticated = auth.authenticate(
				password: cflogin.password, 
				username: cflogin.name)>
			<cfif authenticated>
				<cfset doLogin()>
				<cfset setNextEvent(event: getSetting('defaultEvent'))>
			<cfelse>
				<!--- Set the reset flag and log in for pwreset --->
				<cfif auth.getErrorStruct().code EQ 7>
					<cfset doLogin(reset: true)>
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

	<cfif event.getCurrentEvent() NEQ "marlooauth:auth.logout">	
		<!--- Force a user to reset a password after login --->	
		<cfif IsUserLoggedIn() >
			<cfif session.marlooauth.reset EQ true>
				<cfset event.overrideEvent("marlooauth:auth.pwreset")>		
			</cfif>
		</cfif>
	</cfif>
	
</cffunction>

<cffunction name="doLogin" access="private" output="false" returnType="void">
	<cfargument name="reset" required="false" type="boolean" default="false">
	
	<cfloginuser name="#cflogin.name#" password="#cflogin.password#" roles=""/> 
	<cfset sessionRotate()>

	<!--- Build auth session --->
	<cfset session.marlooauth = structNew()>
	<cfset session.marlooauth.editkeys = structNew()>
	<cfset session.marlooauth.user = {
		firstname = 'REWORK',
		lastname = 'REWORK',
		login = cflogin.name
	}>

	<cfif arguments.reset EQ true>
		<cfset session.marlooauth.reset = true>
	</cfif>
	
</cffunction>



</cfcomponent>