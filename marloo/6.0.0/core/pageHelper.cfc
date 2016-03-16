<cfcomponent>

<cfset variables.datasource = "">
<cfset variables.useRedirectTable = false>
<cfset variables.URLRewriter = false>
<cfset variables.ssl = true>
<cfset variables.urlStruct = "">
<cfset variables.site_config = "">
<cfset variables.includeQueryString = true>

<cffunction name="init" access="public" returntype="pageHelper">
	<cfargument name="site_config" type="struct" required="true">
	<cfargument name="datasource" type="string" required="false">
	<cfargument name="useRedirectTable" type="boolean" required="false">
	<cfargument name="URLRewriter" type="boolean" required="false">

	<cfset variables.datasource = arguments.site_config.datasource>
	<cfset variables.useRedirectTable = arguments.site_config.useRedirectTable>
	<cfset variables.URLRewriter = arguments.site_config.URLRewriter>
	<cfset variables.ssl = arguments.site_config.CMS.ssl>

	<cfif NOT isNull(arguments.datasource)>
		<cfset variables.datasource = arguments.datasource>
	</cfif>

	<cfif NOT isNull(arguments.useRedirectTable)>
		<cfset variables.useRedirectTable = arguments.useRedirectTable>
	</cfif>

	<cfif NOT isNull(arguments.URLRewriter)>
		<cfset variables.URLRewriter = arguments.URLRewriter>
	</cfif>

	<cfset variables.site_config = arguments.site_config>

	<cfreturn this>
</cffunction>

<cffunction name="SEOUrlsToId" output="false">
	<cfargument name="pageHTML" type="string" required="true">
	<cfargument name="site_config" type="struct" required="false" default="variables.site_config">
	<cfargument name="datasource" type="string" required="false" default="variables.datasource">

	<cfset var changed = false>

	<!--- find all page ids --->
    <cfset var found = 1>
    <cfset var stripPast = 0>
    <cfset var mychar = "">
    <cfset var myid = "">
    <cfset var myurl = "">
    <cfset var myhtml = arguments.pagehtml>
    <cfset var quoteChar = "">

    <cfloop condition="found GT 0">
        <cfset stripPast = found + 1>
        <cfset found = findnocase('href=', myHTML, stripPast)> 
        
        <cfif found EQ 0>
        	<cfbreak>
       	</cfif>

       	<!--- get the quote used, could be single or double --->
       	<cfset quoteChar = mid(myHTML, found + 5, 1)>

        <cfset found = found + 6>

        <!--- ignore urls in the correct format --->
       	<cfif lcase(mid(myHTML, found, 8)) EQ 'page.cfm'>
	       	<cfcontinue>
       	</cfif>

        <!--- ignore non-relative links --->
       	<cfif lcase(mid(myHTML, found, 4)) EQ 'http'>
	       	<cfcontinue>
       	</cfif>

        <!--- ignore mailto --->
       	<cfif lcase(mid(myHTML, found, 6)) EQ 'mailto'>
	       	<cfcontinue>
       	</cfif>

       	<!--- ignore non-relative urls --->
       	<cfif lcase(mid(myHTML, found, 2)) EQ '//'>
	       	<cfcontinue>
       	</cfif>

       	<!--- ignore # urls --->
       	<cfif lcase(mid(myHTML, found, 1)) EQ '##'>
	       	<cfcontinue>
       	</cfif>

		<!--- find the closing quote --->
		<cfset foundend = find(quoteChar, myHTML, found)>
		<cfset myurl = getToken(mid(myHTML, found, foundend - found), 1, '##')>
		<cfset query = getToken(myurl, 2, '?')>
		<cfset path = getToken(myurl, 1, '?')>

		<!--- fix path if it does not contain a trailing / --->
		<cfif right(path, 1) NEQ '/'>
			<cfset path = path & '/'>
		</cfif>

		<cfset fragment = getToken(mid(myHTML, found, foundend - found), 2, '##')>

		<cfset oldUrl = mid(myHTML, found - 6, foundend + 1 - (found - 6))>

<!---
        <cfdump var="#path#" label="path">
        <cfdump var="#query#" label="query">
        <cfdump var="#fragment#" label="fragment">
