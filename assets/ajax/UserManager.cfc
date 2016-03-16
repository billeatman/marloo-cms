<cfcomponent displayname="User Manager">
	<!--- 
      Get all users of the CMS
	  
	  optional securityGroup parameter
	--->
    <cffunction name="getAllUsers" returntype="any" access="public">				
    	<cfargument name="securityGroup" required="false" default="">
        <cfquery datasource="#application.datasource#" name="qUsers">
        	select distinct login from mrl_pageGroupMember
 		    <cfif arguments.securityGroup neq "">
            	where groupName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityGroup#">            
        	</cfif>
        </cfquery>
        
        <cfreturn qUsers>
    </cffunction>
    
    <!--- stub wrapper of the above function for remote calls --->
    <cffunction name="getAllUsersAJAX" access="remote">
    <!---
    	<cfinvoke component="JSON" method="encode" data="#users#" returnvariable="result" totalCount ="#totalRows.totalRows#" queryFormat="array"/>
		<cfoutput>
			#result#
		</cfoutput>
    --->
	</cffunction>
            
</cfcomponent>