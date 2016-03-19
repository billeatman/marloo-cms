<cfcomponent output="false" accessors="true">

<cfset variables.message = "">
<cfset variables.detail = "">
<cfset variables.code = "">
<cfset variables.error = false>

<cffunction name="init" returntype="error">
	<cfreturn this>
</cffunction>

<cffunction name="setError" returntype="void">
	<cfargument name="message" type="string" required="true">
	<cfargument name="detail" type="string" required="false" default="">
	<cfargument name="code" type="string" required="false" default="">

	<cfset variables.error = true>
	<cfset variables.message = arguments.message>
	<cfset variables.detail = arguments.detail>
	<cfset variables.code = arguments.code>
</cffunction>

<cffunction name="getErrorStruct" access="public" returntype="struct">
    <cfset var errorStruct = structNew()>
    <cfset errorStruct.message = variables.message>
    <cfset errorStruct.detail = variables.detail>
    <cfset errorStruct.code = variables.code>
    <cfset errorStruct.error = variables.error>

    <cfreturn errorStruct>
</cffunction>    

<cffunction name="throw" hint="Same parameters as setError">
	<cfset var throwMessage = "">

	<!--- See if we are also trying to set the error attributes --->
	<cfif structKeyExists(arguments, "message")>		
		<cfset setError(argumentCollection: arguments)>
	</cfif>

	<cfif variables.message eq "">
		<cfthrow message="Error - A message is required for errors to be thrown.">
	</cfif>

	<cfif variables.code NEQ "">
		<cfset throwMessage = "Code: " &  variables.code & " - " & variables.message> 
	</cfif>

	<cfthrow message="#throwMessage#" detail="#variables.detail#">
</cffunction>

<cffunction name="isError" returntype="boolean">
	<cfreturn variables.error>
</cffunction>

<cffunction name="clearError" returntype="void">
	<cfset variables.error = false>
	<cfset variables.message = "">
	<cfset variables.detail = "">
</cffunction>

</cfcomponent>