--->
<!---
        <cfinvoke component="marloo.core.pageHelper" method="pageUrlToId" returnvariable="mypage">
        	<cfinvokeargument name="page_url" value="#path#">
	        <cfinvokeargument name="root_id" value="#application.site_config.cms.tree.rootid#">
		    <cfinvokeargument name="datasource" value="#application.datasource#">
			<cfinvokeargument name="userRedirectTable" value="true">
		</cfinvoke>
--->
		<cfset mypage = pageUrlToId(page_url: path, root_id: arguments.site_config.cms.tree.rootid, datasource: arguments.datasource, useRedirectTable: true)>

		<cfif NOT isNumeric(mypage.id)>
			<cfcontinue>
		</cfif>

		<!--- put the new url back together --->			
		<cfset newUrl = "page.cfm?page_id=#mypage.id#">

		<cfif query NEQ "">
			<cfset newUrl = newUrl & '&' & query> 
		</cfif>

		<cfif fragment NEQ "">
			<cfset newUrl = newUrl & '##' & fragment>
		</cfif>

		<cfset newUrl = 'href="' & newURL & '"'>

		<!--- replace the old url in the html --->
		<cfset changed = true>
		<cfset myHTML = replace(myhtml, oldUrl, newUrl, 'all')>
<!---
		<cfdump var="#oldUrl# -> #newUrl#"><br />
--->
        <cfset found = found + 1>      
    </cfloop>

    <cfif changed EQ true>
	    <cfreturn myHTML>    
    </cfif>

    <cfreturn arguments.pageHTML>
</cffunction> 

