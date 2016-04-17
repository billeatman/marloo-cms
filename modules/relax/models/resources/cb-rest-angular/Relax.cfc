<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	Relax Resources Definition.  For documentation on how to build this CFC
	look at our documenation here: http://wiki.coldbox.org/wiki/Projects:Relax.cfm

	The methods you can use for defining your RESTful service are:

	// Service is used to define the service
	- service(title:string,
			  description:string,
			  entryPoint:string or struct
			  extensionDetection:boolean,
			  validExtensions:list,
			  throwOnInvalidExtensions:boolean);

	// GlobalHeader() is used to define global headers which can be concatenated
	- globalHeader(name:string, description:string, required:boolean, default:any, type:string);

	// globalParam() is used to define global params which can be concatenated
	- globalParam(name:string, description:string, required:boolean, default:any, type:string);

	// Resources are defined by concatenating the following methods
	// The resource() takes in all arguments that match the SES addRoutes() method
	resource(pattern:string, handler:string, action:string or struct)
		.description(string)
		.methods(string or list)
		.header(name:string, description:string, required:boolean, default:any, type:string)
		.param(name:string, description:string, required:boolean, default:any, type:string)
		.placeholder(name:string, description:string, required:boolean, default:any, type:string)
		.schema(format:string, description:string, body:string)
		.sample(format:string, description:string, body:string);

----------------------------------------------------------------------->
<cfcomponent output="false">
<cfscript>

	// I save the location of this CFC path to use resources located here
	variables.dirPath = getDirectoryFromPath( getMetadata(this).path );

	function configure(){

		/************************************** SERVICE DEFINITION *********************************************/

		// This is where we define our RESTful service, this is usually
		// our first place before even building it, we spec it out.
		this.relax = {
			// Service Title
			title = "CB-REST-ANGULAR",
			// Service Description
			description = "A very cool RESTFul Service",
			// Service entry point, can be a single string or name value pairs to denote tiers
			entryPoint = {
				dev  = "http://api.cbrestangular.local/index.cfm",
				production = "http://api.cbrestangular.local/index.cfm"
			},
			// Does it have extension detection via ColdBox
			extensionDetection = false,
			// Valid format extensions
			validExtensions = "json",
			// Does it throw exceptions when invalid extensions are detected
			throwOnInvalidExtension = false
		};

		/************************************** GLOBAL PARAMS +  HEADERS *********************************************/

		// Global API Headers
		globalHeader(name="apiKey",description="The api key needed for request authentication.",required=true);
		globalHeader(name="token",description="The token for request authentication.",required=true);

		// Global API Parameters
		//globalParam(name="token",description="The token for request authentication.",required=true);

		/************************************** RESOURCES *********************************************/
		resource(pattern="/api/v1/auth/login", handler="v1.security", action="doLogin")
			.description("logs in user.")
			.methods("POST")
			.param(name="username", type="string", description="Username", required=true)
			.param(name="password", type="string", description="Password", required=true)
			.param(name="rememberMe", type="string", description="RememberMe", required=false)
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/login/success.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/login/failure.json"));
		resource(pattern="/api/v1/auth/logout", handler="v1.security", action="doLogout")
			.description("logs out user.")
			.methods("POST")
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/logout/success.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/logout/failure.json"));
		resource(pattern="/api/v1/auth/changePassword", handler="v1.security", action="doChangePassword")
			.description("changes user password.")
			.methods("POST")
			.param(name="username", type="string", description="Username", required=true)
			.param(name="password", type="string", description="Password", required=true)
			.param(name="newPassword", type="string", description="New Password", required=true)
			.param(name="newPassword_Confirm", type="string", description="New Password Confirmation", required=true)
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/changePassword/success.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/changePassword/failure.json"));
		resource(pattern="/api/v1/permission/list", handler="v1.permission", action="list")
			.description("lists permissions.")
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/permission/list.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/permission/failure.json"));
		resource(pattern="/api/v1/permission/getPermissions", handler="v1.permission", action="getPermissions")
			.description("gets permissions.")
			.methods("GET,POST,DELETE")
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/permission/getPermissions.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/permission/failure.json"));
		resource(pattern="/api/v1/permission/:permissionID", handler="v1.permission", action={get='get', post='save', delete='delete'})
			.description("get permission.")
			.param(name="permissionID", type="numeric", description="ID of the permission", required=false)
			.sample(format="json", description="GET result.", body=fileRead("#dirPath#samples/permission/get.json"))
			.sample(format="json", description="POST result.", body=fileRead("#dirPath#samples/permission/save.json"))
			.sample(format="json", description="DELETE result.", body=fileRead("#dirPath#samples/permission/delete.json"));
		resource(pattern="/api/v1/user/list", handler="v1.user", action="list")
			.description("lists users.")
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/user/list.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/user/failure.json"));
		resource(pattern="/api/v1/user/getUsers", handler="v1.user", action="getUsers")
			.description("gets users.")
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/user/getUsers.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/user/failure.json"));
		resource(pattern="/api/v1/user/:userID", handler="v1.user", action={get='get', post='save', delete='delete'})
			.description("get user.")
			.methods("GET,POST,DELETE")
			.param(name="userID", type="numeric", description="ID of the user", required=false)
			.sample(format="json", description="GET result.", body=fileRead("#dirPath#samples/user/get.json"))
			.sample(format="json", description="POST result.", body=fileRead("#dirPath#samples/user/save.json"))
			.sample(format="json", description="DELETE result.", body=fileRead("#dirPath#samples/user/delete.json"));
		resource(pattern="/api/v1/role/list", handler="v1.role", action="list")
			.description("lists roles.")
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/role/list.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/role/failure.json"));
		resource(pattern="/api/v1/role/getRoles", handler="v1.role", action="getRoles")
			.description("gets roles.")
			.sample(format="json", description="The return information.", body=fileRead("#dirPath#samples/role/getRoles.json"))
			.sample(format="json", description="Example response if an error occured", body=fileRead("#dirPath#samples/role/failure.json"));
		resource(pattern="/api/v1/role/:roleID", handler="v1.role", action={get='get', post='save', delete='delete'})
			.description("get role.")
			.methods("GET,POST,DELETE")
			.param(name="roleID", type="numeric", description="ID of the role", required=false)
			.sample(format="json", description="GET result.", body=fileRead("#dirPath#samples/role/get.json"))
			.sample(format="json", description="POST result.", body=fileRead("#dirPath#samples/role/save.json"))
			.sample(format="json", description="DELETE result.", body=fileRead("#dirPath#samples/role/delete.json"));
	}
</cfscript>
</cfcomponent>