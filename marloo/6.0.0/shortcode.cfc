<cfcomponent>

<cfset variables.head_code = "">
<cfset variables.site_config = "">
<cfset variables.sc = "">
<cfset variables.name = "">
<cfset variables.currentURL = "">

<cffunction name="init" output="false" returntype="ANY">
	<cfargument name="head_code" required="true" type="struct">
	<cfargument name="site_config" required="true">

	<cfset variables.head_code = arguments.head_code>
	<cfset variables.site_config = arguments.site_config>
	<cfset variables.sc = arguments.site_config>	
	
	<cfset local.metadata = getMetaData(this)>
	<cfset variables.name = ListLast(local.metadata.name, '.')>
	
	<!--- add the run-once to the head --->
	<!---
	<cfif structKeyExists(this, 'renderHeadOnce')>
	<cfsavecontent variable="local.masterHead">
	<cfset renderHeadOnce()>
	</cfsavecontent>
	<cfset structInsert(variables.head_code, "shortcode-" & variables.name, local.masterHead , false) >
	</cfif>
	--->

	<cfreturn this>
</cffunction>

<cffunction name="getCurrentURL">
	<cfif variables.currentURL neq "">
		<cfreturn variables.currentURL>
	<cfelse>
		<cfinvoke component="core.pageHelper" method="getCurrentURL" returnvariable="variables.currentURL">
	</cfif>

	<cfreturn variables.currentURL>
</cffunction>

<cffunction name="getCoreCFCPath">
	<cfreturn variables.sc.cfMappedPath & "." & variables.sc.sitepath & ".core">
</cffunction>

<cffunction name="addHTMLhead">
	<cfargument name="text" required="true" type="string">
	<cfset structInsert(variables.head_code, "shortcode-" & variables.name & '-' & CreateUUID(), arguments.text, false) >
</cffunction>

<cffunction name="createWidget" access="public" returntype="ANY" output="false">
	<cfargument name="widgetname" type="string">

	<cfset var baseCFCPath = "#sc.cfMappedPath#.#sc.sitepath#">

	<cfreturn createObject("#baseCFCPath#.widgets.#widgetname#").init(argumentCollection: arguments, head_code: variables.head_code, site_config: variables.sc)>
</cffunction>

<cffunction name="filterWhiteSpace" access="public" returntype="string" output="false">
	<cfargument name="s_content">
	<!--- WE - filter out trailing '<p>&nbsp;</p>' --->	
	<cfset local.content_array = listToArray(arguments.s_content, '<p>&nbsp;</p>', true, true)>

	<cfset arguments.s_content = "">
	<cfset local.stop_flag = false>

	<cfloop from="#arrayLen(local.content_array)#" to="1" index="local.i" step="-1">
		<cfif local.stop_flag NEQ true AND trim(local.content_array[local.i]) eq "">
		<cfelse>
			<cfif local.i NEQ 1>
				<cfset arguments.s_content = '<p>&nbsp;</p>' & local.content_array[local.i] & arguments.s_content>
			<cfelse>
				<cfset arguments.s_content = local.content_array[local.i] & arguments.s_content>						
			</cfif>
			<cfset local.stop_flag = true>				
		</cfif>
	</cfloop>
	<!--- end filter --->

	<cfreturn arguments.s_content>
</cffunction>


</cfcomponent>
