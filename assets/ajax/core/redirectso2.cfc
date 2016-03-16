<cfcomponent output="false">

<cffunction name="ValidateTable" public="true" output="true" access="remote">
    <cfset var qPages = "">
    <cfset var orphaned = 0>
    <cfset var orphanedPages = arrayNew(1)>
    
    <cfquery datasource="#application.datasource#" name="qPages">
        select id, title from mrl_sitePublic
    </cfquery>
    
    <!--- create the page helper --->
    <cfset variables.ph = createObject("component", "marloo.core.pageHelper").init(
        datasource: application.datasource, 
        useRedirectTable: false, 
        URLRewriter: true,
        site_config: application.site_config
    )>
    
    <!--- create the page helper --->
    <cfset variables.phtable = createObject("component", "marloo.core.pageHelper").init(
        datasource: application.datasource, 
        useRedirectTable: true, 
        URLRewriter: true,
        site_config: application.site_config
    )>
    
    <cfloop query="qPages">
        <cfset pageURLTable = phtable.pageIdToURL(page_id: qPages.id)>
        <cfset pageURL = ph.pageIdToURL(page_id: qPages.id)>

        <cfset pageRetvalTable = variables.phtable.pageURLToId(page_url: pageURLTable, root_id: application.tree.rootid)>
        <cfset pageRetval = variables.ph.pageURLToId(page_url: pageURL, root_id: application.tree.rootid)>

<!---
        <cfoutput>ID: #qPages.id#, #pageURL# - #pageURLTable#</cfoutput><br />
--->

        <cfif pageURL NEQ pageURLTable>
            <cfoutput>Page ID: #qPages.id#<br /></cfoutput>
            <cfoutput>URL Generator: #pageURL#<br /></cfoutput>
            <cfoutput>Lookup Table: #pageURLTable#<br /></cfoutput>
        <cfelse>
            <cfif isNumeric(pageURL) AND isNumeric(pageURLTable)>
                <cfset orphaned = orphaned + 1>
                <cfset arrayAppend(orphanedPages, "PAGE_ID: #qPages.id#, TITLE: #qPages.title#")>
            <cfelse>            
                <cfset phid = phtable.pageURLtoID(page_url: pageURL, root_id: application.tree.rootid)>
                <cfif phid.id NEQ qPages.id>
                    <cfoutput>ERROR - pageURLtoID - expected: #qPages.id#  actual: #phid.id# for #pageURL#<br /></cfoutput>
                </cfif>
            </cfif>                
        </cfif>

        <cfif pageRetvalTable.redirecturl NEQ "">
            <cfoutput>ERROR - pageURLtoID - expected: #pageURLTable#  actual: #pageRetvalTable.redirectURL#<br /></cfoutput>
            <cfdump var="#pageRetvalTable#">
        </cfif>

    </cfloop>
    <cfif orphaned GT 0>
        <br />Orphaned Pages: #orphaned#<br />
        <cfloop array="#orphanedPages#" index="local.i">
            <cfoutput>#local.i#</cfoutput><br />
        </cfloop>
    </cfif>
</cffunction>

<cffunction name="optimizeID" public="true" output="false" access="remote" returntype="ANY">
	<cfargument name="page_id" type="numeric" required="true" > 
	<cfset var qPage = "">
    <cfset var retval = "">
	
	<cflock name="#application.applicationname#redirects" timeout="360" type="exclusive" > 			           
        <!--- get the history id for the id --->
		<cfquery datasource="#application.datasource#" name="qPage" >  
			select idHistory from mrl_sitePublic 
			where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
		</cfquery>
		
		<cfif qPage.recordCount EQ 0>
			<cfreturn>
		<cfelse>	
			<cfset retval = addHistoryId(history_id: qPage.idHistory)>
		</cfif>
	</cflock>

    <cfreturn retval>
</cffunction>

