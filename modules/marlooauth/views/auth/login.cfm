 <div class="container">
	<cfif structKeyExists(prc,"loginErrorStruct")>
		<cfoutput>
		<h2>#prc.loginErrorStruct.message#</h2>
		</cfoutput>
	</cfif>
      <form class="form-signin" action="index.cfm" method="post">
        <h2 class="form-signin-heading">Marloo Web Admin</h2>
        <label for="inputEmail" class="sr-only">Username</label>
        <input name="j_username" type="email" id="inputEmail" class="form-control" placeholder="Email address" required autofocus>
        <label for="inputPassword" class="sr-only">Password</label>
        <input name="j_password" type="password" id="inputPassword" class="form-control" placeholder="Password" required>
        <div class="checkbox">
        </div>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
      </form>

    </div> <!-- /container -->
</body>
</html>