<cfcomponent displayname="formUtility" hint="helper functions for handling form data.">
	<cffunction name="cleanFormScope" access="public" output="false" hint="prevents xss attacks using HTMLEditFormat.">
		<cfargument name="maxItems" type="numeric" required="no" default="500" hint="max number of characters allowed.">
        <cfargument name="formScope" type="struct" required="yes" hint="data from your form.">
        
        <cfset var LOCAL = structNew()>
        <cfset LOCAL.retval = true>
        
		<!--- clean form vars --->
		<cfset LOCAL.formItemMax = 0>
		<cfloop collection="#arguments.formScope#" item="item">
		   	<cfset LOCAL.formItemMax = LOCAL.formItemMax + 1>
			<cfset arguments.formScope['#item#'] = HTMLEditFormat(arguments.formScope['#item#'])>
			<cfif LOCAL.formItemMax GT 50>
   				<cfset LOCAl.retval = false>
                <cfbreak>
            </cfif>
		</cfloop>
		
        <cfreturn LOCAL.retval>
    </cffunction>
</cfcomponent>