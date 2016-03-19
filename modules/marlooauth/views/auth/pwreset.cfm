<div class="container">
	<cfset writeOutput(getInstance("messagebox@cbmessagebox").renderIt(true))>
	<cfoutput>
	<a href="#event.buildLink(linkTo: 'marlooauth:auth.logout')#">Logout</a>
	</cfoutput>
	<div class="row">
		<div class="col-sm-6 col-sm-offset-3">
			<h1 id="login-logo" class="text-center">Marloo CMS</h1>
			<div id="login-panel" class="panel panel-default">
				<div class="panel-heading">
					<h2 class="panel-title">Password must be changed</h2>
				</div> <!-- /.panel-header -->
				<div class="panel-body">
				<form id="login-form" class="form-horizontal" action="index.cfm" method="post">
					<div class="form-group">
						<label for="inputPassword1" class="col-sm-3 text-right">Password: </label>
						<div class="col-sm-8">
							<input id="inputPassword1" type="password" class="form-control" name="r_password1" required />
						</div>
					</div>
					<div class="form-group">
						<label for="inputPassword2" class="col-sm-3 text-right">Password Confirm: </label>
						<div class="col-sm-8">
							<input id="inputPassword2" type="password" class="form-control" name="r_password2" required />
						</div>
					</div>
					<div class="text-center">
						<button class="btn btn-primary" type="submit">Change Password</button>
					</div>
				</form>
				</div> <!-- /.panel-body -->
			</div> <!-- /.panel -->
		</div> <!-- /12 -->
	</div> <!-- /.row -->
</div> <!-- /.container -->