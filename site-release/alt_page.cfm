<cfparam name="page_id" default="">
<cfparam name="history_id" default="">

<cfsilent>
<!--- get the config for the site --->
<cfinvoke component="siteConfig" method="getConfig" returnvariable="site_config" />

<cfset baseCFCPath = "#site_config.cfMappedPath#.#site_config.sitepath#">

<!--- Get the core data object --->
<cfset page = createObject("component", "#baseCFCPath#.core.page").init(
	page_id: page_id, 
	history_id: history_id, 
	site_config: site_config)>

<!--- See if page is valid and NOT required secure --->
<cfif NOT isObject(page) OR page.isSSL()>
	<cfabort>
</cfif>

<!--- create the page helper --->
<cfset ph = createObject("component", "#baseCFCPath#.core.pageHelper").init(site_config: site_config)>

<!--- Shortcode Object --->
<cfset shortCodesObject = createObject("component", "#baseCFCPath#.core.shortcodes").init(site_config: site_config)>

<cfinvoke component="#baseCFCPath#.core.renderCore" method="renderChain" returnvariable="content">
	<!--- <cfinvokeargument name="filterList" value="#variables.filterList#"> --->
	<cfinvokeargument name="content" value="#page.getInfo()#">
	<cfinvokeargument name="site_config" value="#site_config#">
	<cfinvokeargument name="pageHelper" value="#ph#">
	<cfinvokeargument name="history_id" value="#page.getPage().IDhistory#">
	<cfinvokeargument name="shortCodesObject" value="#shortCodesObject#">
</cfinvoke>
</cfsilent>

<html>
<head>
<style>
p, body {
	font-size: 14px;
	}
</style>
</head>
<body>
<cfoutput>#content#</cfoutput>
</body>
</html>

