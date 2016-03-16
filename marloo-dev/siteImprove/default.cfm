<cfsilent>

<cfset site_config = application.site_config>

<cfset baseCFCPath = "#site_config.cfMappedPath#.#site_config.sitepath#">

<cfquery name="qPages" datasource="#application.datasource#">
	select id from mrl_sitePublic where 
	[owner] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.owner#">
</cfquery>

<cfhttp url="%siteimprove_report" method="get" result="site">

<cfset local.utilityCore = createObject('component', '#baseCFCPath#.core.utilityCore')>
<cfset local.jsoup = local.utilityCore.getJsoup()>
<cfset local.dom = local.jsoup.parse(site.filecontent)>

<cfset local.pageErrorCount = 0>

<cfloop array="#local.dom.select('div.page-title > a > span:last-of-type')#" index="i">
	<cfset myhtml = replaceNoCase(i.html(), '&shy;', '', 'all')>
	<cfset page_id = getPageIdFromURLString(myhtml)>
	<cfif page_id NEQ -1>
		
	<cfelse>
		<cfinvoke component="#baseCFCPath#.core.pageHelper" method="pageUrlToId" returnvariable="page">
			<cfinvokeargument name="page_url" value="#getPath(myhtml)#">
		    <cfinvokeargument name="root_id" value="#site_config.rootId#">
			<cfinvokeargument name="datasource" value="#site_config.datasource#"> 
			<cfinvokeargument name="useRedirectTable" value="#site_config.useRedirectTable#">       
		</cfinvoke>
		<cfif page.id NEQ "">
			<cfset page_id = page.id>
		<cfelse>
			<cfset page_id = -1>
		</cfif>
	</cfif>
	
	<cfoutput>#myhtml#</cfoutput> - <cfoutput>#page_id#</cfoutput>

	<cfquery dbtype="query" name="qPages2">
		select id from qPages 
		where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#page_id#">
	</cfquery>

	<cfif qPages2.recordCount EQ 1>
		<cfset local.pageErrorCount = local.pageErrorCount + 1>
		HIT!	<br />
	<cfelse>
		<br />
		<cfset i.parent().parent().parent().parent().parent().parent().remove()>
	</cfif>

</cfloop>

<!---  add to pageHelper and incorporate into webtofilepath --->
<cffunction name="getPath" access="private">
    <cfargument name="myurl" required="true" type="string">
    <cfset local.pos1 = mid(arguments.myurl, 1, find("//", arguments.myurl))>
    <cfset local.pos1 = len(local.pos1) + 2>
    <cfset local.pos2 = find("/", arguments.myurl, local.pos1)>
    <cfset local.groupPath = mid(arguments.myurl, local.pos2 + 1, len(arguments.myurl) - local.pos2)>
    <cfreturn local.groupPath>
</cffunction>

<!--- add to pageHelper and incorporate into changeURLStoSEO --->
<cffunction name="getPageIdFromURLString" access="private" returntype="numeric" output="false">
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

</cfsilent>
	
<cfif local.pageErrorCount LTE 0>
	<h1>NO ERRORS</h1>
	<cfabort>
</cfif>

<cfmail from="webamaster@example.com" to="user@example.com" type="html" subject="Page Error Report">
<html>
<head>
<cfoutput>#local.dom.head().html()#</cfoutput>
</head>
<cfoutput>#local.dom.body().html()#</cfoutput>
</html>
</cfmail>

