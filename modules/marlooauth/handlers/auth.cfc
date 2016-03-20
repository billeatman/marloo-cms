component extends="coldbox.system.EventHandler"{
	property name="messagebox" inject="messagebox@cbmessagebox";
	property name="ormUser" inject="entityservice:marlooUser" setter=false getter=false;

	function index(event,rc,prc){
		event.setView("home/index");
	}

	function login(event,rc,prc){
		event.setView("auth/login");		
	}

	function logout(event,rc,prc){
		event.setView("auth/login");
		structClear(session);
		cflogout();
		setNextEvent(event: "marlooauth:auth.login");
	}

	function pwreset(event,rc,prc){
		// Is a pwreset being requested
		if (session.marlooauth.reset == true && event.valueExists('r_password1') && event.valueExists('r_password2')) {
			if (rc.r_password1 != rc.r_password2){
				messagebox.error("The passwords do not match");
				return;
			}

			// Get user entity
			var user = ormUser.get(session.marlooauth.user.login);

			// Bail out if the user is not found
			if (isNull(user)){
				messagebox.error("Error resetting passsword");
				runEvent(event: 'marlooauth:auth.logout', prepostExemp: true);
				return;
			}	

			// Set and save the password 
			user.setPassword(rc.r_password1);
			user.save();

			messagebox.info("Password Change Successful");
			runEvent(event: 'marlooauth:auth.logout', prepostExemp: true);
		}
	}
}
