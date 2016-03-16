<cfcomponent displayName="Page Functions" output="false">

<cffunction name="toggleDevSite" returntype="boolean" access="remote">
	<cfargument name="enableDev" type="boolean" required="yes">
	<cfif arguments.enableDev eq true>
		<cfset SESSION.devSite = true>
    <cfelse>
		<cfset SESSION.devSite = false>
    </cfif>
    <cfreturn true>
</cffunction>

<cffunction name="duplicateURLCheck" returntype="struct" access="remote" output="false" returnFormat="JSON">
	<cfargument name="page_id" type="numeric" required="false" hint="Page ID">
    <cfargument name="history_id" type="numeric" required="false" hint="History ID">
	<cfargument name="url" type="string" required="false" hint="Proposed title">
    <cfargument name="parent_id" type="numeric" required="false" hint="Force check on a different parent">
    <cfargument name="checkVisible" type="boolean" required="false" default="false" hint="Takes into account the visibility of the page being checked">
    
    <cfset var LOCAL = structNew()>
    
    <cfset LOCAL.response = structNew()>
    <cfset LOCAL.response.duplicate = false>
    
    <!--- specify one or the other, but not both --->
	<cfif NOT (structKeyExists(arguments, "page_id") XOR structKeyExists(arguments, "history_id"))>
		<cfthrow message="Required: page_id XOR history_id">
		<cfset LOCAL.response['success'] = false>
        <cfreturn LOCAL.response>			    	
    </cfif>

	<!--- Get the object for the page --->    
    <cfif isDefined("arguments.history_id")>
    	<cfset LOCAL.page = createObject("component", "marloo.core.page").init(page_id: "", history_id: arguments.history_id, admin: true, editorJS: false, site_config: application.site_config)>
	<cfelse>
    	<cfset LOCAL.page = createObject("component", "marloo.core.page").init(page_id: arguments.page_id, history_id: "", admin: true, editorJS: false, site_config: application.site_config)>
    </cfif>

    <!--- take into account the visibility of the page being checked --->
	<cfif arguments.checkVisible EQ true AND LOCAL.page.getPage().visible EQ 'F'>
    	<cfreturn LOCAL.response>
    </cfif>
	
    <!--- Get the parent ID --->
    <cfif isDefined("arguments.parent_id")>
    	<cfset LOCAL.idParent = arguments.parent_id>
    <cfelse>
    	<cfset LOCAL.idParent = LOCAL.page.getPage().idParent>
    </cfif>
    
    <!--- Get the page peers --->
    <cfquery datasource="#application.datasource#" name="LOCAL.qPeers">
    	select URL, id, title from mrl_sitePublic where idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#LOCAL.idParent#">
    </cfquery>
    
    <!--- set the proposed URL --->
    <cfif isDefined("arguments.url")>
    	<cfset LOCAL.url = arguments.url>
    <cfelse>
    	<cfset LOCAL.url = trim(LOCAL.page.getPage().URL)>
    </cfif>

	<!--- check the page peers for duplicates --->
	<cfloop query="LOCAL.qPeers">
    	<cfif LOCAL.page.getID() NEQ LOCAL.qPeers.id AND trim(LOCAL.page.getPage().URL) EQ trim(LOCAL.qPeers.URL)>
        	<!--- <cfoutput>Conflict - URL: #LOCAL.page.getURL()# - Page_ID: #LOCAL.page.getId()#, #LOCAL.qPeers.id#</cfoutput><br /> --->
            <cfset LOCAL.response.duplicate = true>
            <cfset LOCAL.response.id_parent = LOCAL.idParent>
            <cfset LOCAL.response.id = LOCAL.page.getID()>
            <cfset LOCAL.response.id_dup = LOCAL.qPeers.id>
            <cfbreak>            
        </cfif>
    </cfloop>
    
    <cfreturn LOCAL.response>

</cffunction>

<!--- WE - need to add security check --->
<cffunction name="getComments" returntype="struct" access="remote" returnformat="json" hint="Gets comments for a draft.">
	<cfargument name="page_id" type="numeric" required="false" hint="Page ID">
    <cfargument name="history_id" type="numeric" required="false" hint="History ID">
    
    <cfset var LOCAL = structNew()>
    
    <cfset LOCAL.response = structNew()>
    
    <!--- specify one or the other, but not both --->
	<cfif NOT (structKeyExists(arguments, "page_id") XOR structKeyExists(arguments, "history_id"))>
		<cfthrow message="Required: page_id XOR history_id">
		<cfset LOCAL.response['success'] = false>
        <cfreturn LOCAL.response>			    	
    </cfif>
    
    <cfif structKeyExists(arguments, "page_id")>    
        <!--- Get comments --->
        <cfquery datasource="#application.datasource#" name="LOCAL.qComment">
        select top 1 * from mrl_pageComment
        where idHistory in (select idHistory from mrl_siteHistory where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">) and commentDate > (select modifiedDate from mrl_siteAdmin where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">) and state = 'denied'
        order by commentDate desc    
        </cfquery>