<cffunction name="webToFilePath" access="public" output="false" returntype="struct">
	<cfargument name="src" type="string" required="true">
	<cfargument name="site_config" type="struct" required="false" default="#variables.site_config#">

	<cfset local.path = {
		webPath = arguments.src,
		filePath = ""
	}>

	<cfif findnocase("http", local.path.webPath) eq 0>
	    <!--- WE - NEW SHIT ---> 
	    <cfset local.pos1 = mid(arguments.site_config.cms.web.groups, 1, find("//", arguments.site_config.cms.web.groups))>
	    <cfset local.pos1 = len(local.pos1) + 2>
	    <cfset local.pos2 = find("/", arguments.site_config.cms.web.groups, local.pos1)>

	    <cfset local.groupPath = mid(arguments.site_config.cms.web.groups, local.pos2 + 1, len(arguments.site_config.cms.web.groups) - local.pos2)>
	    <cfset local.path.webPath = replace(local.path.webPath, local.groupPath, "")>
	    <!--- END OF NEW SHIT --->

	    <cfset local.path.filePath = URLDecode(local.path.webPath)>
	    <cfset local.path.filePath = arguments.site_config.cms.path.groups & replacenocase(local.path.filePath, '/', '\', 'all')>
	    <cfset local.path.webPath = arguments.site_config.cms.web.groups & local.path.webPath>

	    <!--- strip out ? --->
	    <cfset local.path.filePath = getToken(local.path.filePath, 1, '?')>
	</cfif>

	<cfreturn local.path>

</cffunction>


<!--- gets children pages --->	   
<cffunction name="getChildren" access="public" output="false" returntype="query">
   	<cfargument name="page_id" required="true" type="numeric">
	<cfargument name="datasource" type="string" required="false" hint="CMS Datasource" default="#variables.datasource#">
	<cfargument name="useAlphaorder" type="boolean" required="false" default="false">
	<cfargument name="summary" required="false" type="boolean" default="true" > 

   	<cfstoredproc datasource="#arguments.datasource#" procedure="mrl_getChildren">
		 <cfprocparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
		 <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.summary#">
		 <cfprocparam cfsqltype="cf_sql_bit" value="true">
		 <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.useAlphaorder#">
		 <!--- Give me everything --->
		 <cfprocresult name="local.qChildren">
	</cfstoredproc>

   	<cfreturn local.qChildren>
</cffunction>

<cffunction name="getSiblings" access="public" returntype="query" output="false">
	<cfreturn getPeers(argumentCollection: arguments)>
</cffunction>

<cffunction name="getIdUrl" access="public" returntype="string" output="false">
	<cfargument name="page_id" required="true" type="numeric">
	<!--- if the ID is invalid, return the current url --->
	<cfif arguments.page_id EQ -1>
		<cfset local.ustring = getCurrentURL()>
	<cfelse>
		<cfset local.u = getCurrentURL(returnType: 'struct')> 
		<cfif local.u.port NEQ 80>
			<cfset local.ustring = "#local.u.scheme##local.u.domain#:#local.u.port#/page.cfm?page_ID=#page_id#">
		<cfelse>
			<cfset local.ustring = "#local.u.scheme##local.u.domain#/page.cfm?page_ID=#page_id#">
		</cfif>
	</cfif>

	<cfreturn "#local.ustring#">
</cffunction>

<cffunction name="getPeers" access="public" returntype="query" output="false">
	<cfargument name="page_id" type="numeric" required="true" hint="page_id">
	<cfargument name="datasource" type="string" required="false" hint="CMS Datasource" default="#variables.datasource#">
	<cfargument name="useAlphaorder" type="boolean" required="false" default="false">

	<!--- get the peer pages --->
	<cfstoredproc datasource="#arguments.datasource#" procedure="mrl_getPeers">
	  	<cfprocparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
	  	<cfprocparam cfsqltype="cf_sql_bit" value="#true#">
      	<cfprocparam cfsqltype="cf_sql_bit" value="#true#">           
      	<cfprocparam cfsqltype="cf_sql_bit" value="#arguments.useAlphaorder#">
		<cfprocresult name="local.qPeers">
	</cfstoredproc> 
		
	<cfreturn local.qPeers>
</cffunction>

<cffunction name="getQueryString" access="public" output="false" returntype="string">
	<cfargument name="excludeReserved" type="boolean" required="false" default="true">
	<cfargument name="useRedirectTable" type="boolean" required="false" default="#variables.useRedirectTable#">

	<cfset var queryString = "">
	<cfset var urlItem = "">
	<cfset var skip = false>

	<cfif arguments.excludeReserved EQ false>
		<cfreturn cgi.query_string>
	<cfelse>
		<cfloop collection="#url#" item="urlItem">
			<cfset skip = false>
			<cfswitch expression="#lcase(urlItem)#">
				<cfcase value="rewriteitem">
					<cfset skip = true>
				</cfcase>
				<cfcase value="page_id">
					<cfif arguments.useRedirectTable EQ true>
						<cfset skip = true>
					</cfif> 
				</cfcase>
			</cfswitch>
			<cfif skip NEQ true>
				<cfif queryString NEQ "">
					<cfset queryString = queryString & "&">
				</cfif>
				<cfset queryString = queryString & urlItem & "=" & url["#urlItem#"]>
			</cfif>
		</cfloop>
	</cfif>

	<cfreturn queryString>
</cffunction>

<cffunction access="public" name="isConnSSL" output="false" returntype="boolean">
    <cfreturn cgi.server_port_secure>
</cffunction>

<cffunction access="public" name="setSSL" output="false" returntype="boolean">
   	<cfargument name="state" required="false" type="boolean" default="true">
    
    <cfset var my_url = getCurrentURL(returnType: 'struct')>   

    <cfif state eq true and isConnSSL() eq false>
		<cfif variables.ssl EQ true>
			<cfset my_url.scheme = "https://">
			<cflocation url="#genURLString(my_url)#" statuscode="301" />	
        </cfif>
    </cfif>
    
    <cfif state eq false and isConnSSL() eq true>
		<cfset my_url.scheme = "http://">
		<cflocation url="#genURLString(my_url)#" statuscode="301" />	
   	</cfif>        
   	
   	<cfreturn true>
</cffunction>

<cffunction access="private" name="genURLString" output="false" returntype="string">
	<cfargument name="urlStruct" type="struct" required="true">
	<cfargument name="filterDefaultCFM" type="boolean" required="false" default="true">

	<cfset var urlPath = arguments.urlStruct.path>
	<cfset var urlString = "">

	<!--- filter out default.cfm and index.cfm--->		
	<cfif arguments.filterDefaultCFM EQ true>
		<cfif (len(urlPath) - 10) GT 0 AND lcase(mid(urlPath, len(urlPath) - 10, 11)) EQ "default.cfm">
			<cfset urlPath = mid(urlPath, 1, len(urlPath) - 11)>  
		<cfelseif (len(urlPath) - 8) GT 0 AND lcase(mid(urlPath, len(urlPath) - 8, 9)) EQ "index.cfm">
			<cfset urlPath = mid(urlPath, 1, len(urlPath) - 9)>
		</cfif>
	</cfif>

	<cfset urlString = urlStruct.scheme & urlStruct.domain>
	
	<cfif cgi.server_port NEQ 80 AND cgi.server_port NEQ 443>
		<cfset urlString = urlString & ":" & urlStruct.port>
	</cfif>
	
	<cfset urlString = urlString & urlPath>

	<cfif urlStruct.query NEQ "">
		<cfset urlString = urlString & "?" & urlStruct.query>
	</cfif>	 
	
	<cfreturn urlString>
</cffunction>

<cffunction access="public" name="setIncludeQueryString" output="false" returntype="void" hint="sets this option for method getCurrentUrl">
	<cfargument name="includeQueryString" type="boolean" required="true">

	<cfset variables.includeQueryString = arguments.includeQueryString>
</cffunction>

<cffunction access="public" name="getIncludeQueryString" output="false" returntype="boolean" hint="gets this option for method getCurrentUrl">
	<cfreturn variables.includeQueryString>
</cffunction>

<cffunction access="public" name="getCurrentURL" output="false" returntype="any">
	<cfargument name="returnType" type="string" required="false" default="string" hint="string, struct">
	<cfargument name="includeQueryString" type="boolean" required="false" default="#variables.includeQueryString#"> 

	<cfset var my_url = "">

	<cfif isStruct(variables.urlStruct)>
		<cfset my_url = variables.urlStruct>
	<cfelse>
		<cfset my_url = structNew()>
		<cfset my_url.scheme = "">
		<cfset my_url.domain = "">
		<cfset my_url.port = "">
		<cfset my_url.path = "">
		<cfset my_url.query = "">
		<cfset my_url.string = "">
		
		<!--- Scheme --->
		<cfif cgi.server_port_secure>
			<cfset my_url.scheme = "https://">
		<cfelse>
			<cfset my_url.scheme = "http://">
		</cfif>
		
		<!--- Host --->
		<cfset my_url.domain = cgi.SERVER_NAME>
		<cfset my_url.port = cgi.SERVER_PORT>
		
		<!--- Path --->
		<!--- The request.uri var is set in handler.cfm by the url rewriter --->
		<cfif isDefined('request.uri') AND request.uri NEQ ''>
			<cfset my_url.path = request.uri>	
		<cfelse>
			<cfset my_url.path = cgi.script_name>
		</cfif>	
		
		<!--- make sure the path always has a prefix "/" --->
		<cfif my_url.path EQ "" OR mid(my_url.path, 1, 1) NEQ '/'>
			<cfset my_url.path = "/" & my_url.path>
		</cfif>  

		<!--- Query String --->	
		<cfif isDefined('request.uri') AND request.uri NEQ '' AND find('&', cgi.query_string) NEQ 0>
			<!--- filter out the first part of the query string for the rewriter --->
			<cfset my_url.query = mid(cgi.query_string, find('&', cgi.query_string) + 1, len(cgi.query_string) - find('&', cgi.query_string))>
		<cfelseif isDefined('request.uri') AND request.uri NEQ ''>
			<cfset my_url.query = "">
		<cfelse>
			<cfset my_url.query = cgi.query_string>
		</cfif>

		<cfset variables.urlStruct = my_url>
	</cfif>

	<cfset my_url.string = genURLString(urlStruct: my_url)>
	
	<!--- string the query string --->
	<cfif arguments.includeQueryString EQ false>
		<cfset my_url.string = GetToken(my_url.string, 1, '?')>
	</cfif>

	<cfif returnType EQ "struct">	
		<cfreturn my_url>
	</cfif>

	<cfreturn my_url.string>

</cffunction>

<cffunction name="changeURLStoSEO" access="public" returntype="string" output="false" hint="Changes page id urls to SEO friendly urls.">
	<cfargument name="pagehtml" type="string" required="true" hint="html content">  
	<cfargument name="datasource" type="string" required="false" hint="CMS Datasource" default="#variables.datasource#">
    <cfargument name="useRedirectTable" type="boolean" required="false" default="#variables.useRedirectTable#">
	
	<!--- find all page ids --->
    <cfset var found = 1>
    <cfset var stripPast = 0>
    <cfset var mychar = "">
    <cfset var myid = "">
    <cfset var myurl = "">
    <cfset var myhtml = arguments.pagehtml>

    <cfloop condition="found GT 0">
        <cfset stripPast = found + 1>
        <cfset found = findnocase('href="page.cfm?page_id=', myHTML, stripPast)> 
        
        <cfif found NEQ 0>
            <cfset found = found + 6>
            <cfset mychar = found + 17>
            
            <!--- get ID --->
            <cfloop condition="isNumeric(mid(myHTML, mychar, 1)) EQ true">
				<cfset mychar = mychar + 1>
            </cfloop>
            
            <cfset myid = mid(myHTML, found + 17, mychar - (found + 17))>
			
            <cfset myurl = pageIDToURL(page_id: myid, datasource: arguments.datasource, useRedirectTable: arguments.useRedirectTable, URLrewriter: true)>
            
            <cfif myurl NEQ false AND NOT isNumeric(myurl)>
            	<!--- change page --->
				<cfset myHTML = replace(myHTML, mid(myHTML, found, mychar - found), "#myurl#")>
            <cfelse>
            	<!--- do nothing, the page cannot be resolved --->
            </cfif>
        <cfelse>
        </cfif>
    </cfloop>
    
    <cfreturn myHTML>
</cffunction> 

<cffunction name="pageUrlToId" access="public" returntype="struct" output="false" hint="converts a virtual page url to a page id.">
	<cfargument name="page_url" type="string" required="true" hint="the virtual url path for a page">
    <cfargument name="root_id" type="numeric" required="true" hint="root page id of the site, the id doesn't even have to actually exist">
	<cfargument name="datasource" type="string" required="false" hint="CMS Datasource" default="#variables.datasource#">
	<cfargument name="useRedirectTable" type="boolean" required="false" default="#variables.useRedirectTable#">
	
    <cfset var bread = "">
	<cfset var notFound = "">
    <cfset var id = "">
	<cfset var i = "">
    <cfset var oldId = "">
    <cfset var qChildren = "">
    <cfset var qRedirects = "">
	
	<cfset var retVal = structNew()>
	
	<cfset retVal.id = ''>
	<cfset retVal.redirect = false>
	<cfset retVal.redirectUrl = ''>
	<cfset retVal.redirectId = ''>

	<!--- Use redirect table for fast lookups --->
    <cfif useRedirectTable eq true>
		<cfquery datasource="#arguments.datasource#" name="qRedirects">
			select id, redirect, redirectId from mrl_redirect
			where md5 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.page_url, 'md5')#">
		</cfquery>

		<!--- Bail out if no record exists, return '' --->
		<cfif qredirects.RecordCount EQ 0>
			<cfreturn retVal>
		</cfif>
	
		<!--- Check if this is a non-redirect page --->
		<cfif qRedirects.redirect EQ ''>
			<cfset retVal.id = qRedirects.id>
			<cfset retVal.redirect = false>
		<!--- if the page is a redirect, check that the page is public first --->
		<cfelseif isPublicId(page_id: qRedirects.redirectId, datasource: arguments.datasource)>
			<!--- a redirect exists for the requested url --->
			<cfset retVal.id = qRedirects.id>
			<cfset retVal.redirect = true>
			<cfset retVal.redirectUrl = getBasePath() & qRedirects.redirect>
			<cfset retVal.redirectId = qRedirects.redirectId>	
		</cfif>
		
		<cfreturn retVal>		
	</cfif>

	<cfset notFound = false>
    
 	<cftry>
  		<cfset bread = listToArray(arguments.page_url, '/', false)>
        <cfcatch>
        	<!--- could not parse the url! --->
            <cfset notFound = true>
        </cfcatch>
    </cftry>
    
	<!--- get the root id from the arguments --->
    <cfset id = arguments.root_id>
    
    <cfif notFound NEQ true>	
	    <!--- Loop through the bread crumbs to resolve the page id --->
	    <cfloop array="#bread#" index="i"> 

	        <cfstoredproc datasource="#arguments.datasource#" procedure="mrl_getChildren">
	            <cfprocparam dbvarname="@id" cfsqltype="cf_sql_integer" value="#id#">
	            <cfprocparam dbvarname="@summary" cfsqltype="cf_sql_bit" value="0">
	            <cfprocresult name="qChildren">
	        </cfstoredproc>



	        <cfset oldId = id>
	        <cfloop query="qChildren">
	            <cfif qChildren.url EQ i>
	                <!---<cfoutput>ID: #qChildren.id#<br /></cfoutput> --->
	                <cfset id = qChildren.id>
	                <cfbreak> 
	            </cfif>
	        </cfloop>
	        
	        <cfif oldId EQ id>
	            <cfset notFound = true>
	            <cfbreak>
	        </cfif>
	    
	    </cfloop>
    </cfif>
    
    <cfif notFound EQ true>
    	<cfset retVal.id = "">
    <cfelse>
    	<cfset retVal.id = id>
    </cfif>

    <cfreturn retVal>

