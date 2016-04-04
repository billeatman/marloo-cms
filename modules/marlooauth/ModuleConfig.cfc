/**
Module Directives as public properties
this.title 				= "Title of the module";
this.author 			= "Author of the module";
this.webURL 			= "Web URL for docs purposes";
this.description 		= "Module description";
this.version 			= "Module Version";
this.viewParentLookup   = (true) [boolean] (Optional) // If true, checks for views in the parent first, then it the module.If false, then modules first, then parent.
this.layoutParentLookup = (true) [boolean] (Optional) // If true, checks for layouts in the parent first, then it the module.If false, then modules first, then parent.
this.entryPoint  		= "" (Optional) // If set, this is the default event (ex:forgebox:manager.index) or default route (/forgebox) the framework
									       will use to create an entry link to the module. Similar to a default event.
this.cfmapping			= "The CF mapping to create";
this.modelNamespace		= "The namespace to use for registered models, if blank it uses the name of the module."
this.dependencies 		= "The array of dependencies for this module"

structures to create for configuration
- parentSettings : struct (will append and override parent)
- settings : struct
- datasources : struct (will append and override parent)
- interceptorSettings : struct of the following keys ATM
	- customInterceptionPoints : string list of custom interception points
- interceptors : array
- layoutSettings : struct (will allow to define a defaultLayout for the module)
- routes : array Allowed keys are same as the addRoute() method of the SES interceptor.
- wirebox : The wirebox DSL to load and use

Available objects in variable scope
- controller
- appMapping (application mapping)
- moduleMapping (include,cf path)
- modulePath (absolute path)
- log (A pre-configured logBox logger object for this object)
- binder (The wirebox configuration binder)
- wirebox (The wirebox injector)

Required Methods
- configure() : The method ColdBox calls to configure the module.

Optional Methods
- onLoad() 		: If found, it is fired once the module is fully loaded
- onUnload() 	: If found, it is fired once the module is unloaded

*/
component {

	// Module Properties
	this.title 				= "marloo auth";
	this.author 			= "";
	this.webURL 			= "";
	this.description 		= "";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "/";
	// Model Namespace
	this.modelNamespace		= "marlooauth";
	// CF Mapping
	this.cfmapping			= "marlooauth";
	// Module Dependencies
	this.dependencies 		= ['BCrypt','cborm'];

	function configure(){

		// parent settings
		parentSettings = {

		};

		// module settings - stored in modules.name.settings
		settings = {
			/*
			// Add this module to your ORM path in application.cfc. Example below: 
			this.ormSettings = {
				cfclocation = ['models', 'modules/marloo-auth/models'],
			};*/

			/*
			Defaults.  Overwride these in the app's /config/ColdBox.cfc:
  				
			settings = {
				'marlooauth' = {
					settings = {
						#USE SETTINGS FROM BELOW HERE#
					}
				}
			};

			// list your ldap servers here
			/*ldapDomains = [{
				loginDomain: "mydomain",
				ldapServer: "myldapserver",
				dcStart: "DC=mydc"	
			}],
			// simple dev password 
			simplePassword = "pass",
			// lock attempts
			lockoutAttempts = 3, 
			steps for authentication.  Order matters.

			choices are:  
				groups - checks that the login is a member of a security group
				lockout - checks that a user isn't locked out			
				ldap - checks a login against ldap servers
				simple - DEV ONLY - check a login against a simple password
			
			suggested steps:
				steps = ["groups", "lockout", "ldap"]

			dev steps:
				steps = ["simple"]

			authSteps = ['email', 'simple'] */		
		};

		/* used from bcrypt module */
		// Look for module setting overrides in parent app and override them.
		var coldBoxSettings = controller.getSettingStructure();
		if( structKeyExists( coldBoxSettings, 'marlooauth') 
			&& structKeyExists( coldBoxSettings[ 'marlooauth' ], 'settings' ) ) {
			structAppend( settings, coldBoxSettings[ 'marlooauth' ][ 'settings' ], true );
		}

		// Layout Settings
		layoutSettings = {
			defaultLayout = ""
		};

		// datasources
		datasources = {

		};

		// SES Routes
		routes = [
			// Module Entry Point
			//{pattern="/", handler="auth", action="login"},
			// Convention Route
		{	
			pattern="marlooUsers",
			handler="marlooUser",
			action = {
				GET = 'find',
				POST = 'create'
			}
		},{
			pattern="marlooSecurityGroups",
			handler="marlooSecurityGroup",
			action = {
				GET = 'find',
				POST = 'create'
			}
		},{
			pattern="ma/-numeric",
			handler="category",
			action = {
				PUT = 'update',
				DELETE = 'delete',
				GET = 'read'
			}
		},{
			pattern="shopitem",
			handler="shopitem",
			action = {
				PUT = 'update',
				DELETE = 'delete',
				GET = 'read'
			}
		},{
			pattern="/:handler/:action?"
		}
				// Find and create
		];

		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = ""
		};

		// Custom Declared Interceptors
		interceptors = [
			{class="#moduleMapping#.interceptors.securityInterceptor"}
		];

		// Binder Mappings
		binder.mapDirectory(packagePath: "#moduleMapping#.models", namespace: "@marlooauth");		
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		//var coldBoxSettings = controller.getSettingStructure();
		//writeDump(controller);

		//var modsettings = controller.getModuleSettings('marloo-auth');
		//var modsettings = controller.getSettingStructure();
		//writeDump(modsettings);
		//abort;

		/*
		if (structKeyExists( coldBoxSettings, 'marloo-auth')){
			throw(message: "marloo-auth settings not found!");
		}

		if (structKeyExists( coldboxSettings['marloo-auth'], 'steps')){
			throw(message: "Please configure settings for module marloo-auth.  Instructions in ModuleConfig.cfc");
		}*/
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}