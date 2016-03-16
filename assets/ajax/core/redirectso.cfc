<cfcomponent output="false">

<cffunction name="getHistory" public="true" output="true" access="remote">
</cffunction>

<cffunction name="ValidateTable" public="true" output="true" access="remote">
	<cfset var qPages = "">
	<cfset var orphaned = 0>

	<cfquery datasource="#application.datasource#" name="qPages">
		select id from mrl_sitePublic
	</cfquery>
	
	<!--- create the page helper --->
	<cfset variables.ph = createObject("component", "pageHelper").init(
		datasource: application.datasource, 
		useRedirectTable: false, 
		URLRewriter: true
	)>
	
	<!--- create the page helper --->
	<cfset variables.phtable = createObject("component", "pageHelper").init(
		datasource: application.datasource, 
		useRedirectTable: true, 
		URLRewriter: true
	)>

	<cfloop query="qPages">
		<cfset pageURLTable = phtable.pageIdToURL(page_id: qPages.id)>
		<cfset pageURL = ph.pageIdToURL(page_id: qPages.id)>
		<cfif pageURL NEQ pageURLTable>
			<cfif isNumeric(pageURL) AND NOT isNumeric(pageURLTable)>
				<cfset orphaned = orphaned + 1>
			<cfelse>
				<cfoutput>URL Lookup: #pageURL#<br></cfoutput>
				<cfoutput>Redirect Table: #pageURLTable#<br></cfoutput>
			</cfif>
		</cfif>
	</cfloop>
	<cfif orphaned GT 0>
		<br />Orphaned Pages: #orphaned#<br />
	</cfif>
</cffunction>

<cffunction name="optimizeID" public="true" output="false" access="remote">
	<cfargument name="page_id" type="numeric" required="true" > 
	<cfset var qPage = "">
	
	<!--- SEO crap - update the redirects table --->
	<!--- 
	<cfthread action="run" name="#CreateUUID()#" mypage="#arguments.page_id#" priority="LOW">
	<cflock name="#application.applicationname#redirects" timeout="180" type="exclusive" > 			           
		<!--- get the history id for the id --->
		<cfquery datasource="#application.datasource#" name="thread.qPage" >  
			select idHistory from mrl_sitePublic 
			where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#mypage#">
		</cfquery>
		
		<cfif thread.qPage.recordCount EQ 0>
			<cfreturn>
		<cfelse>	
			<cfset addHistoryId(history_id: thread.qPage.idHistory)>
		</cfif>
	</cflock>
	</cfthread>
	--->
	
	<cflock name="#application.applicationname#redirects" timeout="360" type="exclusive" > 			           
		<!--- get the history id for the id --->
		<cfquery datasource="#application.datasource#" name="qPage" >  
			select idHistory from mrl_sitePublic 
			where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
		</cfquery>
		
		<cfif qPage.recordCount EQ 0>
			<cfreturn>
		<cfelse>	
			<cfset addHistoryId(history_id: qPage.idHistory)>
		</cfif>
	</cflock>
</cffunction>

<cffunction name="addHistoryId" output="false">
	<cfargument name="history_id" type="numeric">

	<cfset var qTree = "">
    <cfset var pageSubs = "">
    <cfset var page_id = "">
    <cfset var bread = "">
    <cfset var burl = "">
	<cfset var qPage = "">

	<!--- get the info for the history_id --->
	<cfquery datasource="#application.datasource#" name="qPage">
    	select usedDate, id, idHistory from mrl_siteHistory 
        where idHistory = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.history_id#">
    </cfquery>	

    <!--- generate the old site map / tree --->
    <cfinvoke component="redirects" method="getOldTree" returnvariable="qTree">
		<cfinvokeargument name="treedate" value="#qPage.usedDate#">
        <cfinvokeargument name="id_root" value="#application.tree.rootid#">
    </cfinvoke>
   
    <!--- get the list of all pages that need to be resolved --->
    <cfinvoke component="redirects" method="getAllSubs" returnvariable="pageSubs">
		<cfinvokeargument name="id" value="#qPage.id#">
        <cfinvokeargument name="db" value="#qTree#">
    </cfinvoke>
	
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
		
        <cfinvoke component="redirects" method="insertUrl">
        	<cfinvokeargument name="url" value="#burl#">
            <cfinvokeargument name="id" value="#page_id#">
			<!--- <cfinvokeargument name="idHistory" value="#qPage.idHistory#"> --->
            <cfinvokeargument name="useddate" value="#qPage.usedDate#">
		</cfinvoke>             
    </cfloop>
    
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

