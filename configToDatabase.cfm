<!--- Sets the current application var to a serialized string in the config db table --->
<cfinclude template="config.cfm">

<cfinvoke component="assets.ajax.core.configToDatabase" method="isConfigCurrent" returnvariable="isConfigCurrent">
	<cfinvokeargument name="applicationName" value="#application.applicationName#">
</cfinvoke>

<cfif isConfigCurrent EQ true>
	<h2>Config is already up to date</h2>
<cfelse>
	<h2>Config has been updated!</h2>
</cfif>

<cfinvoke component="assets.ajax.core.configToDatabase" method="configToDatabase">

<cfquery datasource="#application.datasource#" name="qConfig">
	select top 1 config from mrl_siteConfig order by [datetime] desc
</cfquery>	

<cfdump var="#DeserializeJSON(qConfig.config)#"><br />

