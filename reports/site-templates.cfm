<!--- get the config for the site --->

<cfinvoke component="siteConfig" method="getConfig" returnvariable="site_config" />

<cfinvoke component="marloo.core.pageService" method="renderStaticTemplate">
    <cfinvokeargument name="template_name" value="reports.reports_templatehealth">
    <cfinvokeargument name="site_config" value="#site_config#">
</cfinvoke>
