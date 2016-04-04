<div class='col-md-3'>
	<div class='panel-group'>
		<div id='userman-nav-panel' class='panel panel-default'>
			<div class='panel-heading'>
				<h2 class='panel-title'><i class='typcn typcn-group-outline'></i> User Manager</h2>
			</div> <!--- /panel-heading --->
			<div class='panel-body'>
				<div class='btn-group-vertical' role='group'>
					<a href='' class='btn btn-default btn-lg active'><i class='typcn typcn-user'></i> Users</a>
					<a href='' class='btn btn-default btn-lg'><i class='typcn typcn-group'></i> Groups</a>
					<a href='' class='btn btn-default btn-lg'><i class='ti ti-id-badge'></i> Roles</a>
				</div> <!--- /btn-group-v --->
			</div> <!--- /panel-body --->
		</div> <!--- /panel --->
	</div> <!--- /panel-group --->
</div> <!--- /3 --->
<div class='col-md-9'>
	<div class='row'>
		<div class='col-md-8'>
			<h1>Users</h1>
		</div> <!--- /8 --->
		<div class='col-md-4 text-right'>
			<cfoutput><a href="#event.buildLink(linkTo: 'marlooauth:userman.edituser')#" class='btn btn-mrl-primary'><i class='typcn typcn-user-add-outline'></i> Add a User</a></cfoutput>
		</div> <!--- /4 --->
	</div> <!--- /row --->
	<cfset user = prc.users>
	<table class='table table-striped'>
		<thead>
			<tr>
				<th>Options</th>
				<th>Username</th>
				<th>Date Added</th>
				<th>Active?</th>
			</tr>
		</thead>
		<tbody>
	<cfloop query='user'>
			<tr>
				<cfoutput>
				<td>
					<a href="#event.buildLink(linkTo: 'marlooauth:userman.edituser', queryString='login=#user.login#')#" class='btn btn-xs btn-mrl'><i class='ti ti-pencil'></i> Edit</a>
					<a href="#event.buildLink(linkTo: 'marlooauth:userman.deleteuser', queryString='login=#user.login#')#" class='btn btn-xs btn-mrl confirm'><i class='ti ti-trash'></i> Delete</a>
				</td>
				<td>#user.login#</td>
				<td>#dateFormat(user.createdDate)#</td>
				<td>#isActive(user.active)#</td>
				</cfoutput>
			</tr>
	</cfloop>
		</tbody>
	</table>

	<cffunction name="isActive">
		<cfargument name="active" required="true">

		<cfif ucase(trim(arguments.active)) EQ 'T'>
			<cfreturn 'Active'>
		</cfif>

		<cfreturn 'Inactive'>		
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

</div> <!--- /9 --->


