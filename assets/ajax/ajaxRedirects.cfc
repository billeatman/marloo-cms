<cfcomponent>
	<!---Function for getting data from db.--->
    <cffunction name = "getRedirect" access="remote" output="false" returnFormat="JSON">
        
        <cfset var qUsers = "">
        <cfset var userArray = arrayNew(1)>
        <cfset var userStruct = "">
        <cfset var i = "">
    
        <cfinvoke component="userman" method="getUsers" returnvariable="qUsers" />
    
        <cfloop index="i" from="1" to="#qUsers.RecordCount#">   
            <cfset userStruct = structNew()>
            <cfset userStruct.login = "#qUsers.login[i]#">
            <cfset userStruct.key = "#qUsers.login[i]##qUsers.groupname[i]#">
            <cfset userStruct.groupname = "#qUsers.groupname[i]#">
            <cfset arrayappend(userArray, userStruct)>
        </cfloop>
    
        <cfreturn userArray>
    </cffunction>
    
    <!---Function for updating data in db.--->
    <cffunction name="updateUsers" access="remote" output="false" returnFormat="plain"> 
        <cfargument name="login" required="yes" type="string">
        <cfargument name="groupname" required="yes" type="string">
    
        <cfinvoke component="userman" method="updateUser">
            <cfinvokeargument name="login" value="#arguments.LOGIN#">
            <cfinvokeargument name="groupname" value="#arguments.GROUPNAME#">
        </cfinvoke>
        
    </cffunction>
    
    <cffunction name="createUsers" access="remote" output="false" returnFormat="plain"> 
        <cfargument name="login" type="string" required="true">
        <cfargument name="groupname" type="string" required="true">
        
        <cfinvoke component="userman" method="addUserAccess">
            <cfinvokeargument name="LOGIN" value="#arguments.LOGIN#">
            <cfinvokeargument name="GROUPNAME" value="#arguments.GROUPNAME#">
        </cfinvoke>
    </cffunction>
    
    <cffunction name="killUsers" access="remote" output="false" returnFormat="plain">
        <cfargument name="login" type="string" required="true">
     
        <cfinvoke component="userman" method="delUserAccess">
            <cfinvokeargument name="LOGIN" value="#arguments.LOGIN#">
            <cfinvokeargument name="GROUPNAME" value="#arguments.GROUPNAME#">
        </cfinvoke>
    </cffunction>
    
    <cffunction name="getGroups" access="remote" returnFormat="JSON"> 
    
        <cfinvoke component="userman" method="getGroups" returnvariable="allTheGroups" />
    
        <cfset myArray = arrayNew(1)>
        
        <cfloop index="i" from="1" to="#allTheGroups.RecordCount#">   
            <cfset myStruct = structNew()>
            <cfset mystruct.groupname = "#allTheGroups.groupname[i]#">
            <cfset arrayappend(myArray, mystruct)>
        </cfloop>
    
        <cfreturn myArray>
    </cffunction>
    
</cfcomponent>