<!---        
        <cfinvoke component="core.queryToStruct" method="queryToStruct" returnvariable="LOCAL.comment">
    		<cfinvokeargument name="query" value="#LOCAL.qComment#">
    	</cfinvoke>
--->

        <cfset LOCAL.comment = new marloo.core.queryhelper(LOCAL.qComment).toArray()>
   
        <cfset LOCAL.response['data'] = LOCAL.comment[1]>         
    <cfelse>
    	<!--- implement later for only history id --->
    </cfif>
    
	<cfset LOCAL.response['success'] = true>
    <cfreturn LOCAL.response>
        
</cffunction>

<!--- Get latest draft --->
<cffunction name="getLatestDraft" returntype="struct" access="remote" returnformat="json" hint="Gets the latest draft for editting.">
	<cfargument name="page_id" type="numeric" required="true" hint="Page ID">

    <!--- get the raw latest draft --->
    <cfinvoke component="marloo.core.pageCore" method="getLatestDraft" returnvariable="LOCAL.qPage">
        <cfinvokeargument name="page_id" value="#arguments.page_id#">
    </cfinvoke>

    <!--- get the template details --->
    <cfinvoke component="marloo.core.pageHelper" method="getPageTemplate" returnvariable="LOCAL.qTemplate">
        <cfinvokeargument name="page_id" value="#arguments.page_id#">
    </cfinvoke>

    <cfset LOCAL.page = new marloo.core.queryhelper(LOCAL.qPage).toArray()>

    <cfset LOCAL.formResponse = structNew()>
    <cfset LOCAL.formResponse['success'] = true>
    <cfset LOCAL.formResponse['data'] = LOCAL.page[1]>
    <cfset LOCAL.formResponse['data']['TINYMCESTYLESHEET'] = LOCAL.qtemplate.tinyMCEStyleSheet>

    <!--- WE - 01/20/2016 - Check to see if the menu text is different from the title.  If not, we know a custom wasn't used --->
    <!---
    <cfif Compare(LOCAL.qPage.title, LOCAL.qPage.menu) EQ 0>
        <cfset LOCAL.formResponse['data']['CUSTOMURL'] = false>
    <cfelse>
        <cfset LOCAL.formResponse['data']['CUSTOMURL'] = true>
    </cfif>--->
    
    <cfreturn LOCAL.formResponse>
</cffunction>

<!--- Gets details for a given page id and returns the attributes as a struct --->
<cffunction name="getPageDetails" returntype="struct" access="remote" returnformat="json">
	<cfargument name="id" type="numeric" required="yes">     

	<cfquery datasource="#application.datasource#" name="qPage">
    	select * from mrl_siteAdmin where id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfinvoke component="state" method="getStateInfo" returnvariable="stateInfo">
    	<cfinvokeargument name="state" value="#qPage.state#">
    </cfinvoke>
         
    <cfset time = "">
	<cftry>    
		<cfset lockedDays = DateDiff("d", qPage.lockedDate, now())>
        <cfset lockedHours = DateDiff("h", qPage.lockedDate, now()) mod 24>
        <cfset lockedMinutes = DateDiff("n", qPage.lockedDate, now()) mod 60>
        <cfset lockedSeconds = DateDiff("s", qPage.lockedDate, now()) mod 60>
        
        <cfif lockedDays gt 0>
            <cfset time = time & "Days: #lockedDays#">
        </cfif>
        
        <cfif lockedHours gt 0>
            <cfif len(time) gt 1>
                <cfset time = time & ", ">
            </cfif>
            <cfset time = time & "Hours: #lockedHours#">
        </cfif>
        
        <cfif lockedMinutes gt 0 and len(time) lt 15>
            <cfif len(time) gt 1>
                <cfset time = time & ", ">
            </cfif>
            <cfset time = time & "Minutes: #lockedMinutes#">
        </cfif>
             
        <cfif lockedSeconds gt 0 and len(time) lt 15>
            <cfif len(time) gt 1>
                <cfset time = time & ", ">
            </cfif>
            <cfset time = time & "Seconds: #lockedSeconds#">
        </cfif>
	<cfcatch>
    </cfcatch>
    </cftry>
        
<!--- <cfset time = "Days: #lockedDays#, Hours: #lockedHours#, Minutes: #lockedMinutes#, Seconds: #lockedSeconds#"> --->
<!--- <cfdump  var="#time#"> --->
 <!---
 	<cfdump var="#qPage#">
    <cfabort>
 --->
    <cfscript>
        page = structNew();
        page.title = qPage.title;
        page.id = qPage.id;
        page.visible = qPage.visible;
		page.locked = qPage.locked;
		page.lockedBy = qPage.lockedBy;
		page.lockedDate = qPage.lockedDate;
		page.lockedTime = time;
		page.state = qPage.state;
		page.stateDesc = stateInfo.text;
		page.securityGroup = qPage.securityGroup;
    </cfscript>
    
    <cfreturn page>