<!---
    <cfdump var="#retval#">
	<cfdump var="#arguments#">
	<cfdump var="#notfound#">
	<cfdump var="#bread#">
	<cfabort>
--->

    
</cffunction>

<cffunction name="isPublicId" access="public" returntype="boolean" output="false">
	<cfargument name="page_id" type="numeric" required="true" hint="page_id">
	<cfargument name="datasource" type="string" required="false" hint="CMS Datasource" default="#variables.datasource#">
	
	<cfset var qPage = "">
	
	<cfquery datasource="#arguments.datasource#" name="qPage">
		select count(*) as [count]
		from mrl_sitePublic
		where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
	</cfquery>
	
	<cfif qPage.count EQ 1>
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif> 
</cffunction>

<cffunction name="pageIdToUrl" access="public" returntype="any" output="false">
	<cfargument name="page_id" type="numeric" required="true" hint="page_id">
	<cfargument name="datasource" type="string" required="false" hint="CMS Datasource" default="#variables.datasource#">
	<cfargument name="useRedirectTable" type="boolean" required="false" default="#variables.useRedirectTable#">
	<cfargument name="URLrewriter" type="boolean" required="false" default="#variables.URLrewriter#">
	<cfargument name="site_config" type="struct" required="false">
	
    <cfset var qBread = "">
    <cfset var qRedirect = "">
    <cfset var myurl = "">
    <cfset var i = 0>
    <cfset var retval = "">

    <cfif isDefined("arguments.site_config")>
    	<cfset variables.site_config = arguments.site_config>
    </cfif>

	<cfif arguments.URLrewriter EQ false>
		<cfreturn 'page.cfm?page_ID=#page_id#'>
	</cfif>
	
	<cfset local.cachekey = "pageIdToUrl#SerializeJSON(arguments)#">
	<cfset local.mycache = cacheGet(local.cachekey)>

	<!---
	<cfif arguments.useRedirectTable EQ true>
		<cfquery datasource="#arguments.datasource#" name="qRedirect" cachedwithin="#createTimeSpan(0,0,1,0)#">
			select top 1 url, redirect
			from mrl_redirect
			where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
			order by usedDate desc
		</cfquery>
		
		<cfif qRedirect.redirect EQ "">
			<cfreturn qRedirect.url>
		<cfelse>
		</cfif>	
	</cfif>	
	--->

	<cfif NOT isNull(mycache) AND 5 EQ 6>
		<cfset local.retval = mycache>
	<cfelse>
		<cfset qbread = getBreadcrumbs(page_id: arguments.page_id, datasource: arguments.datasource)>
		
		<cfif qbread.query.recordCount GT 0 AND qbread.orphaned NEQ true AND qbread.query.visible EQ 'T'>
	        <cfset i = 0>
	        <cfloop query="qbread.query">
	            <cfif i NEQ 0>
	                <cfset myurl = myurl & '/'>
	            </cfif>
	            <cfset myurl = myurl & qbread.query.url> 
	            <cfset i = i + 1>
	        </cfloop>
	        <cfset myurl = myurl & '/'>
	        
	        <cfset local.retval = myurl>        
	    <cfelseif qbread.orphaned EQ true AND qbread.query.visible EQ 'T'>
	    	<cfset local.retval = arguments.page_id>
	    </cfif>

	    <cfset CachePut(local.cachekey, local.retval, createTimeSpan(0,0,1,0))>
    </cfif>

    <cfreturn local.retval>
