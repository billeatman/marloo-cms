<cfcomponent displayname="Security Manager">
	<cffunction name="getMySecurityGroups" access="public" returntype="query">
	<!--- Change to this when time permits!!! --->
<!--- 		<cfstoredproc datasource="#application.datasource#" procedure="mrl_userGroups">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
  <cfprocresult name="qGroups">
</cfstoredproc>
--->
        
        <cfquery datasource="#application.datasource#" name="qSecurityGroups">
        	select * from mrl_pageGroup where type = 'pagegroup' and GroupName in (select distinct GroupName from mrl_pageGroupMember where [login] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.auth.user.login#">)
        </cfquery>
		<cfreturn qSecurityGroups>
    </cffunction>

	<cffunction name="getAllSecurityGroups" access="public" returntype="query">
   		<cfquery datasource="#application.datasource#" name="qSecurityGroups">
        	select * from mrl_pageGroup where type = 'pagegroup' 
            order by groupDesc ASC
        </cfquery>
		<cfreturn qSecurityGroups>
	</cffunction>    
    
    
    
    <!--- used with securitybrowser tree plugin --->
    <cffunction name="getSecurityChecks" access="remote" returnformat="JSON">
    	<cfset var qGroups = getAllSecurityGroups()>
        
		<cfset masterArray = arraynew(1)>
        <cfset checkArray = arraynew(1)>
        <cfset i = 0>
        <cfloop query="qGroups">
            <cfif i gt 22>
            	<cfset i = 0>
                <cfset itemSt = structnew()>
                <cfset itemSt['defaultType'] = 'checkbox'>
                <cfset itemSt['items'] = checkArray>
                <cfset arrayAppend(masterArray, itemSt)>
            	<cfset checkArray = arraynew(1)>
			</cfif>
			<cfset checkbox = structnew()>
            
			<cfset checkbox['boxLabel'] = qGroups.groupdesc>
			<cfset checkbox['name'] = qGroups.groupname>
			<cfset checkbox['hideLabel'] = true>
            
            <cfset arrayAppend(checkArray, checkbox)>
 	      	<cfset i = i + 1>		            
        </cfloop>
        
              <cfset itemSt = structnew()>
                <cfset itemSt['defaultType'] = 'checkbox'>
                <cfset itemSt['items'] = checkArray>
                <cfset arrayAppend(masterArray, itemSt)>
            	<cfset checkArray = arraynew(1)>
 
 		<cfreturn masterArray>   
    </cffunction>
    
    
</cfcomponent>