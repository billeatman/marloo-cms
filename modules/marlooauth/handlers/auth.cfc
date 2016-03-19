component extends="coldbox.system.EventHandler"{
	property name="orm" inject="entityservice" setter=false getter=false;

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
		setNextEvent(event: "marloo-auth:auth.login");
	}

	function pwreset(event,rc,prc){
		event.setView("auth/pwreset")
	}
}
