component extends="marloo.siteconfig" output="false" {
	variables.site_config = {};

	// General
	site_config.admin = true;					// true for CMS, false for release
	site_config.datasource = application.datasource;;		// datasource for the site
	site_config.cfMappedPath = replace(application.path.assetsMapping, '/', '', 'all');	// mapped path 
	site_config.displayErrors = true;			// true for CF error screen
	site_config.rootid = application.site_config.rootid;
	site_config.showTime = true;				// true to show page load time
	site_config.useCache = false;				// true to use caching
	site_config.flushCache = false;				// true to flush the cache.
	
	// SEO
	site_config.URLrewriter = false;				// turn on URL rewriter
	site_config.useRedirectTable = false;		// use redirect lookup table for faster 
												// response and historic url redirection
}
