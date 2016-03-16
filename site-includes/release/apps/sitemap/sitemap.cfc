<cfcomponent displayname="sitemap" hint="generates struct with a site map">

<cfset variables.datasource = "">

<cffunction name="getMap" hint="returns the site map array" access="public" output="false" returntype="Array" returnformat="JSON">
	<cfargument name="pageId" hint="root node for the site">
	<cfargument name="rootTitle" default="ROOT" required="false">
	<cfargument name="level" default="0" hint="pass the previous tree level">
    <cfargument name="admin" default="false" type="boolean" required="false">
    
	<cfset var qPages = 0>	
	<cfset var pageArray = arrayNew(1)>
	<cfset var pageData = 0>
	<cfset var returnArray = 0>
	<cfset var myStruct = 0>
	
	<!--- get the peer pages or root --->
	<cfif admin eq true>
		<cfif level neq 0>
            <cfstoredproc datasource="#variables.datasource#" procedure="mrl_getPeers">
              <cfprocparam cfsqltype="cf_sql_integer" value="#pageId#">
			  <cfprocparam cfsqltype="cf_sql_bit" value="#false#">              
			  <cfprocparam cfsqltype="cf_sql_bit" value="#false#">              
              <cfprocresult name="qPages">
            </cfstoredproc>
        <cfelse>
            <cfquery datasource="#variables.datasource#" name="qPages">
                select id, menu, owner, visible, deleted from mrl_siteAdmin where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#pageId#">
            </cfquery>
        </cfif>		    
    <cfelse>
		<cfif level neq 0>
            <cfstoredproc datasource="#variables.datasource#" procedure="mrl_getPeers">
              <cfprocparam cfsqltype="cf_sql_integer" value="#pageId#">
              <cfprocresult name="qPages">
            </cfstoredproc>
        <cfelse>
            <cfquery datasource="#variables.datasource#" name="qPages">
                select id, menu from mrl_sitePublic where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#pageId#">
            </cfquery>
        </cfif>
    </cfif>
    
	
	<!--- create a query structure for the root if it does not exist --->
	<cfif qPages.recordcount eq 0 and level eq 0>
		<cfset qPages = QueryNew("id, menu, visible, deleted, owner", "Integer, VarChar, VarChar, VarChar, varChar")>
		<cfset newRow = QueryAddRow(qPages, 1)>
		<cfset querySetCell(qPages, "id", pageId, 1)>
		<cfset querySetCell(qPages, "menu", rootTitle, 1)>
   	    <cfset querySetCell(qPages, "deleted", "F", 1)>
		<cfset querySetCell(qPages, "visible", "T", 1)>
		<cfset querySetCell(qPages, "owner", "", 1)>
    </cfif>	 

	<cfloop query="qPages">
		<cfif admin eq false or (admin eq true and qPages.visible eq "T" and qPages.deleted eq "F")>
			<cfset pageData = structNew()>
            <cfset pageData.title = qPages.menu>
            <cfset pageData.id = qPages.id>
            <cfset pageData.level = level>
            <cfif admin eq true>
                <cfset pageData.owner = qPages.owner>
            </cfif>
            <cfset arrayAppend(pageArray, pageData)>
    
            <cfquery datasource="#variables.datasource#" name="qChildren">
                select top 1 id from mrl_sitePublic where idParent = <cfqueryparam cfsqltype="cf_sql_numeric" value="#qPages.id#">
            </cfquery>
            
            <cfif qChildren.getRowCount() gt 0>
                <cfset returnArray = getMap(pageId: qChildren.id, level: (level + 1), admin: arguments.admin)>
                <cfif isArray(returnArray)>
                    <cfif ArrayLen(returnArray) gt 0>
                        <cfloop array="#returnArray#" index="myStruct">
                            <cfset ArrayAppend(pageArray, myStruct)>
                        </cfloop>
                    </cfif>
                </cfif>
            </cfif>				
        </cfif>	
    </cfloop>
	
	<cfif level eq 0>
	</cfif>
	<cfreturn pageArray>
	
</cffunction>

<cffunction name="getHTMLMap" access="public" returnformat="plain" returntype="string" hint="HTML for site map" output="false">
	<cfargument name="pageId" required="true" hint="root node for the site">
	<cfargument name="datasource" required="true"> 
	<cfargument name="rootTitle" default="ROOT" required="false">
    <cfargument name="rootURL" default="" required="false">
	<cfargument name="cacheHours" default="12" required="false">
    <cfargument name="useCache" default="true" required="false">
	
    <cfset var mycontent = "">
    <cfset var mycache = "">
    <cfset var cacheKey = "sitemap#arguments.pageId##arguments.rootTitle##arguments.rootURL#">

	<cfset variables.datasource = arguments.datasource>
	
    <cfsilent>
    
    <cfif arguments.useCache>
        <cfset mycache = CacheGet(cacheKey)>

        <cfif NOT isNull(mycache)>
            <cfreturn mycache>        
        </cfif>
    </cfif>

    <cfset siteArray = getMap(pageID: pageID, rootTitle: rootTitle)>
    <!---	<cfdump var="#siteArray#"> --->
    <cfset treeHTML = "">
    <cfset lastLevel = 0>
    <cfset treeHTML = treeHTML & "<ul>">
    <cfloop array="#siteArray#" index="myPage">
        <cfif lastLevel lt myPage.level>
            <cfloop from="#lastLevel#" to="#myPage.level - 1#" index="i"> 
                <cfset treeHTML = treeHTML & "<ul>">
            </cfloop> 
        </cfif>
        <cfif lastLevel gt myPage.level>
            <cfloop from="#myPage.level#" to="#lastLevel - 1#" index="i"> 
                <cfset treeHTML = treeHTML & "</li></ul></li>">
            </cfloop> 
        </cfif>
        <cfif lastLevel eq myPage.level>
            <cfset treeHTML = treeHTML & "</li>">
        </cfif>
        <!--- Use custom root URL if defined --->
        <cfif (myPage.id eq pageId) and (rootURL neq "")> 
            <cfset treeHTML = treeHTML & "<li><a href='#rootURL#'>#myPage.title#</a>">
        <cfelse>
            <cfset treeHTML = treeHTML & "<li><a href='http://www.example.com/page.cfm?page_ID=#myPage.id#'>#myPage.title#</a>">
        </cfif>        		
    
    <cfset lastLevel = myPage.level>
    </cfloop>
    <cfset treeHTML = treeHTML & "</ul>">	
	
    <cfif arguments.useCache>
        <cfset CachePut(cacheKey, treeHTML, createTimeSpan(0,arguments.cacheHours,0,0))>
    </cfif>
    
    </cfsilent>

	<cfreturn treeHTML>
	
</cffunction>  

</cfcomponent>