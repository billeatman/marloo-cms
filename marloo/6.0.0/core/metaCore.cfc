<cfcomponent displayname="metaCore">

<cffunction name="init" returntype="metaCore" access="public" output="false">
	<cfargument name="site_config" type="struct" required="true">
	<cfargument name="generate_open_graph" type="boolean" required="false" default="false">
	
	<cfset var og_meta_mapping = "">
	<cfset var meta = "">

	<cfset variables.generate_open_graph = arguments.generate_open_graph>

	<!--- default meta --->
	<cfset variables.meta = structNew()>
	<cfset structAppend(variables.meta, duplicate(arguments.site_config.CMS.site.meta))>

	<cfif NOT structKeyExists(variables.meta, 'name')>
		<cfset variables.meta.name = structNew()>
	</cfif>

	<!--- generate open_graph for global config meta --->
	<cfif variables.generate_open_graph>
		<cfloop list="#getOpenGraphMappings()#" index="og_meta_mapping">
			<cfif structKeyExists(variables.meta.name, og_meta_mapping)>
				<cfset meta = structNew()>
				<cfset meta["#og_meta_mapping#"] = variables.meta.name["#og_meta_mapping#"]>
				<cfset addOpenGraph(meta: meta)>
			</cfif>		
		</cfloop>
	</cfif>

	<cfreturn this>
</cffunction>

<cffunction name="addMeta" access="public" output="false">
	<cfargument name="overwrite" type="boolean" required="false" default="true">
	<cfargument name="key_attribute" type="string" required="false" default="name">

	<cfset var i = "">
	<cfset var meta = structCopy(arguments)>

	<cfset structDelete(meta, 'overwrite')>
	<cfset structDelete(meta, 'key_attribute')>
	
	<cfif structCount(meta) GT 1>
		<cfthrow message="Too many arguments!">
	</cfif>

	<cfif NOT structKeyExists(variables.meta, "#key_attribute#")>
		<cfset variables.meta['#key_attribute#'] = structNew()> 
	</cfif>
	
	<cfset structAppend(variables.meta['#key_attribute#'], meta, arguments.overwrite)>

	<cfif variables.generate_open_graph and arguments.key_attribute EQ 'name'>
		<cfset addOpenGraph(meta: meta)>
	</cfif>
</cffunction>

<cffunction name="getOpenGraphMappings" access="private" returntype="string">
	<cfreturn "title,description">
</cffunction>

<cffunction name="addOpenGraph" access="private">
	<cfargument name="meta" type="struct" required="true">

	<cfset var og_meta = structNew()>
	<cfset var meta_key = trim(lcase(structKeyList(arguments.meta)))>  

	<cfif listFindNoCase(getOpenGraphMappings(), meta_key)>
		<cfset og_meta["og:#meta_key#"] = arguments.meta['#meta_key#']>
		<cfset addMeta(argumentCollection: og_meta, overwrite: false, key_attribute: 'property')>
	</cfif>
</cffunction>

<cffunction name="renderMeta" output="true">
<cfsilent>
	
<cfset var i = "">
<cfset var attribute = "">

</cfsilent>
<cfloop collection="#variables.meta#" item="attribute">
<cfloop collection="#variables.meta['#attribute#']#" item="i">
<meta #lcase(attribute)#="#lcase(i)#" content="#variables.meta['#attribute#']['#i#']#"></cfloop> 
</cfloop>
</cffunction>

</cfcomponent>