<cfcomponent>

<cfset variables.head_code = "">
<cfset variables.site_config = "">
<cfset variables.sc = "">
<cfset variables.name = "">

<cffunction name="init" output="false" returntype="ANY">
	<cfargument name="head_code" required="true" type="struct">
	<cfargument name="site_config" required="true">

	<cfset variables.head_code = arguments.head_code>
	<cfset variables.site_config = arguments.site_config>
	<cfset variables.sc = arguments.site_config>	
	
	<cfset local.metadata = getMetaData(this)>
	<cfset variables.name = ListLast(local.metadata.name, '.')>
	
	<!--- add the run-once to the head --->
	<cfif structKeyExists(this, 'renderHeadOnce')>
	<cfsavecontent variable="local.masterHead">
	<cfset renderHeadOnce()>
	</cfsavecontent>
	
	<cfset structInsert(variables.head_code, "widget-" & variables.name, local.masterHead , false) >
	</cfif>
	
	<cfreturn this>
</cffunction>

<cffunction name="addHTMLhead">
	<cfargument name="text" required="true" type="string">
	<cfset structInsert(variables.head_code, "widget-" & variables.name & '-' & CreateUUID(), arguments.text, false) >
</cffunction>

<cffunction name="createWidget" access="public" returntype="ANY" output="false">
	<cfargument name="widgetname" type="string">
	<cfreturn createObject("widgets.#widgetname#").init(argumentCollection: arguments, head_code: variables.getHeadCode(), site_config: variables.sc)>
</cffunction>

</cfcomponent>
