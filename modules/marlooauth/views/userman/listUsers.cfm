<h1>Users</h1>

<cfset user = prc.users>
<table border="1">
	<tr>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<th>Login</th>
		<th>Created Date</th>
		<th>Active</th>
	</tr>
<cfloop query="user">
	<tr>
		<cfoutput>
		<td><a href="#event.buildLink(linkTo: 'marlooauth:userman.edituser', queryString='login=#user.login#')#">Edit</a></td>
		<td><a class="confirm" href="#event.buildLink(linkTo: 'marlooauth:userman.deleteuser', queryString='login=#user.login#')#">Delete</a></td>
		<td>#user.login#</td>
		<td>#dateFormat(user.createdDate)#</td>
		<td>#isActive(user.active)#</td>
		</cfoutput>
	</tr>
</cfloop>
</table>
<br />

<cfoutput>
<a href="#event.buildLink(linkTo: 'marlooauth:userman.edituser')#">Add User</a>
</cfoutput>

<cffunction name="isActive">
	<cfargument name="active" required="true">

	<cfif ucase(trim(arguments.active)) EQ 'T'>
		<cfreturn true>
	</cfif>

	<cfreturn false>		
</cffunction>

<script type="text/javascript">
var elements = document.getElementsByClassName('confirm');

for (var e = 0; e < elements.length; ++e) {
	elements[e].addEventListener('click', function(e){
		if (!confirm('Are you sure?'))
			e.preventDefault();
	}, false);
}

</script>


