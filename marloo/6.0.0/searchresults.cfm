<!--- get the config for the site --->

<cfinvoke component="siteConfig" method="getConfig" returnvariable="site_config" />

<cfset baseCFCPath = "#site_config.cfMappedPath#.#site_config.sitepath#">

<cfinvoke component="#baseCFCPath#.core.pageService" method="renderStaticTemplate">
    <cfinvokeargument name="template_name" value="searchpage">
    <cfinvokeargument name="site_config" value="#site_config#">
</cfinvoke>

