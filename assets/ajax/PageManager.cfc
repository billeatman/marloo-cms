<cfcomponent displayname="PageManager">
	<!---
    	Returns all page attributes as a structure
    --->
    <cffunction name="getPageAttributes" access="public" returntype="any"> 
    	<cfargument name="page_id" required="false" type="numeric">
		  <cfset page = createObject("component", "marloo.core.page").init(page_id: page_id, site_config: application.site_config)>    	
      	  <cfset qPage = page.getPage()>
        
          <cfset page_properties = new marloo.core.queryhelper(qPage).toArray()>
        <cfreturn page_properties[1]> 
    </cffunction>    
    
    <cffunction name="validateAttribute" access="private" output="false">
		<cfargument name="attribute" required="true" type="string">
        <cfset var retVal = structNew()>
        <cfset var myattribute = "">
        <cfset var valid = false>
        <cfset var type = "">

		<cfset arguments.attribute = trim(lcase(arguments.attribute))>

        <cfswitch expression="#arguments.attribute#">
        	<cfcase value="idshortcut">
            	<cfset myattribute = "idshortcut">
                <cfset type = "cf_sql_integer">
            </cfcase>
        	<cfcase value="shortcuttype">
            	<cfset myattribute = "shortcuttype">
                <cfset type = "cf_sql_integer">
            </cfcase>
        	<cfcase value="shortcutexternal">
            	<cfset myattribute = "shortcutexternal">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="state">
            	<cfset myattribute = "state">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="visible">
            	<cfset myattribute = "visible">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="createddate">
            	<cfset myattribute = "createddate">
                <cfset type = "cf_sql_timestamp">
            </cfcase>
        	<cfcase value="createdby">
            	<cfset myattribute = "createdby">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="deleted">
            	<cfset myattribute = "deleted">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="locked">
            	<cfset myattribute = "locked">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="lockedby">
            	<cfset myattribute = "lockedby">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="lockeddate">
            	<cfset myattribute = "lockeddate">
                <cfset type = "cf_sql_timestamp">
            </cfcase>
        	<cfcase value="idhistory">
            	<cfset myattribute = "idhistory">
                <cfset type = "cf_sql_integer">
            </cfcase>
        	<cfcase value="idparent">
            	<cfset myattribute = "idparent">
                <cfset type = "cf_sql_integer">
            </cfcase>
        	<cfcase value="securitygroup">
            	<cfset myattribute = "securitygroup">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="quicklink">
            	<cfset myattribute = "quicklink">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="app">
            	<cfset myattribute = "app">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="gmodifiedby">
            	<cfset myattribute = "gmodifiedby">
                <cfset type = "cf_sql_varchar">
            </cfcase>
        	<cfcase value="gmodifieddate">
            	<cfset myattribute = "gmodifieddate">
                <cfset type = "cf_sql_timestamp">
            </cfcase>
           	<cfcase value="owner">
            	<cfset myattribute = "owner">
                <cfset type = "cf_sql_varchar">
            </cfcase>
            <cfcase value="template">
            	<cfset myattribute = "template">
                <cfset type = "cf_sql_varchar">
            </cfcase>
            <!--- added 01/04/2016 --->
            <cfcase value="reviewedby">
                <cfset myattribute = "reviewedby">
                <cfset type = "cf_sql_varchar">
            </cfcase>
            <cfcase value="revieweddate">
                <cfset myattribute = "revieweddate">
                <cfset type = "cf_sql_timestamp">
            </cfcase>
            <cfcase value="ssl">
                <cfset myattribute = "ssl">
                <cfset type = "cf_sql_varchar">
            </cfcase>
	   	</cfswitch>
		
        <cfset retVal.type = type>
        <cfset retVal.attribute = myattribute>
 
		<cfif myattribute neq "">
        	<cfset valid = true>
        </cfif>
        
		<cfset retVal.valid = valid>
           
		<cfreturn retVal>
	</cffunction>
    
    <cffunction name="setAttribute" access="public" output="false" returntype="struct" returnFormat="JSON"> 
    	<cfargument name="page_id" required="true" type="numeric">
    	<cfargument name="attribute" required="true" type="string">
        <cfargument name="value" required="true" type="any">
		<cfset var myattribute = "">
        <cfset var retval = structNew()>
        <cfset var securitygroup = "">
        <cfset var response = "">
        <cfset var arrayIds = arrayNew(1)>

		<cfset var pageData = "">
        
        <cfset retval.success = true>
        <cfset retval.page_id = arguments.page_id>
        
       	<!--- Check security --->
        <cfset securitygroup = getAttribute(arguments.page_id, "securitygroup")>
		<cfif securitygroup NEQ "">
        	<cfif NOT isdefined("session.auth.groups.#securitygroup#")>
            	<cfset retval.success = false>
                <cfset retval.message = "Not Authenticated">
                <cfset retval.code = "auth">
                <cfreturn retval>
            </cfif>
        <cfelse>
          	<cfset retval.success = false>
            <cfset retval.message = "Invalid Page ID">
            <cfset retval.code = "pageid">
            <cfreturn retval>        	
        </cfif>	

        <cfset myattribute = validateAttribute(arguments.attribute)>
        <cfif myattribute.valid NEQ true>
        	<cfset retval.success = false>
            <cfset retval.message = "Invalid Attribute">
            <cfset retval.code = "attribute">
            <cfreturn retval>
        </cfif>
        
        <!--- Check for duplicate URLS --->
        <cfif myattribute.attribute EQ "visible" AND arguments.value EQ 'T'>
            <cfinvoke component="ajaxPage" method="duplicateURLCheck" returnvariable="LOCAL.response">
                <cfinvokeargument name="page_id" value="#arguments.page_id#">
            </cfinvoke> 
			<cfif LOCAL.response.duplicate EQ true>
				<cfset retval.success = false>
                <cfset retval.message = "URL Duplicate">
                <cfset retval.code = "urlduplicate">
                <cfset retval.details = LOCAL.response>
                <cfreturn retval>
            </cfif>
        </cfif>

        <cfquery datasource="#application.datasource#" result="qResult">
            update mrl_page
            set #myattribute.attribute# 
            = <cfqueryparam cfsqltype="#myattribute.type#" value="#arguments.value#" null="#trim(arguments.value) EQ ''#">
            where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
        </cfquery>
        
        <!--- SEO crap - update the redirects table --->
        <cfif attribute EQ "visible">            
    		<cfinvoke component="core.redirects" method="optimizeID" >
    			<cfinvokeargument name="page_id" value="#arguments.page_id#">
                <cfinvokeargument name="force" value="true">
    		</cfinvoke>
        </cfif>

		<!--- 
		<cflock name="#application.applicationname#redirects" timeout="180" type="exclusive" > 			           
			<!--- get the history id for the id --->
			<cfinvoke component="ajaxPage" method="getLatestDraft" returnvariable="pageData"  >
				<cfinvokeargument name="page_id" value="#arguments.page_id#" >
			</cfinvoke>
			
			<cfinvoke component="core.redirects" method="addHistoryId" >
				<cfinvokeargument name="history_id" value="#pageData.data.idhistory#" >
			</cfinvoke>
		</cflock>
        --->
		
        <cfif retval.success NEQ true>
        	<cfreturn retval>
        </cfif>
        
        <cfif qresult.recordcount NEQ 1>
        	<cfset retval.success = false>
            <cfset retval.message = "Error Updating Page">
            <cfset retval.code = "update">
        </cfif>
		
        <cfreturn retval>
    </cffunction>
    
    <cffunction name="SetAttributes" access="remote" output="false" returntype="array" returnFormat="JSON">
        <cfargument name="page_id" required="true" type="numeric">
    	<cfargument name="attribute" required="true" type="string">
        <cfargument name="value" required="true" type="any">
        <cfargument name="recursive" required="false" type="boolean" default="false">
        
		<cfset var qPageSubs = "">
        <cfset var attrib = arguments.attribute>
        <cfset var arrayIds = arrayNew(1)>    
        <cfset var pageSet = "">
        
        <cfif arguments.recursive EQ true>
			<cflock name="#application.applicationname#SetAttributesRecursive" timeout="360" type="exclusive" >    
			<!--- check for subs --->
            <cfquery datasource="#application.datasource#" name="qPageSubs">
                select id from 
                mrl_siteAdmin where idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#"> and deleted != 'T'
            </cfquery> 	
            
            <cfif qPageSubs.getRowCount() gt 0> 
                <cfloop query="qPageSubs">
                    <cfset arrayIds.addAll(SetAttributes(page_id: qPageSubs.id, attribute: attrib, value: arguments.value, recursive: true))>
                </cfloop> 
            </cfif>
			</cflock>
		</cfif>
       	
		<cfset pageSet = setAttribute(page_id: arguments.page_id, attribute: attrib, value: value)>
        
		<cfset ArrayAppend(arrayIds, pageSet)>
    
        <cfreturn arrayIds>
    </cffunction> 
    
    <cffunction name="getAttributes" access="remote" output="false" returntype="array" returnformat="JSON">
    	<cfargument name="requestArray" required="true" type="string">
        
        <cfset arguments.requestArray = deserializeJSON(arguments.requestArray)>
        
        <cfset LOCAL = structNew()>
        <cfset var attribArray = arrayNew(1)>
        
        <cfloop array="#arguments.requestArray#" index="LOCAL.i"> 
        	<cfset LOCAL.i.value = getAttribute(page_id: LOCAL.i.page_id, attribute: LOCAL.i.attribute)>
        </cfloop>

		<cfreturn arguments.requestArray>        
    </cffunction>
    
    <cffunction name="getAttribute" access="public" output="false" returntype="any" returnformat="JSON">
   		<cfargument name="page_id" required="true" type="numeric">
    	<cfargument name="attribute" required="true" type="string">
 		<cfset var myattribute = "">
        
        <cfset myattribute = validateAttribute(arguments.attribute)>
        
        <cfif myattribute.valid eq true>
            <cfquery datasource="#application.datasource#" result="qResult" name="qReturn">
                select #myattribute.attribute# as 'attribute'  <!--- myattribute.attribute is hard coded and safe --->
                from mrl_page
                where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
            </cfquery>           
        <cfelse>
        	<cfreturn>
        </cfif>
        
        <cfif qresult.recordcount eq 1>
        	<cfreturn qReturn.attribute>
        <cfelse>
        	<cfreturn>
        </cfif>
        
        
    </cffunction>
       
</cfcomponent>    
    