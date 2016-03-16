<cfcomponent output="false">

<cffunction name="ValidateTable" public="true" output="true" access="remote">
    <cfargument name="page_id" type="numeric" required="false" default="0">
    <cfset var qPages = "">
    <cfset var orphaned = 0>
    <cfset var orphanedPages = arrayNew(1)>

    <cfif arguments.page_id EQ 0>
        <cfsetting requesttimeout="999999">   
    </cfif>

    <cfquery datasource="#application.datasource#" name="qPages">
        select id, title from mrl_sitePublic
        <cfif page_id NEQ 0>
            where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
        </cfif>
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
            <cfabort>
        </cfif>

    </cfloop>
    <cfif orphaned GT 0>
        <br />Orphaned Pages: #orphaned#<br />
        <cfloop array="#orphanedPages#" index="local.i">
            <cfoutput>#local.i#</cfoutput><br />
        </cfloop>
    </cfif>


</cffunction>

<!--- This is for newly updated or created pages --->
<cffunction name="optimizeID" public="true" output="false" access="remote" returntype="ANY">
	<cfargument name="page_id" type="numeric" required="true">
    <cfargument name="ignore_subs" type="boolean" required="false" default="false">
    <cfargument name="force" type="boolean" required="false" default="false"> 

    <!--- create the page helper --->
    <cfset local.ph = createObject("component", "marloo.core.pageHelper").init(
        datasource: application.datasource, 
        useRedirectTable: false, 
        URLRewriter: true,
        site_config: application.site_config
    )>

    <!--- get the used date and idHistory for the page --->
    <cfquery datasource="#application.datasource#" name="local.qPage">
        select idHistory, modifiedDate as usedDate, url from mrl_siteAdmin 
        where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
    </cfquery>

    <!--- get the list of all pages that need to be resolved and the relative urls --->
    <cfquery datasource="#application.datasource#" name="local.qPageSubs">        
        WITH pages as
        (
          SELECT sp.id, sp.IdParent, CAST(sp.url AS VarChar(Max)) as relUrl
          FROM mrl_sitePublic sp
          WHERE sp.IdParent =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">

          UNION ALL

          SELECT sp2.id, sp2.IdParent, M.relUrl + '/' + CAST(sp2.url AS VarChar(Max))
          FROM mrl_sitePublic sp2  
          INNER JOIN pages M
          ON M.id = sp2.IdParent
         )
        SELECT * From pages
    </cfquery>

    <cfset local.fixedPages = structNew()>

    <!--- create the base url --->
    <!--- get the breadcrumbs for the current page --->
    <cfset local.pageBreadCrumbs = local.ph.getBreadcrumbs(page_id: arguments.page_id, useCache: false)>
    <cfset local.baseUrl = ''>
    <cfset local.root_id = application.site_config.cms.tree.rootid>

    <!--- bail out if page is orphaned --->
    <cfif local.pageBreadCrumbs.orphaned EQ true>
        <cfreturn>
    </cfif>

    <!--- build urls from the bread crumbs --->
    <cfloop query="local.pageBreadCrumbs.query">
        <!--- ignore root --->
        <cfif local.pageBreadCrumbs.query.id NEQ local.root_id OR arguments.page_id EQ local.root_id>            
            <cfset local.baseUrl = local.baseUrl & local.pageBreadCrumbs.query.url & '/'>
        </cfif>
    </cfloop> 

    <!--- *** BAIL OUT *** --->
    <!--- bail out if the page url has not changed --->
    <cfif isDuplicate(url: local.baseUrl, page_id: arguments.page_id) AND arguments.force EQ false>
        <cfreturn local.qPage.usedDate>
    </cfif> 

    <!--- update the changed page --->
    <cfinvoke component="redirects" method="insertUrl">
        <cfinvokeargument name="url" value="#local.baseUrl#">
        <cfinvokeargument name="id" value="#arguments.page_id#">
        <cfinvokeargument name="useddate" value="#local.qPage.usedDate#">
    </cfinvoke>

    <!--- *** BAIL OUT *** --->
    <!--- bail out early if the page is the root --->
    <cfif arguments.page_id EQ local.root_id OR arguments.ignore_subs EQ true>
        <cfreturn local.qPage.usedDate>        
    </cfif>

    <!--- update the sub pages --->
    <cfloop query="local.qPageSubs">
        <cfset local.page_url = local.baseUrl & local.qPageSubs.relUrl & '/'>       
        <cfinvoke component="redirects" method="insertUrl">
            <cfinvokeargument name="url" value="#local.page_url#">
            <cfinvokeargument name="id" value="#local.qPageSubs.id#">
            <cfinvokeargument name="useddate" value="#local.qPage.usedDate#">
        </cfinvoke>             
    </cfloop>

    <cfreturn local.qPage.usedDate>
</cffunction>


<cffunction name="isDuplicate" returntype="boolean" output="false">
    <cfargument name="url" type="string" required="true">
    <cfargument name="page_id" type="numeric" required="true">    

     <!--- check for duplicate entry.  This means the title has not changed --->
    <cfquery datasource="#application.datasource#" name="qDuplicate">
        select count(*) as count from mrl_redirect
        where md5 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#createURLHash(url: arguments.url)#">
        and id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
        and redirect is null
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

    <cfset pageURLTable = phtable.pageIdToURL(page_id: arguments.page_id)>
    <cfset pageURL = ph.pageIdToURL(page_id: arguments.page_id)>

    <cfif qDuplicate.count EQ 1 AND pageURLTable EQ pageURL>
        <cfreturn true>
    </cfif>

    <cfreturn false>
</cffunction>


<cffunction name="createURLHash" access="private" output="false" returntype="string">
    <cfargument name="url" type="string" required="true">
    <cfreturn hash(arguments.url, 'MD5')>
</cffunction>


<cffunction name="insertUrl" access="public" output="false" returntype="boolean">
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
    <cfset redirect.MD5 = createURLHash(url: arguments.url)>
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

    <cfreturn true>
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