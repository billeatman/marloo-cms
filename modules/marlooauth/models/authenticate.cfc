component accessors=true {
	property name="config" inject="coldbox:moduleSettings:marlooauth" setter=false getter=false;
	property name="error" inject="error@marlooauth" setter=false getter=false;
	property name="throwErrors" type="boolean";
	property name="bcrypt" inject="bcrypt@bcrypt" setter=false getter=false;
	property name="dsn" inject="coldbox:datasource:marloo" setter=false;
	property name="ORMService" inject="entityservice";
	
	function init(){
		// set defaults until Adobe fixes defaults bug!!!
		setThrowErrors(false);
		return this;
	}

	// override implicit getter to just return the error structure.
	public struct function getErrorStruct(){
		return error.getErrorStruct();
	}

	public boolean function authenticate(string username, string password){
		var authSteps = variables.config.authSteps; 
		var step = "";

		for (step in authSteps) {
			switch (lcase(trim(step))) {
				case 'hash':
					// Check for temp clear text password
					if (!len(local.user.getPwHash()) && len(local.user.getPwTemp())) {
						if (password == local.user.getPwTemp()){
							error.setError(message: "You've reset your password.", code: "7");
							break;
						} else {
							error.setError(message: "You've entered an incorrect password.", code: "1");
							break;
						}
					}
						
					// Check for hashed password (default)
					if (!local.user.checkPassword(arguments.password)) {
						error.setError(message: "Your password is incorrect.", code: "1");
						break;
					}
				break;
				case 'user':
					// Check if user exists
					local.user = ORMService.get('marlooUser', arguments.username);
					if (NOT isDefined('local.user')) {
						error.setError(message: "The username you entered is invalid.", code: "5");
						break;
					}

					// Check if user is active
					if (NOT local.user.getActive()){
						error.setError(message: "This user is not active in this system.", code: "6");
						break;
					}	
				break;
				case 'lockout':
					
				break;
				case 'ldap':
				break;
				// Simple password check DEV ONLY!
				case 'simple':
					if (NOT simple(password: arguments.password)){
						error.setError(message: "The password you entered is invalid.", code: "5");
					}
				break;
				// Validate email address  
				case 'email':
					if (NOT isValid('email', arguments.username)){
						error.setError(message: "Please enter a correct email address.", code: "3");
					}
				break;
			}

			// Check for errors 
			if (error.isError()){
				if (throwErrors){
					error.throw();
				} else {
					return false;
				}
			}
		}

		return true;
	}

	private boolean function simple(string password){
		var simplePassword = variables.config.simplePassword;
		if (arguments.password EQ simplePassword){
			return true;
		}
		return false;	
	}
}
