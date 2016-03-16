<cfcomponent displayname="auth" output="false">
	<cffunction name="isGroup" output="false" access="remote" returntype="boolean" hint="Is group defined for a user.">
    	<cfargument name="groupname" type="string" required="yes" hint="name of group">
        <cfset var retVal = false> 
        
        <cftry>
        	<cfset retVal = isDefined("SESSION.Auth.groups.#securityGroup#")>
        <cfcatch>				        	
        </cfcatch>
        </cftry>
        
        <cfreturn retVal>
    </cffunction>
</cfcomponent>