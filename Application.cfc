/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/

component{
	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING   = "/";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE 	 = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY 		 = "";
	// JAVA INTEGRATION: JUST DROP JARS IN THE LIB FOLDER
	// You can add more paths or change the reload flag as well.
	this.javaSettings = { loadPaths = [ "lib" ], reloadOnChange = true };

	// Application properties
	this.name = hash( getCurrentTemplatePath() );
	this.scriptProtect = "none";
	this.loginstorage = "session";
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,10,0);
	this.setClientCookies = true;
	this.mappings[ "/cborm" ] = COLDBOX_APP_ROOT_PATH & "modules/cborm";
	this.datasource = "marloo-cms";
	this.ormEnabled = true;
	this.ormSettings = {
		cfclocation = ['models', 'modules/marlooauth/models'],
	    dbcreate    = "none",
	    logSQL		= false,
	    flushAtRequestEnd 	= false,
	    autoManageSession 	= false,
	    eventHandling   	= true,
	    eventHandler      	= "cborm.models.EventHandler"
	};
	// application start
	public boolean function onApplicationStart(){
		application.cbBootstrap = new coldbox.system.Bootstrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );
		application.cbBootstrap.loadColdbox();
		return true;
	}

	// request start
	public boolean function onRequestStart(String targetPage){
		// Process ColdBox Request

		ormreload();
		sleep(250);
	//	ormflush();

		application.cbBootstrap.onRequestStart( arguments.targetPage );
	
		return true;
	}

	public void function onSessionStart(){
		application.cbBootStrap.onSessionStart();
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection=arguments );
	}

	public boolean function onMissingTemplate( template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection=arguments );
	}
}