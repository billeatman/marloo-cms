<!--- this is the MASTER CONFIG for application.cfc --->
 <cfset application.site = structNew()>
 <cfset application.site.meta = structNew()>
 <cfset application.site.meta.name = structNew()>
 
 <cfscript>  		
		// Apps
	application.apps = structNew();
	application.apps.enabled = true;
	application.apps.list = "fileapp"; 	

	// Enable disable debug menu
	application.debug = true;
	application.auth.lockout = 3;				   // Number of tries before account lockout

	// Config Site
	application.ssl = true;					   // Enable/Disable SSL
	application.datasource = "marloo";		   // Datasource for this site
	application.pagename = "page.cfm";			   // cfm template page
    application.idvar = "page_ID"; 				   // URL ID var
	//application.mods = "dis";				   // Mod to use path /mods/%mods%
	application.editor = "default";				   // Template editor to use
	application.menutext = false;
	application.marlooVersion = '6.0.0 Beta 3';
	
	// Strings
	application.name = "Marloo CMS";	   			// Name of this application
	application.sitename = "Example";				// Site Name
    application.idname = "ID";					// What we call ids within the editor   
	application.pagedesc = "Page";				// What we call pages within the editor

	// Local Paths			
	application.path.groups = "X:\inetpub\example\sitefiles\";	// CFFM (File Manager) local root path
	application.path.siteroot = "X:\inetpub\example";
	application.path.editorRoot = GetDirectoryFromPath(GetCurrentTemplatePath());  
	application.path.assetsMapping = "/marloo-includes/";

	// component root
	application.componentRoot = "marloo_admin";	   // shortened editor root 
	application.domain = ".example.com";	   // Domain needed for editor 

	// Web Paths
	application.web.groups = "//www.example.com/sitefiles/";		// Web Path root to user files 		
	application.web.siteRoot = "//www.example.com/";  			// Web Path to the site root
	application.web.editorRoot = "//marloo_admin/";	//Web path to the editor
	
	// Tree Config
	application.tree.rootText = "Homepage";	// The name of the tree root
	application.tree.rootId = 0;			// The page id for the root
	application.tree.crumbIndex = 1;  		// 1 or 0 needed for other sites that have editable roots OR SITES WHERE THE ROOT ID DOES NOT EXIST!
	application.tree.alphaOrder = false;	// whether to use alpha order or custom order.

	// Site root config
	application.root = structNew();
	application.root.static = false;

	// Page Security Groups
	/* NEW */ 
	application.defaultTemplate = "default";		// default template
	application.securitygroups.default = "default";		// The default security group to use for initial pages or pages where there is no parent

	// Site Global Meta Data
	application.site.meta.name = {
		"keywords" = "hello world, asdf"
		// put other meta data here
	};

	// Open Graph metadata http://ogp.me/... used for facebook
	application.site.meta.property = {
		"og:site_name" = "mysite"
		,"og:locale" = "en_us"
	};

	// places for search api keys
	application.searchAPIKeys = {
		"google" = "something:something" 
	};

	// SUFFIX - PAGETITLE 
	application.site.titleSuffix = "My Site";

	// Approver / Admin emails (comma delimited)
	application.mail = "billeatman@example.com";

</cfscript>
