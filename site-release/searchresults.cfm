<cfinvoke component="siteConfig" method="getConfig" returnvariable="site_config" />

<cfinvoke component="marloo.core.pageService" method="renderStaticTemplate">
    <cfinvokeargument name="template_name" value="searchpage">
    <cfinvokeargument name="site_config" value="#site_config#">
</cfinvoke>