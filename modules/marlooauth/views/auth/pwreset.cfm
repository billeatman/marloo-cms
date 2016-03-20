<div class='row'>
	<div class='col-sm-8 col-sm-offset-4'>
		<h1>Welcome to Marloo!</h1>
		<p class='lead'>Before you can access all the awesome features here, let's reset your password.</p>
		<div id='pw-reset-panel' class='panel panel-default'>
			<div class='panel-body'>
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
					<button class='btn btn-primary' type='submit'>Change Password</button>
				</div>
			</form>
			</div> <!--- /.panel-body --->
		</div> <!--- /.panel --->
	</div> <!--- /8 --->
</div> <!--- /row --->