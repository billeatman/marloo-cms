<div class="container">
	<cfif structKeyExists(prc,"loginErrorStruct")>
		<cfoutput>
		<h2>#prc.loginErrorStruct.message#</h2>
		</cfoutput>
	</cfif>
	<div class="row">
		<div class="col-sm-6 col-sm-offset-3">
			<h1 id="login-logo" class="text-center">Marloo CMS</h1>
			<div id="login-panel" class="panel panel-default">
				<div class="panel-heading">
					<h2 class="panel-title">Log in to Marloo CMS</h2>
				</div> <!-- /.panel-header -->
				<div class="panel-body">
				<form id="login-form" class="form-horizontal" action="index.cfm" method="post">
					<div class="form-group">
						<label for="inputEmail" class="col-sm-3 text-right">Username: </label>
						<div class="col-sm-8">
							<input id="inputEmail" type="email" class="form-control" name="j_username" required />
						</div>
					</div>
					<div class="form-group">
						<label for="inputPassword" class="col-sm-3 text-right">Password: </label>
						<div class="col-sm-8">
							<input id="inputPassword" type="password" class="form-control" name="j_password" required />
						</div>
					</div>
					<div class="text-center">
						<button class="btn btn-primary" type="submit">Log In!</button>
					</div>
				</form>
				</div> <!-- /.panel-body -->
				<div class="panel-footer text-center">
					<a id="forgot-password">Forgot your password?</a>
				</div> <!-- /.panel-footer -->
			</div> <!-- /.panel -->
		</div> <!-- /12 -->
	</div> <!-- /.row -->
</div> <!-- /.container -->