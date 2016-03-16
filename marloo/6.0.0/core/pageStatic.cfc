<cfcomponent displayName="pageStatic">

<cfset variables.pageTitle = "">
<cfset variables.textDescription = "">
<cfset variables.ssl = false>
<cfset variables.modifiedDate = now()>
<cfset variables.ownerEmail = "">

<cffunction name="init" access="public" returntype="pageStatic">
	<cfreturn this>
</cffunction>

<cffunction name="isStatic" access="public" returntype="boolean">
   	<cfreturn true>
</cffunction>
   
<cffunction name="getID" access="public" output="false">
   	<cfreturn -1>
</cffunction>

<cffunction name="getPageTitle" access="public" output="false">
	<cfreturn variables.pageTitle>
</cffunction>

<cffunction name="getTitle" access="public" returntype="string" output="false">
	<cfreturn getPageTitle()>	
</cffunction>

<cffunction name="setModifiedDate" access="public" output="false">
	<cfargument name="date" type="date" required="true">
	<cfset variables.modifieddate = arguments.date>
</cffunction>

<cffunction name="getModifiedDate" access="public" output="false" returntype="date">
	<cfreturn variables.modifiedDate>
</cffunction>

<cffunction name="setOwnerEmail" access="public" output="false">
	<cfargument name="email" type="string" required="true">
	<cfset variables.ownerEmail = arguments.email>
</cffunction>

<cffunction name="getOwnerEmail" access="public" output="false" returntype="string">
	<cfreturn variables.ownerEmail>
</cffunction>

<cffunction name="setTitle" access="public" returntype="string" output="false">
	<cfreturn setPageTitle(argumentCollection: arguments)>	
</cffunction>

<cffunction name="setPageTitle" access="public" output="false">
  	<cfargument name="pageTitle" type="string" required="true">
   	
	<cfset variables.pageTitle = arguments.pageTitle>
</cffunction>

<cffunction name="isSSL" access="public" output="false">
	<cfargument name="SSL" type="boolean" required="false">

	<cfif NOT isNull(arguments.ssl)>
		<cfset variables.ssl = arguments.SSL>
	</cfif>

	<cfreturn variables.ssl>
</cffunction>

<cffunction name="getTextDescription" access="public" returntype="string" output="false">
  	<cfargument name="maxLength" type="numeric" required="no" default="100">
  	<cfargument name="minLength" type="numeric" required="no" default="75">
    <cfargument name="nearestSentence" type="boolean" required="false" default="false">
       
	<cfset var myTextDescription = "">

	<cfinvoke component="utilityCore" method="stringToSummary" returnvariable="mytextDescription">
		<cfinvokeargument name="maxLength" value="#arguments.maxLength#">
        <cfinvokeargument name="minLength" value="#arguments.minLength#">
        <cfinvokeargument name="nearestSentence" value="#arguments.nearestSentence#">
		<cfinvokeargument name="sourceStr" value="#variables.textDescription#">
	</cfinvoke>
	
    <cfreturn myTextDescription>
</cffunction>
	
<cffunction access="public" name="getSecurityGroup" output="false" returntype="string">
	<cfreturn "">
</cffunction>
	
<cffunction name="setTextDescription" access="public" returntype="void" output="false">
	<cfargument name="textDescription" type="string" required="true">

	<cfset variables.textDescription = arguments.textDescription>
</cffunction>


</cfcomponent>