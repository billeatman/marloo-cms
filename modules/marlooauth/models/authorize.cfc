component accessors=false {

property name="ormUser" inject="entityservice:marlooUser" setter=false getter=false;

function init(){
	return this;
}

// Must be called from within CFLOGIN tag
public void function login(required string username, required string password){
	cfloginuser(name: arguments.username, password: hash(arguments.password) roles:"");
	configureSession(username: arguments.username);
}

private void function configureSession(required string username){
	// Get user entity
	var user = ormUser.get(arguments.username);
	sessionRotate();
	session.marlooauth = {
		editkeys: {},
		user: {
			firstName: user.getFirstName(),
			lastName: user.getLastName(),
			username: user.getLogin()
		},
		reset = false
	};
}

}