<cffunction name="addHistoryId" output="false" returntype="ANY">
	<cfargument name="history_id" type="numeric">
    <cfargument name="date" type="date" required="false">
    <cfargument name="type" type="string" required="false">


	<cfset var qTree = "">
    <cfset var qNextHistory = "">
    <cfset var pageSubs = "">
    <cfset var page_id = "">
    <cfset var bread = "">
    <cfset var burl = "">
	<cfset var qPage = "">

    <cfset var treedate = "">
    <cfset var nexttreedate = "">
    <cfset var b = "">
    <cfset var isNew = false>

	<!--- get the info for the history_id --->
	<cfquery datasource="#application.datasource#" name="qPage">
    	select usedDate, id, idHistory from mrl_siteHistory 
        where idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.history_id#">
    </cfquery>	

    <cfif isDefined("arguments.date")>
        <cfset treeDate = arguments.date>
    <cfelse>
         <cfquery datasource="#application.datasource#" name="qNextHistory">
            select top 1 idHistory, usedDate from mrl_siteHistory 
            where usedDate > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#qPage.usedDate#">
            and id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qPage.id#"> and state = 'approved'
            order by usedDate asc
         </cfquery>

        <cfif qNextHistory.recordCount EQ 1>
            <cfset treeDate = qNextHistory.usedDate>
        <cfelse>
            <cfset treeDate = DateAdd("n", 1, now())>
            <cfset isNew = true>
        </cfif>        
    </cfif>

    <!--- generate the old site map / tree --->
    <cfinvoke component="redirects" method="getOldTree" returnvariable="qTree">
		<cfinvokeargument name="treedate" value="#treeDate#">
        <cfinvokeargument name="id_root" value="#application.tree.rootid#">         
    </cfinvoke>

    <!--- get the list of all pages that need to be resolved --->
    <cfinvoke component="redirects" method="getAllSubs" returnvariable="pageSubs">
		<cfinvokeargument name="id" value="#qPage.id#">
        <cfinvokeargument name="db" value="#qTree#">
    </cfinvoke>

    <cfset local.urls = structNew()>
    <!--- create the page helper --->
    <cfset local.ph = createObject("component", "marloo.core.pageHelper").init(
        datasource: application.datasource, 
        useRedirectTable: false, 
        URLRewriter: true,
        site_config: application.site_config
    )>

    <cfloop array="#pageSubs#" index="page_id">
    	<cfinvoke component="redirects" method="getBread" returnvariable="bread">
        	<cfinvokeargument name="id" value="#page_id#">
            <cfinvokeargument name="db" value="#qTree#">
            <cfinvokeargument name="root" value="#application.tree.rootid#">
		</cfinvoke>

		<cfset burl = "">
        <cfloop array="#bread#" index="b">
        	<cfset burl = "#burl##b#/">
        </cfloop>
		
        <!--- We see if this is a "new" page, because this is experimental.  We then put the 
        urls into a hash so we can detect collisions.  If a collision occurs, we look up
        the correct page and change the id --->
        <cfif isNew EQ true>  
            <cfif structKeyExists(local.urls, "#burl#")>
<!---
                <cfoutput>2nd: #page_id#, #treeDate#, #burl#</cfoutput><br />        
                <cfoutput>1st: #local.urls["#burl#"]#</cfoutput><br /> --->
                <cfset local.correctId = local.ph.pageURLToId(page_url: trim(burl), root_id: application.tree.rootid)>
                <cfif isNumeric(local.correctId.id)>
                    <cfset page_id = local.correctId.id>
<!---                    <cfdump var="#local.correctId#">
                    <cfoutput>corrected: #page_id#</cfoutput><br />
                --->
                </cfif>
            <cfelse>
                <cfset local.urls["#burl#"] = page_id>
            </cfif>
        </cfif>
<!---
        <cfoutput>S: #page_id#, #treeDate#, #burl#</cfoutput><br />    
--->

        <cfif burl NEQ "">        
            <cfinvoke component="redirects" method="insertUrl">
            	<cfinvokeargument name="url" value="#burl#">
                <cfinvokeargument name="id" value="#page_id#">
    			<!--- <cfinvokeargument name="idHistory" value="#qPage.idHistory#"> --->
                <cfinvokeargument name="useddate" value="#treeDate#">
    		</cfinvoke>             
        </cfif>
    </cfloop>

    <cfreturn treedate>
</cffunction>

<cffunction name="insertUrl" access="public" output="false" returntype="void">
	<cfargument name="url" type="string">
    <cfargument name="id" type="numeric">
	<cfargument name="idHistory" type="numeric">
    <cfargument name="useddate" type="date">

	<cfset var redirect = structNew()>
    <cfset var qPage = "">
    <cfset var dt = now()>
	
	<cfset redirect.usedDate = arguments.useddate>
    <cfset redirect.createdDate = dt>
    <cfset redirect.createdBy = "system">
    <cfset redirect.modifiedDate = dt>
    <cfset redirect.modifiedBy = "system">
    <cfset redirect.deleted = "F">
    <cfset redirect.MD5 = hash(arguments.url, 'MD5')>
    <cfset redirect.url = arguments.url>
    <cfset redirect.id = arguments.id>
    <cfset redirect.idHistory = 0>
	
    <cftransaction>

	<!--- Does any previous page with this ID to exist with the same url? 
		We DON'T want to redirect to the same page ! :-)
		
		Delete all duplicates of the past!  	
	--->
    <cfquery datasource="#application.datasource#">
		delete from mrl_redirect where 
		md5 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#redirect.MD5#"> 
    </cfquery>
	
	<!--- get the last url title and see if the entry exists --->
    <cfquery datasource="#application.datasource#" name="qPage">
    	select top 1 url, idHistory, MD5 from mrl_redirect
        where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#redirect.id#">
        order by usedDate DESC
    </cfquery>

	<!--- update previous urls to point to the last url --->
    <cfif qPage.recordCount gt 0>
    	<cfquery datasource="#application.datasource#">
            update mrl_redirect set 
            redirectId = <cfqueryparam cfsqltype="cf_sql_integer" value="#redirect.id#">
            , redirect = <cfqueryparam cfsqltype="cf_sql_varchar" value="#redirect.url#">
            , modifiedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
            where redirect = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qPage.url#"> 
			or url = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qPage.url#"> 
        	or id = <cfqueryparam cfsqltype="cf_sql_integer" value="#redirect.id#">
        </cfquery>
    </cfif>
    
    <!--- insert the new entry --->
    <cfquery datasource="#application.datasource#">
    	insert into mrl_redirect (usedDate, createdDate, createdBy, modifiedDate, modifiedBy, deleted, md5, url, id, idHistory) 
        VALUES (
        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#redirect.usedDate#">
       ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#redirect.createdDate#">
       ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#redirect.createdBy#">
       ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#redirect.modifiedDate#">
       ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#redirect.modifiedBy#">
       ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#redirect.deleted#">
       ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#redirect.MD5#">
       ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#redirect.url#">
       ,<cfqueryparam cfsqltype="cf_sql_numeric" value="#redirect.id#">
       ,<cfqueryparam cfsqltype="cf_sql_numeric" value="#redirect.idHistory#">
       )
	</cfquery>

    </cftransaction>

    