</cffunction>

<!--- sets the lock state for a given page --->
<cffunction name="setPageLock" returntype="boolean" access="remote" returnformat="json">
	<cfargument name="id" type="numeric" required="yes">
    <cfargument name="state" type="boolean" required="yes">

	<!--- check that we have access to the page security group --->
    <cfset page = getPageDetails(id)>

    <!--- Server Side Authentication Check --->
	<CFIF NOT isDefined("SESSION.Auth.groups.#page.securityGroup#")>
      <cfreturn false>
    </CFIF>
   
    <!--- set the page locked state --->
	<cfquery datasource="#application.datasource#">
		update mrl_page set 
          locked = <cfqueryparam cfsqltype="cf_sql_varchar" value="#state#">
        , lockedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
        , lockedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
        where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#"> 
    </cfquery>
    <cfreturn true>
</cffunction>

<!--- clear all locked pages for a given user (defaults to logged in user) --->
<cffunction name="clearPageLocks" returntype="boolean" access="remote" returnformat="json">
	<cfargument name="login" type="string" required="no" default="#session.auth.user.login#">
	
    <cfif session.auth.user.login neq login>
		<CFIF NOT isDefined("SESSION.Auth.groups.toplevel")>
			<cfreturn false>
        <cfelse>
        	<cfquery datasource="#application.datasource#">
                update mrl_page set
                  locked = 'false'
                , lockedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
                , lockedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                where lockedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#login#">
            </cfquery>
        </CFIF>
    <cfelse>
  	    <cfquery datasource="#application.datasource#">
            update mrl_page set
              locked = 'false'
            , lockedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
            , lockedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
            where lockedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
        </cfquery>
    </cfif>
    <cfreturn true>
</cffunction>

<!--- gets the breadcrumbs for a given page id --->
<cffunction name="getBreadcrumbs" returntype="array" access="remote" returnformat="json">
	<cfargument name="id" type="numeric" required="yes">
    
    <cfstoredproc datasource="#application.datasource#" procedure="mrl_getBreadCrumbs">
        <cfprocparam cfsqltype="CF_SQL_INTEGER" value="#id#" variable="id">
        <cfprocparam cfsqltype="CF_SQL_BIT" value="false" variable="public">
        <cfprocresult name="qpages"> 
    </cfstoredproc>
    
    <cfscript>
        pageIDs = ArrayNew(1);
    </cfscript>
    <cfset index = 0>
    <cfloop query="qpages">
       <cfscript>
        ArrayAppend(pageIDs, qpages.id);
        </cfscript>
    </cfloop> 
    
    <cfreturn pageIDs>
</cffunction>


<!--- creates a new stub page in mrl_page--->	
<cffunction name="deletePage" access="private" returnType="any" output="false">
	<cfargument name="id" type="numeric" default="-1"> 
	
	<!--- Get data for existing page --->
	<CFQUERY DATASOURCE="#application.DataSource#" NAME="queryPage">
	  SELECT TOP 1 securityGroup, title
	  FROM mrl_siteAdmin
	  WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
	</CFQUERY>
	
	<!--- check authentication --->
	<cfset auth = isDefined("SESSION.Auth.groups.#trim(queryPage.securityGroup)#")>
	<cfif auth eq false>
		<cfreturn false>
	</cfif>
			
	<!--- mark the page as deleted --->
	<cfquery datasource="#application.DataSource#" name="queryUpdate" result="updateResult">
	  UPDATE mrl_page
	  SET deleted = 'T',
	  gModifiedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">,
	  gModifiedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
	  WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
	</cfquery>
	
	<cfreturn true>
</cffunction>

<cffunction name="recursiveDelete" access="remote" output="true" returnFormat="plain" >
	<cfargument name="id" type="numeric"> 
	<cfset var qPageSubs = "">
	<cfset var idPage = id>
		
	<!--- check for subs --->
	<cfquery datasource="#application.datasource#" name="qPageSubs">
		select id from 
		mrl_siteAdmin where idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#idPage#"> and deleted != 'T'
	</cfquery> 	

	<cfif qPageSubs.getRowCount() gt 0> 
		<cfloop query="qPageSubs">
			<cfset recursiveDelete(id: qPageSubs.id)>
		</cfloop> 
	</cfif>

	<cfreturn deletePage(id: idPage)>
</cffunction> 

<cffunction name="checkForChildren" access="remote" returnType="any" returnformat="JSON">
	<cfargument name="id" default="-1" type="Numeric" > 
	
	<cfquery datasource="#application.DataSource#" name="qChildrenCount">
		select count(*) as count from
		mrl_siteAdmin where idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#"> and deleted != 'T' 
	</cfquery>
	
	<cfset retStruct = structnew()>
	<cfset retStruct.CHILDREN = (qChildrenCount.count gt 0)>

	<!--- true, children  false, no children --->
	<cfreturn retStruct>
</cffunction>

</cfcomponent>