</cffunction>

<cffunction name="getBasePath" access="public" returntype="string" output="false">
	<cfargument name="relative" type="boolean" default="true" required="false" hint="relative true: / relative false: http://www.asdf.com/">
	<cfset var LOCAL = structNew()>	
	
   	<cfset LOCAL.found = 1>
	
   	<cfloop condition="LOCAL.found GT 0">
       <cfset LOCAL.stripPast = LOCAL.found + 1>
       <cfset LOCAL.found = find('/', cgi.SCRIPT_NAME, LOCAL.stripPast)> 
   	</cfloop>
	    
   	<cfset LOCAL.path = mid(cgi.SCRIPT_NAME, 1, stripPast - 1)>
	
	<cfif arguments.relative EQ false>		
		<cfset LOCAL.currentURL = getCurrentURL(returnType: 'struct')>
		<cfset LOCAL.currentURL.path = LOCAL.path>
		<cfset LOCAL.currentURL.query = "">
		<cfset LOCAL.path = genURLstring(LOCAL.currentURL)>
	</cfif>
	
	<cfreturn LOCAL.path>
</cffunction>

<cffunction name="getSiteRoot" access="public" output="false" returntype="string">
	<cfargument name="site_config" type="struct" required="false" default="#variables.site_config#"> 
	<cfreturn arguments.site_config.CMS.web.siteroot>
