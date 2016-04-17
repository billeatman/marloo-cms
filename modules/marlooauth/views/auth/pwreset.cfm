<div id="login-page" class="container-fluid">
	<div class="row">
		<div class="col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
			<h1 id="login-logo" class="text-center"><img src='/includes/src/img/logos/marloo-cms.png' alt='Marloo CMS' title='Marloo CMS' /></h1>
			<div id="login-panel" class="panel panel-mrl-dark">
				<div class="panel-heading">
					<h2 class="panel-title text-center">Welcome aboard, <cfoutput>#session.marlooauth.user.firstname#</cfoutput>!</h2>
				</div> <!-- /.panel-header -->
				<div class='panel-body'>
					<p class='text-center'>Please create a more secure password.</p>
				<form id='login-form' class='form-horizontal' action='index.cfm' method='post'>
					<div class='form-group'>
						<label for='inputPassword1' class='col-sm-3 text-right'>Password: </label>
						<div class='col-sm-8'>
							<input id='inputPassword1' type='password' class='form-control' name='r_password1' required />
						</div>
					</div>
					<div class='form-group'>
						<label for='inputPassword2' class='col-sm-3 text-right'>Confirm Password: </label>
						<div class='col-sm-8'>
							<input id='inputPassword2' type='password' class='form-control' name='r_password2' required />
						</div>
					</div>
					<div class='text-center'>
						<button class='btn btn-mrl-primary' type='submit'>Change Password</button>
					</div>
				</form>
				</div> <!--- /.panel-body --->
			</div> <!--- /.panel --->
		</div> <!--- /.col --->
	</div>
</div>