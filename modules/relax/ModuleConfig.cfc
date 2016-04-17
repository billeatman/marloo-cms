/**
* Copyright Ortus Solutions, Corp, All rights reserved
* www.ortussolutions.com
* ---
*/
component{

	// Module Properties
	this.title 				= "ColdBox Relax";
	this.author 			= "Ortus Solutions";
	this.webURL 			= "http://www.ortussolutions.com";
	this.description 		= "RESTful Tools For Lazy Experts";
	this.version			= "2.2.0+00032";
	this.viewParentLookup 	= true;
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "relax";
	// Model Namespace
	this.modelNamespace		= "relax";
	// CF Mapping
	this.cfmapping			= "relax";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies That Must Be Loaded First, use internal names or aliases
	this.dependencies		= [];

	/**
	* Configure App
	*/
	function configure(){
		// Layout Settings
		layoutSettings = { defaultLayout = "relax.cfm" };

		// SES Routes
		routes = [
			// Module Entry Point
			{ pattern="/", handler="home", action="index" },
			// Convention Route
			{ pattern="/:handler/:action?" }
		];

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		var configSettings = controller.getConfigSettings();
		// parse parent settings
		parseParentSettings();
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
	}

	/**
	* Pre process for relax, makes sure an API is loaded
	*/
	function preProcess( event, interceptData ) eventPattern="^relax.*"{
		var DSLService = wirebox.getInstance( "DSLService@relax" );
		// load the default API if none loaded
		if( !DSLService.isLoadedAPI() ){
			DSLService.loadAPI( controller.getConfigSettings().relax.defaultAPI );
		}
	}

	/**
	* Prepare settings and returns true if using i18n else false.
	*/
	private function parseParentSettings(){
		/**
		Sample:
		relax = {
			// The location of the relaxed APIs, defaults to /models/resources
			APILocation = "#appMapping#.models.resources",
			// Default API to load
			defaultAPI = "myapi",
			// History stack size, the number of history items to track in the RelaxURL
			maxHistory = 10
		};
		*/
		// Read parent application config
		var oConfig 		= controller.getSetting( "ColdBoxConfig" );
		var relaxDSL		= oConfig.getPropertyMixin( "relax", "variables", structnew() );
		var configStruct 	= controller.getConfigSettings();

		// Default Config Structure
		configStruct.relax = {
			APILocation 	= "#moduleMapping#.models.resources",
			defaultAPI 		= "myapi",
			maxHistory		= 10,
			sessionsEnabled	= getApplicationMetadata().sessionManagement
		};

		// Apend it
		structAppend( configStruct.relax, relaxDSL, true );

		/** 
		*  As a convenience, turn off flash auto-saves if sessions are disabled, 
		*  or requestEnd errors will be thrown
		**/
		if( !configStruct.relax.sessionsEnabled && controller.getSetting( "flash" ).scope == 'session' ){
			controller.getSetting( "flash" ).autoSave = false;
		}

		// expand the location path
		configStruct.relax.APILocationExpanded = expandPath( "/#replace( configStruct.relax.APILocation, ".", "/", "all" )#" );
	}

}