</cffunction>

<cffunction name="getAllSitePages" output="false" returnType="query">
	<cfargument name="limit" required="false" type="numeric" default="0">
	<cfargument name="datasource" type="string" required="false" hint="CMS Datasource" default="#variables.datasource#">

	<cfset var qPages = "">
	
	<cfquery datasource="#arguments.datasource#" name="qPages">
		select 
		<cfif limit NEQ 0>
			top #int(arguments.limit)#
		</cfif> 
		id, title from mrl_sitePublic
		order by sortIndex
	</cfquery>
	
	<cfreturn qPages>
</cffunction>

<cffunction name="getBreadcrumbs" access="public" returntype="struct" hint="getBreadBrumbs">
	<cfargument name="page_id" type="numeric" required="true" hint="page_id">
	<cfargument name="datasource" type="string" required="false" hint="CMS Datasource" default="#variables.datasource#">
	<cfargument name="site_config" type="struct" required="false" default="#variables.site_config#">
	<Cfargument name="useCache" type="boolean" required="false" default="true">

	<cfif NOT isStruct(arguments.site_config)>
		<cfthrow message="site_config is not of type struct">
	</cfif>

	<!--- exclude the root id if it editable --->
	<cfif arguments.site_config.CMS.tree.crumbindex EQ 1>
		<cfset arguments.root_id = arguments.site_config.CMS.tree.rootid>
	<cfelse>
		<cfset arguments.root_id = -1>
	</cfif>

    <cfset LOCAL.retVal = structNew()>

    <cfif useCache EQ true AND site_config.useCache EQ true>
	    <cfset LOCAL.timeSpan = createTimeSpan(0,0,1,0)>
	<cfelse>
	    <cfset LOCAL.timeSpan = createTimeSpan(0,0,0,0)>	    
    </cfif>

	<!--- get breadcrumbs from mrl_siteAdmin --->
    <cfquery datasource="#arguments.datasource#" name="LOCAL.qBreadAdmin" cachedwithin="#local.timeSpan#">
	WITH PagesList (id, idparent, menu, url, level, visible, deleted)
		AS
		(
			-- Anchor member definition
			SELECT id, idparent, menu, url,(0) as level, visible, deleted FROM mrl_siteAdmin 
            WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
			UNION ALL

			-- Recursive member definition
			SELECT c.id, c.idparent, c.menu, c.url, p.level + 1, c.visible, c.deleted From mrl_siteAdmin as c
			INNER JOIN PagesList as p
			ON c.id = p.idparent
			<cfif arguments.root_id NEQ -1>
			where c.id != <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.root_id#">				
			</cfif>
		)
		-- Statement that executes the CTE
	SELECT id, idParent, menu, url, level, visible, deleted FROM PagesList ORDER BY level DESC
    </cfquery>
    
    <!--- Sift out deleted or hidden pages from the admin view
    we need to compare this against the original query to see 
    if the page is orphaned --->
	<cfquery dbtype="query" name="LOCAL.qBreadPublic">
    	select * from [LOCAL].qBreadAdmin 
        where visible = 'T' and deleted = 'F'
    </cfquery>    
    
    <cfif LOCAL.qBreadPublic.recordCount NEQ LOCAL.qBreadAdmin.recordcount>
    	<cfset LOCAL.retVal.orphaned = true>
		<!--- filter the query to only include the requested page --->
		<cfquery dbtype="query" name="LOCAL.qBreadPublic">
	    	select * from [LOCAL].qBreadAdmin 
			where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
	    </cfquery>    
    <cfelse>
    	<cfset LOCAL.retVal.orphaned = false>
    </cfif>

    <cfset LOCAL.retVal.query = LOCAL.qBreadPublic>

    <cfreturn LOCAL.retVal>	
