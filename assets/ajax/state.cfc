<cfcomponent displayname="get page state information">
		<!--- returns a state icon based on state and visibility --->
	<cffunction name="getStateInfo" access="remote" returntype="struct" output="no" returnformat="JSON">
		<cfargument name="state" default="approved">
        <cfargument name="visible" default="true">	    
        
         <!--- states:  approved, preview, *stub, *denied, *draft, *pending --->    
            <cfswitch expression="#state#">
                <cfcase value="stub">
                	<cfset icon="assets/images/stub">
	                <cfset text="New Page">
                </cfcase>
	            <cfcase value="denied">
                	<cfset icon="assets/images/redpen">
                	<cfset text="Edits Needed">
                </cfcase>
	            <cfcase value="pending">
                	<cfset icon="assets/images/glasses">
                	<cfset text="Pending Review">
                </cfcase>
	            <cfcase value="draft">
                	<cfset icon="assets/images/bluepen">
                	<cfset text="Draft">
                </cfcase>
                <cfdefaultcase>
                	<cfset icon="assets/images/lined_16">
                	<cfset text="Approved">
                </cfdefaultcase>
            </cfswitch>

			<!--- add hidden class --->
			<cfif visible eq false>
	    	    <cfset icon = Insert("b", icon, len(icon))>
            </cfif>  
            <!--- append the file extension --->
   	    	<cfset icon = Insert(".png", icon, len(icon))>
            
            <cfset stateStruct = structNew()>
            <cfset stateStruct.icon = icon>
            <cfset stateStruct.text = text>
                                      	
		<cfreturn stateStruct>    
    </cffunction>

</cfcomponent>