</cffunction>

<cffunction name="getBread" access="public" output="false" returntype="array">
	<cfargument name="id" type="numeric">
    <cfargument name="db" type="query">
    <cfargument name="root" type="numeric">
    
    <cfset var qPage = "">
    <cfset var urlArray = "">
    <cfset var urlList = "">
    
	<cfquery dbtype="query" name="qPage">
    	select * from db
        where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
    </cfquery>
    
    <cfif qPage.recordCount eq 1>
    	<cfset urlList = listPrepend(urlList, qPage.url)>
        
        <cfif qPage.idParent NEQ root>
     		<cfset urlArray = getBread(qPage.idParent, arguments.db, arguments.root)>   
        	<cfif arrayLen(urlArray) GT 0>
            	<cfset urlList = listPrepend(urlList, arrayToList(urlArray))>
            </cfif>
        </cfif> 
    </cfif>

	<cfreturn listToArray(urlList)>
    
</cffunction>

<cffunction name="getAllSubs" access="public" output="false" returntype="array">
	<cfargument name="id" type="numeric">
    <cfargument name="db" type="query">

    <cfset var idArray = arrayNew(1)>
    <cfset var idArray2 = arrayNew(1)>
    
    <cfset arrayAppend(idArray, arguments.id)>
    
    <cfloop condition="arrayIsEmpty(idArray) EQ false">
        <cfloop query="db">
        	<cfif db.idParent EQ idArray[1]>
            	<cfset arrayAppend(idArray, db.id)>
            </cfif>
        </cfloop>
        
        <cfset arrayAppend(idArray2, idArray[1])>
        <cfset arrayDeleteAt(idArray, 1)>
        
    </cfloop>
    
    <cfreturn idArray2>
</cffunction>


<cffunction name="getOldTree" access="public" output="false" returntype="query">
    <cfargument name="treedate" type="date" required="true">
    <cfargument name="id_root" type="numeric" required="true">
    <cfargument name="walktree2" type="boolean" required="false" default="false">
    
    <cfset var qLogs = "">
    <cfset var qOldPages = "">

    <!--- get all the logs --->
    <cfquery datasource="#application.datasource#" name="qLogs">
        select * from mrl_pageMoveLog
        order by dateTime desc
    </cfquery>

    <!--- get a list of pages from the point in time of treedate --->
    <cfquery datasource="#application.datasource#" name="qOldPages">
        
        select distinct g.id, (
            select idParent 
            from mrl_page 
            where id = g.id
        ) as idParent,
        (
            select top 1 idHistory 
            from mrl_pageRevision 
            where id = g.id and usedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.treeDate#"> and state = 'approved'
            order by usedDate desc) as idHistory, 
        (
            select top 1 url 
            from mrl_pageRevision 
            where id = g.id and usedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.treeDate#"> and state = 'approved'
            order by usedDate desc) as url
        from mrl_pageRevision as g
        where g.state = 'approved' and g.usedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.treeDate#">
<!---        order by ID asc --->
<!---
        select id, idParent as idParent, (
            select top 1 idHistory 
            from mrl_pageRevision 
            where id = g.id and usedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#treeDate#"> and state = 'approved'
            order by usedDate desc
        ) as idHistory, (
            select top 1 url 
            from mrl_pageRevision 
            where id = g.id and usedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#treeDate#"> and state = 'approved'
            order by usedDate desc) as url
        from mrl_siteAdmin as g --->
    </cfquery>

    <!--- replay all page move logs back to the treedate point --->     
    <cfloop query="qLogs">
        <!--- break once we reach far enough back in the logs --->
        <cfif dateCompare(qLogs.dateTime, arguments.treeDate) EQ -1>
            <cfbreak>
        </cfif>
        
        <!--- loop through the site tree to update the record of a page move --->
        <!--- SPEED UP --->
        <cfloop query="qOldPages">
            <cfif qOldPages.ID EQ qLogs.id>
                <cfset QuerySetCell(qOldPages, "IDPARENT", qLogs.OLDPARENT, qOldPages.CurrentRow)>
                <cfbreak>
            </cfif>
        </cfloop>
    </cfloop>
   
    <cfreturn qOldPages>
</cffunction>


</cfcomponent>