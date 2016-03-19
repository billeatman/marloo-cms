<h1>Edit User</h1>

<cfoutput>
<form method="post" action="#event.buildLink('marlooauth:userman.saveUser')#">
	<input type="hidden" name="editKey" value="#prc.editKey#">

	<cfif isNewUser()>
		<cfset renderErrorMessage("login")>
		<label for="frmLogin">Login/Email Address: </label>
		<input type="text" name="login" id="frmLogin" value="#prc.user.getLogin()#" />
		<br /><br />
		<cfset renderErrorMessage("Password")>
		<label for="frmLogin">Password: </label>
		<input type="password" name="password" id="frmPassword" value="" />
	<cfelse>
		<p>
		Login: #prc.user.getLogin()#<br />
		Created: #dateFormat(prc.user.getCreatedDate())#
		</p>
	</cfif>
	<p>
	<cfset renderErrorMessage("firstname")>
	<label for="frmLogin">First Name: </label>
	<input type="text" name="firstname" id="frmActive" value="#prc.user.getFirstname()#"/><br />
	<cfset renderErrorMessage("lastname")>
	<label for="frmLogin">Last Name: </label>
	<input type="text" name="lastname" id="frmActive" value="#prc.user.getLastname()#" />
	</p>
	<p>
	<cfset renderErrorMessage("active")>
	<label for="frmLogin">Active: </label>
	<input type="checkbox" name="active" value="true" id="frmActive" #prc.user.getActive() ? 'checked' : ''# /></p>
	<input type="submit" />

</form>
</cfoutput>

<!--- HELPER --->

<cffunction name="isNewUser" output="false">
	<cfif session.marlooauth.editKeys["#prc.editKey#"] EQ "">
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction name="isFieldError" output="false">
	<cfargument name="fieldname" required="true" type="string">

	<cfif isDefined("prc.formErrors.#arguments.fieldname#")>
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction name="renderErrorMessage" output="true">
<cfargument name="fieldname" required="true" type="string">
<cfif isFieldError(arguments.fieldname)>
<cfoutput><span style="color: red; font-style: italic">#prc.formErrors["#arguments.fieldname#"][1].message#</span></cfoutput><br />
</cfif>
</cffunction>