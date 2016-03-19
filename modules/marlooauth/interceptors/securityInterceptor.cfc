<cfcomponent extends="coldbox.system.Interceptor">
	
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

				<cfset setNextEvent(event: getSetting('defaultEvent'))>
			<cfelse>
				<cfset prc.loginErrorStruct = auth.getErrorStruct()>
			</cfif>
		</cfif>
		
		<cfset event.overrideEvent("marlooauth:auth.login")>
	</cflogin>
	

</cffunction>



</cfcomponent>