</cffunction>

<!--- import page --->
<cffunction name="pageImport" returntype="numeric">
	<cfargument name="parent_id" type="numeric" required="false" default="#application.tree.rootid#">
	<cfargument name="title" type="string" required="true">
	<cfargument name="info"	type="string" required="true">
	<cfargument name="page_id" type="numeric" required="false">
	<cfargument name="comment" type="string" required="false" default="">

	<cfset var page_struct_create = "">
	<cfset var page_struct_save = "">

	<cftransaction>
		<cfinvoke component="assets.ajax.process" method="createPage" returnvariable="page_struct_create">
			<cfinvokeargument name="idparent" value="#arguments.parent_id#">
		  	<cfif isDefined("arguments.page_id")>
			  	<cfinvokeargument name="id" value="#arguments.page_id#">    		
		  	</cfif>
		</cfinvoke>	

		<cfinvoke component="assets.ajax.process" method="savePage" returnvariable="page_struct_save">
			<cfinvokeargument name="id" value="#page_struct_create.data.id#">
			<cfinvokeargument name="title" value="#trim(arguments.title)#">
			<cfinvokeargument name="info" value="#trim(arguments.info)#">
		</cfinvoke>	

		<cfinvoke component="assets.ajax.process" method="setPageState">
			<cfinvokeargument name="idHistory" value="#page_struct_save.idHistory#">
			<cfinvokeargument name="state" value="approved">
			<cfinvokeargument name="comment" value="#arguments.comment#">
			<cfinvokeargument name="send_email" value="false">
		</cfinvoke>
	</cftransaction>
 
	<cfreturn page_struct_create.data.id>
