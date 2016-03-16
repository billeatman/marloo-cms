<cfcomponent displayName="Tree Functions" output="false">
	<cffunction name="movePage" access="remote" returntype="struct" returnformat="JSON" output="false" >    
        <cfargument name="page_id" type="numeric" required="yes">
        <cfargument name="oldParent" type="numeric" required="yes">
        <cfargument name="newParent" type="numeric" required="yes">
        <cfargument name="index" type="numeric" required="yes">    
        
		<cfset var LOCAL = structNew()>
        <cfset var retval = structNew()>
        <cfset var error = false>
        <cfset var logdate = "">

		<!--- get three pages, page_id, oldparent, and newParent --->        
        <CFQUERY DATASOURCE="#application.datasource#" NAME="qPages">
            SELECT securityGroup, id, idParent
            FROM mrl_siteAdmin
            WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#"> OR id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.oldParent#"> OR id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newParent#">
        </CFQUERY>
		
        
		<!--- default is tree root value, this ensures we don't get a crash when adding under the root --->
        <cfif isdefined("application.tree.rootid")>
			<cfset newSecurityGroup = 'toppagelevel'>
    	</cfif>
            
        <!--- Auth - Can Move Pages --->    
        <cfif not isDefined("SESSION.Auth.groups.pagemove")>
        	<cfset error = true>
            <cfset retval.message = "error - PageMove NOT defined">
            <cfset retval.code = "auth">
            <cfheader statuscode="500" statustext="auth">
            <cfreturn retval>
        </cfif>
            
        <!--- Authentication check all three pages for auth --->
        <cfoutput query="qPages">
            <cfif not isDefined("SESSION.Auth.groups.#qPages.securityGroup#")>
            	<cfset error = true>
                <cfset retval.message = "error - Not authenticated on PAGE_ID: #qPages.id#, #qPages.securityGroup#">
                <cfset retval.code = "auth">
                <cfheader statuscode="500" statustext="auth">
                <cfreturn retval>
            </cfif>
            <!--- get the security group for the new parent --->
			<cfif "#qPages.id#" eq newParent>
                <cfset newSecurityGroup = "#qPages.securityGroup#">
            </cfif>
        </cfoutput>
        
        <!--- Check for duplicate URLS --->
        <cfinvoke component="ajaxPage" method="duplicateURLCheck" returnvariable="LOCAL.response">
            <cfinvokeargument name="page_id" value="#arguments.page_id#">
            <cfinvokeargument name="parent_id" value="#arguments.newParent#">
        	<cfinvokeargument name="checkVisible" value="true">
        </cfinvoke> 
            
		<cfif LOCAL.response.duplicate EQ true>
            <cfset retval.message = "Duplicate URLS">
            <cfset retval.code = "urlduplicate">
            <cfset retval.details = LOCAL.response>
			<cfheader statuscode="500" statustext="auth">                           
            <cfreturn retval>
        </cfif>
               
        <cfif application.tree.alphaorder eq false>   
            <!--- lets 'clean' the indexes for inserting a node --->
            <cfquery datasource="#application.datasource#" name="qSubs">
                select id, titleDraft, deleted from mrl_siteAdmin where idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#newParent#">					
                order by deleted, sortIndex
            </cfquery>
            
            <cfset i = 0>
            <cfloop query="qSubs">
            	<cfquery datasource="#application.datasource#">
                    update mrl_page SET
                    sortIndex = <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">
                    where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qSubs.id#">
                </cfquery>
                <cfset i = i + 1>	
            </cfloop>       
		</cfif>
        
		<cfif newParent neq oldParent>
			<!--- Change parent page --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="movepage">
            UPDATE mrl_page SET 
            idParent=<cfqueryparam cfsqltype="cf_sql_integer" value="#newParent#">,
            securityGroup=<cfqueryparam cfsqltype="cf_sql_varchar" value="#newSecurityGroup#">
            WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
            </CFQUERY>
		</cfif>

        <cfif application.tree.alphaorder eq false>   
            <!--- update the sort index of the higher nodes to make room for new node --->
    		<CFQUERY DATASOURCE="#application.datasource#" NAME="movepage">
            UPDATE mrl_page SET 
            sortIndex = sortIndex + 1
            WHERE idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#newParent#"> and sortIndex >= <cfqueryparam cfsqltype="cf_sql_integer" value="#index#">
            </CFQUERY>            

			<!--- change the sort index --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="movepage">
            UPDATE mrl_page SET 
            sortIndex = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.index#">
            WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
            </CFQUERY>
		</cfif>
        
        <cfset logdate = now()>
        <cfset retval.logdate = LSTimeFormat(logdate, "h:m:s:L")>

        <!--- Log the change made --->
        <CFQUERY DATASOURCE="#application.datasource#" NAME="logpagemove">
            INSERT INTO mrl_pageMoveLog
            VALUES ( <cfqueryparam cfsqltype="cf_sql_timestamp" value="#logdate#">, 
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">, 
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">, 
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.oldParent#">, 
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newParent#">, 
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.index#">)
        </CFQUERY>
        
		<cfif newParent neq oldParent>
        	<cfset retval.newParent = true>
            <cfset retval.idparent = newParent>
            <cfset retval.securitygroup = newSecurityGroup>
        <cfelse>
        	<cfset retval.newParent = false>
        </cfif>
        


        <!--- SEO crap - update the redirects table --->
		<cfinvoke component="core.redirects" method="optimizeID" returnvariable="retval.treedate">
			<cfinvokeargument name="page_id" value="#arguments.page_id#">
            <cfinvokeargument name="force" value="true">
		</cfinvoke> 

        <cfset retval.treedate = LSTimeFormat(retval.treedate, "h:m:s:L")>

        <cfreturn retval>
	</cffunction>
      
	<cffunction name="getPage" access="remote" returnType="any" returnformat="JSON" output="false">
        <cfargument name="node" type="numeric" default="-1"> 
        <cfargument name="single" type="boolean" default="false">
        <cfargument name="alphaOrder" type="boolean" required="false" default="#application.tree.alphaorder#">
        <cfargument name="singleLevel" type="boolean" default="false" required="false">
        <cfargument name="rootId" type="numeric" default="-1" required="false">
        <cfargument name="quicklink" required="false" default="false" type="boolean">
        
		<cfset node = arguments.node>
		<cfif node eq -1>
            <cfabort>
        </cfif>
        
        <!--- not sure what this is for --->
        <!---
        <CFQUERY DATASOURCE="#application.datasource#" NAME="queryPage">
        SELECT securityGroup
        FROM mrl_siteAdmin
        WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#node#">
        </CFQUERY>        
        --->
		
		
        <!--- Query for Children pages--->
        <CFQUERY DATASOURCE="#application.datasource#" NAME="queryChildren">
        SELECT id, titleDraft, menuDraft, visible, securityGroup, quicklink, state FROM mrl_siteAdmin 
        <cfif arguments.single eq true>
        	WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#node#"> 
        <cfelse>
        	WHERE idParent=<cfqueryparam cfsqltype="cf_sql_integer" value="#node#"> 
        </cfif>
        AND (deleted <> 'T' OR deleted IS NULL)
        <cfif arguments.alphaOrder eq true>
            ORDER BY titleDraft ASC
        <cfelse>
            ORDER BY sortIndex
       	</cfif>
        </CFQUERY>
        
        <cfscript>
        pageArray = ArrayNew(1);
        </cfscript>
        
        <cfloop query="queryChildren">
            <cfSet pageNode = structnew()>
            <cfset pageNode['id'] = '#trim(id)#'>
            <cfset pageNode['text'] = '#trim(titleDraft)#'>
            <cfset pageNode['visible'] = '#trim(visible)#'>
            <cfset pageNode['securityGroup'] = '#trim(securityGroup)#'>
            <cfset pageNode['color'] = ''>
            
		<!---	<cfset pageNodeAttributes = structnew()>
            <cfset pageNodeAttributes['state'] = '#trim(state)#'> --->
            
<!---			<cfset pageNode['attributes'] = pageNodeAttributes> --->
			<cfset pageNode['state'] = '#trim(state)#'>            
            
            <!--- Authentication--->
            <CFIF NOT isDefined("SESSION.auth.groups.#queryChildren.securityGroup#")>
                <cfset pageNode['disabled'] = true>
            </CFIF>
            
  
      
            
            <!--- get state info --->
            <cfset tempNode = getTreeStyle(visible: visible, state: queryChildren.state, nodeText: pageNode['text'])>
			<cfset StructAppend(pageNode, tempNode, true)>

            <cfquery datasource="#application.datasource#" name="queryLeaf">
            SELECT id FROM mrl_siteAdmin WHERE idParent=#trim(pageNode.id)# AND (deleted <> 'T' OR deleted IS NULL)
            </cfquery>    
            <cfif queryLeaf.RecordCount gt 0>
                <cfset pageNode['leaf'] = false> 
            <cfelse>
                <cfset pageNode['leaf'] = false> 
            <!---	<cfset pageNode.children = []> --->
                <cfset pageNode['expanded'] = true>
            </cfif>
            
            <cfif arguments.singleLevel eq true AND arguments.node EQ arguments.rootId>
            	<cfset pageNode['leaf'] = true>
            </cfif>
            
            <cfif arguments.quicklink eq true>
            	<cfif queryChildren.quicklink eq 'T'>
                	<cfset pageNode['checked'] = true>
				<cfelse>
                	<cfset pageNode['checked'] = false>
                </cfif>
			</cfif>
                
            <cfscript>
            ArrayAppend(pageArray, pageNode);
            </cfscript>
        </cfloop>
		<cfreturn pageArray>        
	</cffunction>

    <!--- Change the node cls based on page state and visibility --->
    <!--- states:  approved, preview, *stub, *denied, *draft, *pending --->

    <cffunction name="getTreeStyle" access="private" returntype="struct">
    	<cfargument name="visible" required="true">
        <cfargument name="state" required="true">
        <cfargument name="nodeText" required="true"> 
        <cfset var myNode = structnew()>
        	                      
            <cfinvoke component="state" returnvariable="stateInfo" method="getStateInfo">
<!---                <cfinvokeargument name="visible" value="#(trim(visible) eq 'T')#">
           	<cfinvokeargument name="state" value="#queryChildren.state#"> --->
                <cfinvokeargument name="visible" value="#(trim(arguments.visible) eq 'T')#">
            	<cfinvokeargument name="state" value="#arguments.state#">
            </cfinvoke>

            <cfset myNode['cls'] = "">
            
            <cfswitch expression="#arguments.state#">
                <cfcase value="stub">
					 <cfset myNode['cls'] = "stub-node">
         			 <cfset myNode['text'] = Insert("<span style='font-style:italic; font-weight:bold;'>#stateInfo.text# -</span>", nodeText, 0)>                     
                </cfcase>
                <cfcase value="denied">
					 <cfset myNode['cls'] = "denied-node">                             
	  	    	     <cfset myNode['text'] = Insert("<span style='font-style:italic; font-weight:bold;'>#stateInfo.text# -</span>", nodeText, 0)>
                </cfcase>
                <cfcase value="draft">
					 <cfset myNode['cls'] = "draft-node">                             
        	    	 <cfset myNode['text'] = Insert("<span style='font-style:italic; font-weight:bold;'>#stateInfo.text# -</span>", nodeText, 0)>
                </cfcase>
	            <cfcase value="pending">
					 <cfset myNode['cls'] = "pending-node">
        	    	 <cfset myNode['text'] = Insert("<span style='font-style:italic; font-weight:bold;'>#stateInfo.text# -</span>", nodeText, 0)>        
                </cfcase>
            </cfswitch>

			<!--- add hidden class --->
			<cfif arguments.visible eq 'F'>
	    	    <cfset myNode['cls'] = Insert("h", myNode['cls'], len(myNode['cls']))>
            </cfif>                	
            
            <!--- default hidden node class for approved pages --->
            <cfif arguments.visible eq 'F' and arguments.state eq 'approved'>
				<cfset myNode['cls'] = "hidden-node">                             
            </cfif>	 
            <!--- <cfset myNode['checked'] = true> --->
            
    		<cfreturn myNode>            
    </cffunction>

</cfcomponent>