<cffunction name="getAllSubsOld" access="public" output="false" returntype="array">
	<cfargument name="id" type="numeric">
    <cfargument name="db" type="query">
    <cfargument name="level" type="numeric" required="false" default="0">
    
    <cfset var qPages = "">
    <cfset var idlist = "">
    <cfset var idsubs = "">
    
    <cfif arguments.level EQ 0>
    	<cfset idlist = arguments.id>
    </cfif>
    
    <cfquery datasource="#application.datasource#" dbtype="query" name="qPages">
        select * from arguments.db where 
        idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
    
    <cfloop query="qPages">
    	<cfset idlist = listAppend(idlist, qPages.id)>
        <cfset idsubs = getAllSubs(qPages.id, arguments.db, arguments.level + 1)>
    	<cfif arrayLen(idsubs) gt 0>
        	<cfset idlist = listAppend(idlist, arrayToList(idsubs))>
        </cfif>
    </cfloop>
    
    <cfreturn listtoArray(idlist)>
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

<cffunction name="getSiteTree" access="public" output="false" returntype="query" hint="get the site tree as a query">
	<cfargument name="root_id" type="numeric" required="true">
    
    <cfset var qSiteTree = "">
    
    <!--- this query seems touchy with SQL.  Look into this.  
    Sometimes it runs in 125ms but other times 
    with the same parameters, it takes 4000ms!!! ---> 
	<cfquery datasource="#application.datasource#" name="qSiteTree">
    with PagesList(id, idParent, menu, url, level)
        AS
        (
            -- Anchor member def
            SELECT id, idparent, menu, url, (0) as level 
            FROM mrl_siteAdmin
            WHERE idparent = <cfqueryparam cfsqltype="cf_sql_integer" value="#root_id#">
    
            UNION ALL
    
            -- Recursive member def
            SELECT c.id, c.idparent, c.menu, c.url, p.level + 1 
            FROM mrl_siteAdmin as c
            INNER JOIN PagesList as p
            ON c.idparent = p.id
        )
        -- Statement that executes the CTE
    SELECT id, idParent, menu, url, level FROM PagesList ORDER BY level ASC
    </cfquery>
    
    <cfreturn qSiteTree>
</cffunction>

<cffunction name="getOldTree" access="public" output="false" returntype="query">
	<cfargument name="treedate" type="date" required="true">
    <cfargument name="id_root" type="numeric" required="true">
    <cfargument name="walktree2" type="boolean" required="false" default="false">
    
    <cfset var qPages = "">
    <cfset var qPage = "">
    <cfset var qLogs = "">
    <cfset var qOldPages = "">
    <cfset var qFinal = "">
    <cfset var mylist = "">

    <cfset var t1 = "">
	<cfset var t2 = "">

	<cfset qPages = getSiteTree(root_id: arguments.id_root)>
    
    <!--- get all the logs --->
    <cfquery datasource="#application.datasource#" name="qLogs">
        select * from mrl_pageMoveLog
        order by dateTime desc
    </cfquery>

	<!--- replay all page move logs back to the treedate point --->     
    <cfloop query="qLogs">
        <!--- break once we reach far enough back in the logs --->
        <cfif dateCompare(qLogs.dateTime, treeDate) EQ -1>
            <cfbreak>
        </cfif>
		
		<!--- loop through the site tree to update the record of a page move --->
        <cfloop query="qPages">
        	<cfif qPages.ID EQ qLogs.id>
            	<cfset QuerySetCell(qPages, "IDPARENT", qLogs.OLDPARENT, qPages.CurrentRow)>
            </cfif>
            <cfbreak>
        </cfloop>
    </cfloop>

	<!--- get a list of pages from the point in time of treedate --->
    <cfquery datasource="#application.datasource#" name="qOldPages">
        select distinct g.id, (
            select top 1 idHistory 
            from mrl_pageRevision 
            where id = g.id and usedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#treeDate#"> and state = 'approved'
            order by usedDate desc) as idHistory, 
        (
            select top 1 url 
            from mrl_pageRevision 
            where id = g.id and usedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#treeDate#"> and state = 'approved'
            order by usedDate desc) as url
        from mrl_pageRevision as g
        where g.state = 'approved' and g.usedDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#treeDate#">
    	order by ID asc
    </cfquery>

<!---
	<!--- re-order IDs in a query of queries. Much faster than doing in the above query --->
    <cfquery dbtype="query" name="qOldPages">
        select * from qOldPages
        order by ID asc
    </cfquery>