</cffunction>

<cffunction name="getPageTemplate" access="public" returntype="query" hint="get template details for a page">
	<cfargument name="page_id" type="numeric" required="true" hint="page_id">

 	<cfquery datasource="#application.datasource#" name="LOCAL.qtemplate">
        select [template], tinyMCEStyleSheet from mrl_page
        join mrl_template on mrl_template.cfcname = mrl_page.template
        where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
    </cfquery>

    <cfreturn LOCAL.qtemplate>
</cffunction>

<!---  add to pageHelper and incorporate into webtofilepath --->
<!--- Get the path from a url http://www.example.com/asdf 
 		to asdf/
--->
<cffunction name="getPath" access="public">
    <cfargument name="url" required="true" type="string">
    <cfset local.pos1 = mid(arguments.url, 1, find("//", arguments.url))>
    <cfset local.pos1 = len(local.pos1) + 2>
    <cfset local.pos2 = find("/", arguments.url, local.pos1)>
    <cfset local.groupPath = mid(arguments.url, local.pos2 + 1, len(arguments.url) - local.pos2)>
    <cfreturn local.groupPath>
</cffunction>

<!--- add to pageHelper and incorporate into changeURLStoSEO --->
<cffunction name="getPageIdFromURL" access="public" returntype="numeric" output="false">
	<cfargument name="url" type="string" required="true">

	<cfset var found = 1>
	<cfset var mychar = "">
	<cfset var myid = -1>
	<cfset var myHTML = "">
	
	<cfset found = findnocase('page.cfm?page_id=', arguments.url)>     

    <cfif found NEQ 0>
        <cfset mychar = found + 17>

        <!--- get ID --->
        <cfloop condition="isNumeric(mid(arguments.url, mychar, 1)) EQ true">
			<cfset mychar = mychar + 1>
        </cfloop>
            
        <cfset myid = mid(arguments.url, found + 17, mychar - (found + 17))>	
    <cfelse>
    	<cfreturn -1>
    </cfif>

    <cfreturn myid> 
</cffunction>

</cfcomponent>