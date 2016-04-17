component extends="coldbox.system.EventHandler"{
	property name="orm" inject="entityservice" setter=false getter=false;

	function listUsers(event,rc,prc){
		prc.users = orm.list('marlooUser');
		event.setView("userman/listusers2");
	}

	function saveUser(event,rc,prc){
		// Check the edit key
		var editKey = prc.editkey = rc.editkey;
		if (NOT structKeyExists(session.marlooauth.editkeys, editkey)) {
			throw("error, invalid edit session");
		}
		
		var login = session.marlooauth.editkeys['#editKey#'];
		var isNewUser = login eq '' ? true : false; 

		prc.user = orm.get('marlooUser', login);
		
		// create a new user
		if (isNewUser) {
			rc.login = lcase(rc.login);
			prc.user.setLogin(rc.login);
			prc.user.setCreatedDate(now());
		}

		// populate the user 
		orm.populate(target: prc.user, model: orm.new('marlooUser'), memento: rc, include: 'active,firstname,lastname');
		prc.user.setActive(structKeyExists(rc, 'active'));

		// validate the user
		var validationResults = validateModel(prc.user);

		// if this user already exists, abort!
		if (isNewUser AND NOT isNull(orm.get('marlooUser', rc.login))) {
			validationResults.addError(validationResults.newError(
				message = "This login is already taken",
				field = "login",
				rejectedValue = rc.login
			));
		}

		// SAVE if there are no errors 
		if (NOT validationResults.hasErrors()) {
			orm.save(prc.user);
			// remove the edit key
			structDelete(session.marlooauth.editkeys, editkey);
			setNextEvent("marlooauth:userman.listUsers");
		}

		prc.formErrors = validationResults.getAllErrorsAsStruct();
		event.setView("userman/edituser");
	}

	function deleteUser(event,rc,prc){
		// find a user 
		prc.user = orm.get('marlooUser', event.getValue('login', '-1'));
		if (isNull(prc.user)) {
			throw('Invalid user');
			abort;
		}

		orm.delete(prc.user);
		setNextEvent("marlooauth:userman.listUsers");		
	}

	function editUser(event,rc,prc){
		prc.user = orm.get('marlooUser', event.getValue('login', ''));

		prc.editKey = Hash(GenerateSecretKey("AES"), "MD5");
		session.marlooauth.editkeys["#prc.editkey#"] = prc.user.getLogin();
	}
}