--->

	<!---     
    <cfif arguments.walktree EQ true>
    	<cfset qFinal = walkTree(qPages)>
    <cfelse>
    	<cfset qFinal = qPages>
    </cfif>
	--->
    
    <cfset qFinal = qPages>
    
    <!--- put all the page id's in a list --->
    <cfset mylist = "">
    <cfloop query="qOldPages">
        <cfset mylist = listAppend(mylist, qOldPages.ID)>
    </cfloop>
    
    <!--- use the list to filter out pages that were not present at treedate --->
    <cfquery dbtype="query" name="qFinal">
        select * from qFinal 
        where ID in (<cfqueryparam list="true" cfsqltype="cf_sql_integer" value="#mylist#">)
		order by ID asc
    </cfquery>
    
    <!--- clean out old pages --->
	<!--- 	
    <cfquery dbtype="query" name="qFinal">
        select * from qFinal
        order by ID asc
    </cfquery>
    --->  
    
    <!--- set the page urls to the old urls --->
    <cfif qFinal.getRowCount() EQ qOldPages.getRowCount()>
        <cfloop query="qOldPages">
            <cfset QuerySetCell(qFinal, "URL", qOldPages.URL, qOldPages.CurrentRow)>
        </cfloop>
    <cfelse>
        ERROR - DBs not the same size!
        <!--- <cfdump var="#qFinal#">
        <cfdump var="#qOldPages#"> --->

        <cfabort>
    </cfif>

	<!--- 
	<cfif arguments.walktree EQ true>
        <cfquery dbtype="query" name="qFinal">
            select * from qFinal
            order by level asc
        </cfquery>
	</cfif>        
   --->
   
	<cfreturn qFinal>
</cffunction>

<cffunction name="walkTree" access="private" output="false" returntype="query">
	<cfargument name="qTree">
    <cfargument name="id" default="0">
    <cfargument name="level" default="0">
    
    <cfset var qPages = "">
    <cfset var qPages2 = "">
    <cfset var qPagesFinal = "">
 
    <cfquery dbtype="query" name="qPages">
		select * from qTree where idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
    </cfquery>    
    
    <cfloop query="qPages">
   		<cfset temp = QuerySetCell(qPages, "LEVEL", arguments.level, qPages.CurrentRow)>
    </cfloop>
    
    <cfset qPagesFinal = qPages>
    
	<cfloop query="qPages">
        
        <cfset qPages2 = walkTree(arguments.qTree, qPages.id, arguments.level + 1)>
        
        <cfif isQuery(qPages2)>
            
            <cfquery dbtype="query" name="qPagesFinal">
             	select * from qPagesFinal
                    
                UNION
                    
                select * from qPages2
            </cfquery>
        </cfif>
    </cfloop>
    
    <cfif arguments.level eq 0>
    	<cfquery dbtype="query" name="qPagesFinal">
        	select * from qPagesFinal
            order by level
        </cfquery>
    </cfif>
    
    <cfreturn qPagesFinal>
</cffunction>

<cffunction name="buildTree" access="public" output="false" returntype="struct">
	<cfargument name="id" type="numeric">
    <cfargument name="db" type="any" default="">
    
    <cfset var root = "">
    <cfset var qSiteAdmin = "">
    <cfset var page = "">
    <cfset var parent = "">

	<cfif isQuery(arguments.db)>
    	<cfset qSiteAdmin = arguments.db>
	<cfelse>    
        <cfquery datasource="#application.datasource#" name="qSiteAdmin">
            select id, idParent, url
            from mrl_siteAdmin
            order by idParent, id asc
        </cfquery>
	</cfif>

	<!--- create tree --->
    <cfset root = structNew()>
    <cfset root.url = "homepage">
    <cfset root.children = structNew()>
        
    <cfloop query="qSiteAdmin">
        <cfset page = structNew()>
        <cfset page.url = qSiteAdmin.url>
        <cfset page.children = structNew()>
    
    	<cfif qSiteAdmin.idParent EQ arguments.id>
        	<cfset root.children['#qSiteAdmin.id#'] = page>
        <cfelse>
           	<cfset parent = StructFindKey(root, qSiteAdmin.idParent)>
			<!--- <cfset parent = findNode(root, qSiteAdmin.idParent)> --->
            
            <cfif arrayLen(parent) gt 0>
                <cfset parent[1].value.children['#qSiteAdmin.id#'] = page>
            <cfelse>
            	<cfoutput>#qSiteAdmin.idParent#</cfoutput><br />
            </cfif>
        </cfif>
    </cfloop>

	<cfreturn root>
    
</cffunction>


</cfcomponent>