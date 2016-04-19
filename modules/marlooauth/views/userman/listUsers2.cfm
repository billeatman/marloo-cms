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
<div class='col-md-9' ng-controller="UsermanController as userman">
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
				<th>Username</th>
				<th>Options</th>
				<th>Date Added</th>
				<th>Active?</th>
			</tr>
		</thead>
		<tbody>
			<tr ng-repeat="user in userman.users">
				<td>{{user.login}}</td>
				<td><button class='btn btn-xs btn-mrl'><i class='ti ti-pencil'></i> Edit</button>
					<button class='btn btn-xs btn-mrl confirm'><i class='ti ti-trash'></i> Delete</button></td>
				<td>{{user.createdDate}}</td>
				<td>{{user.active}}</td>
			</tr>
			<tr>
				<td colspan='4'>
					<div class='row'>
						<div class='col-md-offset-2 col-md-8'>
							<form id='edit-user' class='form form-horizontal'>
								<div class='form-group'>
									<label for='user-email' class='col-md-3'>Username / email:</label>
									<div class='col-md-9'>
										<input type='email' name='user-email' class='form-control' value='billeatman@hotmail.com' />
									</div>
								</div>
								<div class='form-group'>
									<label for='user-pass' class='col-md-3'>Update Password:</label>
									<div class='col-md-9'>
										<input type='password' name='user-pass' class='form-control' value='' />
									</div>
								</div>
								<div class='form-group'>
									<label for='user-fname' class='col-md-3'>Name:</label>
									<div class='col-md-9'>
										<div class='row'>
											<div class='col-md-6'>
												<input type='text' name='user-fname' class='form-control' value='Billy' />
											</div>
											<div class='col-md-6'>
												<input type='text' name='user-lname' class='form-control' value='Eatman' />
											</div>
										</div>
									</div>
								</div>
								<div class='form-group'>
									<div class='col-md-6 col-md-offset-3'>
										<div class='checkbox'>
											<label>
												<input type='checkbox' name='user-active' value='' /> This account is active.
											</label>
										</div>
									</div>
								</div>
								<div class='form-group text-center'>
									<button type='submit' name='submit' class='btn btn-md btn-mrl'>Edit this User</button>
								</div>
							</form>
						</div>
					</div>
				</td>
			</tr>
		</tbody>
	</table>

	<cffunction name="isActive">
		<cfargument name="active" required="true">

		<cfif ucase(trim(arguments.active)) EQ 'T'>
			<cfreturn 'Active'>
		</cfif>

		<cfreturn 'Inactive'>		
	</cffunction>
</div> 


