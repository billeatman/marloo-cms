<cfcomponent displayname="Search Functions" output="no">
	<!--- get the total number of pages for paging purposes.  returned as a query --->
	<cffunction name="getPageCount" access="public" returntype="query">
		<cfargument name="id" default="" >
        <cfargument name="title" default="" >
        <cfargument name="info" default="" >
        <cfargument name="securityGroup" default="" > 
        <cfargument name="resultpage" default="1" >

        <cfif isNumeric(arguments.id) NEQ TRUE AND arguments.id NEQ "">
            <cfset arguments.id = resolveURLtoID(url: arguments.id)>
        </cfif>       

        <CFQUERY DATASOURCE="#application.DataSource#" NAME="queryTotalCount">
            SELECT  count(*) as totalCount
            FROM mrl_siteAdmin
            WHERE 0=0 AND (deleted <> 'T' or deleted IS NULL)
            <!--- Search by page id --->
            <CFIF id IS NOT "">
                AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
            </CFIF>
            <!--- Search by title--->
            <CFIF title IS NOT "">
                AND titleDraft Like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.title#%">
            </CFIF>
            <!--- Search by info --->
            <CFIF info IS NOT "">
                AND info Like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.info#%">
            </CFIF>
            <!--- Search by securityGroup --->
            <CFIF securityGroup IS NOT "">
                AND securityGroup Like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.securityGroup#%">
            </CFIF>
        </CFQUERY>
	<cfreturn queryTotalCount>
    </cffunction>
    
    <!--- get the last 10 modified pages for logged in user
		May pass a login to see recent activity if toplevel 
	--->
    
    <cffunction name="getRecentPages" access="public" returntype="query">
    	<cfargument name="login" required="no" type="string" default="">
        
        <cfif isDefined("SESSION.Auth.groups.TopLevel") and login neq "">
			<cfset userLogin = login>
		<cfelse>
	        <cfset userLogin = session.auth.user.login>
    	</cfif>    
        
        <CFQUERY DATASOURCE="#application.DataSource#" NAME="qPages">
          	select top 10 sh.id, sa.titleDraft, sa.info, sa.securityGroup, sa.visible, sa.state, sh.modifiedDate, sa.modifiedBy, sa.deleted from (
                SELECT distinct id, max(modifiedDate) as modifiedDate from (select * from mrl_siteHistory where modifiedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userLogin#"> and state <> 'preview') as asdf
                group by id
            ) as sh inner join mrl_siteAdmin as sa on sh.id = sa.id
            where sa.deleted = 'F'
            order by modifiedDate desc
        </cfquery>
	
        <cfset qPages = mergeWithGroups(qPages: qPages)>
        
        <cfquery dbtype="query" name="qPages">
        	select * from qPages
            order by modifiedDate DESC
        </cfquery>            
    
		<cfreturn qpages>	
    </cffunction>
    
    <!--- search pages with a returned query ---> 
    <cffunction name="getPages" access="public" returntype="query" output="yes">
		<cfargument name="id" default="" >
        <cfargument name="title" default="" >
        <cfargument name="info" default="" >
        <cfargument name="securityGroup" default="" > 
        <cfargument name="resultpage" default="1" >
        
        <cfif isNumeric(arguments.id) NEQ TRUE AND arguments.id NEQ "">
            <cfset arguments.id = resolveURLtoID(url: arguments.id)>
        </cfif>       

        <!---
        <cfif resultpage eq 1>
        	<cfdump var="#url#">
            <cfdump var="#arguments#">
            <cfabort>
        </cfif>
        --->
		
        <CFQUERY DATASOURCE="#application.DataSource#" NAME="qPages">
            SELECT  id, titleDraft, info, securityGroup, visible, state, modifiedDate, modifiedBy
            FROM     (SELECT ROW_NUMBER() OVER (ORDER BY id ASC)
                         AS Row, id, titleDraft, info, securityGroup, visible, state, modifiedDate, modifiedBy FROM mrl_siteAdmin WHERE 0=0 AND (deleted <> 'T' or deleted IS NULL)
            <!--- SELECT TOP 50 id, title, securityGroup
            FROM admin
            WHERE 0=0 AND (deleted <> 'T' or deleted IS NULL) --->
            <!--- Search by page id --->
            <CFIF id IS NOT "">
                AND id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
            </CFIF>
            <!--- Search by title--->
            <CFIF title IS NOT "">
                AND titleDraft Like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.title#%">
            </CFIF>
            <!--- Search by info --->
            <CFIF info IS NOT "">
                AND info Like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.info#%">
            </CFIF>
            <!--- Search by securityGroup --->
            <CFIF securityGroup IS NOT "">
                AND securityGroup Like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.securityGroup#%">
            </CFIF>
            ) AS adminPaging
            WHERE  Row >= <cfqueryparam cfsqltype="cf_sql_integer" value="#(arguments.resultPage * 25) - 24#"> AND Row <= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.resultPage * 25#">
        </cfquery>
        
        <!--- <cfdump var="#qPages#"> --->
        <cfset qPages = mergeWithGroups(qPages: qPages)>
    	
        <cfreturn qPages>
	</cffunction>

	<!--- merges page queries with page group descriptions --->
	<cffunction name="mergeWithGroups" access="private" returntype="query">
		<cfargument name="qPages" required="yes" type="query">
        <cfset qGroupsAll = getGroups()>
        
        <!--- Gives us the group descriptions and filters out pages that the user cannot access --->
        <!--- NOTE:  The results returned may be wrong because the count is done before filtering --->
        <cfquery dbtype="query" name="qPages2">
            SELECT
                qPages.id,
                qPages.titleDraft,	
                qPages.securityGroup,
                qPages.visible,
                qPages.state,
                qPages.modifiedDate,
                qPages.modifiedBy,
                qGroupsAll.groupDesc
            from
                qPages, qGroupsAll
            where
                lower(qPages.securityGroup) = lower(qGroupsAll.groupName) 
            order by id ASC
        </cfquery>
        <cfreturn qPages2>
    </cffunction>
    
    <!--- Get the active security groups for user --->    
    <cffunction name="getGroups" access="public" returntype="query">
        <cfstoredproc datasource="#application.datasource#" procedure="mrl_userGroups">
          <cfprocparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
          <cfprocresult name="qGroupsAll">
        </cfstoredproc>
		<cfreturn qGroupsAll>
    </cffunction>
    
    <!--- the the user's site specific groups with descriptions --->
	<cffunction name="getUserSiteGroups" access="public" returntype="query">
    	<!--- Get user page groups --->
        <cfset qGroupsAll = getGroups()>
    	
        <!--- Get the site groups --->	    
        <cfquery datasource="#application.datasource#" name="qGroupsSite">
            SELECT DISTINCT securityGroup from mrl_siteAdmin
        </cfquery>
        
        <!--- merge the two queries --->
        <cfquery dbtype="query" name="qSecurityGroups">
            SELECT
                qGroupsSite.securityGroup,
                qGroupsAll.groupDesc
            from
                qGroupsSite, qGroupsAll
            where
                lower(qGroupsSite.securityGroup) = lower(qGroupsAll.groupName)
            order by qGroupsAll.groupDesc ASC
        </cfquery>   
        
       	<cfreturn qSecurityGroups>
    </cffunction>    
    
    <!--- display page query results --->
    <cffunction name="displayQuery" access="public" output="yes">
    	<cfargument name="qPages" type="query" required="yes">
        <cfargument name="limitResults" type="numeric" default="-1">
        <TABLE width="700" align="center">      
        <cfset recentCount = 0>     
        <cfloop QUERY="qPages">
        	<cfoutput>
        	<cfset recentCount = recentCount + 1>
            <cfif limitResults neq -1>
				<cfif recentCount gt limitResults>
    	        	<cfbreak>
        	    </cfif>
            </cfif>
             <TR valign="top">   <!--- 296 --->
                <TD width="215" align="top" wrap="no"><p>#application.pagedesc# #application.idname#: #qPages.id#</p>
                <TD width="294" align="top" wrap="no" colspan="2">#application.pagedesc# Group: #qPages.groupDesc#
	   		 </TR>
             <TR valign="top">              
                <TD width="215" height="40" wrap="no">
                	<cfinvoke component="state" returnvariable="stateInfo" method="getStateInfo">
                    	<cfinvokeargument name="visible" value="#(visible eq 'T')#">
                        <cfinvokeargument name="state" value="#state#">
                    </cfinvoke>
		<!---  	<cfset icon = getStateIcon(visible: (visible eq 'T'), state: state)> --->

                <img src=#stateInfo.icon#>
				<cfif state neq "approved">
                	<span style='font-style:italic; font-weight:bold; position:relative; top: -3px;'>#stateInfo.text# -</span>
                </cfif>
				
				<cfif visible eq 'F'>
 					<span style="position: relative; top: -3px;">
                    #qPages.titleDraft#
                    </span>
			    <cfelse>
 					<span style="position: relative; top: -4px;">
		<!---			<a HREF="#application.web.siteroot##application.pagename#?#application.idvar#=#URLEncodedFormat(Trim(qPages.id))#">#qPages.titleDraft#</a> --->
        			<!--- toggle between dev and release --->
        			<cfif session.devsite eq true>
						<a href="##" onclick="top.setIframeSrc('#application.web.editorroot#site-dev/#application.pagename#?#application.idvar#=#URLEncodedFormat(Trim(qPages.id))#'); return false;">#qPages.titleDraft#</a>
                    <cfelse>
   						<a href="##" onclick="top.setIframeSrc('#application.web.editorroot#site-release/#application.pagename#?#application.idvar#=#URLEncodedFormat(Trim(qPages.id))#'); return false;">#qPages.titleDraft#</a>
					</cfif>
                    </span>
				</cfif>
				</TD>
                <TD width="84" wrap="no">
        <!---        	<A HREF="editors/#application.editor#/update.cfm?id=#qPages.id#"><strong>[Edit]</strong></A> --->
        				<a href="##" onclick="top.pageEdit('#qPages.id#', '#qPages.state#'); return false;"><strong>[Edit]</strong></a>
                </TD>
                <TD width="60" wrap="no"><div align="left"></div></TD>
             </TR>
	        </cfoutput>
      	</cfloop>
      	</TABLE>
    
    
   	</cffunction> 


    <cffunction name="resolveURLtoID" access="private" output="false">        
        <cfargument name="url" type="string">
        <!--- Search by URL... convert the URL to a numeric ID --->
        <cfinvoke component="marloo.core.pageHelper" method="getPath" returnvariable="local.urlPath">
            <cfinvokeargument name="url" value="#url#">
        </cfinvoke>

        <cfinvoke component="marloo.core.pageHelper" method="pageUrlToId" returnvariable="local.page_id">
            <cfinvokeargument name="page_url" value="#local.urlPath#">
            <cfinvokeargument name="root_id" value="#application.site_config.rootId#">
            <cfinvokeargument name="datasource" value="#application.datasource#"> 
            <cfinvokeargument name="useRedirectTable" value="false">       
        </cfinvoke>

        <cfif isStruct(local.page_id)>
            <cfreturn local.page_id.id>
        </cfif> 
        
        <cfreturn local.page_id>
    </cffunction>


</cfcomponent>