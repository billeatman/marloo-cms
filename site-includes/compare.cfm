<cfsetting requesttimeout="1000">

<!--- mini config --->
<cfset admin = true>					 <!--- true for CMS, false for release --->
<cfset corecfc = "default"> 			 <!--- core data cfc for the site --->
<cfset datasource = "marloo-ds">	 <!--- datasource for the site --->
<cfset cfMappedPath = "marloo-includes"> 	 <!--- mapped path --->

<!--- 'dev' or 'release' The CMS takes care of this --->
<cfset sitepath = "release"> 			 
<cfif isdefined("session.devSite")>
	<cfif admin eq true and session.devSite eq true> 
        <cfset sitepath = "dev">
    </cfif>
</cfif>

<cfquery name="qPages" datasource="#application.datasource#">
	select top 100 id from mrl_sitePublic where app is null or app = '' order by newid()
</cfquery>

<cffunction name="renderPage" access="private" output="false" returntype="numeric">
	<cfargument name="page_id">
    <cfargument name="sitepath">
    <cfargument name="history_id" required="false" default="">
	<cfset var mytime = getTickCount()>
    
    
    <!--- Core Page Functions --->
    <cfset page = createObject("component", "#cfMappedPath#.#arguments.sitepath#.core.#corecfc#").init(page_id: page_id, history_id: history_id, admin: admin, datasource: "#datasource#")>
    
    <!--- if we don't init page throw error --->
    <cfif NOT isObject(page)>
        <cfinclude template="errorpage.cfm">
        <cfabort>
    </cfif>
    
    <!--- renders the page with the proper template --->
    <cfset pageTemplate = createObject("component", "#cfMappedPath#.#arguments.sitepath#.#page.getTemplate()#").init(page: page)>
    
    
    <!--- Create the finished page --->
    
    <cfset pageTemplate.renderPage()>
    <cfreturn getTickCount() - mytime>
</cffunction>

<h2>Time</h2>

    <cfset timeRelease = 0>
    <cfset timeDev = 0>
    
    <cfset i = 0>
    <cfloop query="qPages">
    	<cfset i = i + 1>
    	<cfif i MOD 2 eq 0>
        	<cfset timeDev = timeDev + renderPage(page_id: qPages.id, sitepath: "dev")>
        	<cfset timeRelease = timeRelease + renderPage(page_id: qPages.id, sitepath: "release")>
    	<cfelse>
        	<cfset timeRelease = timeRelease + renderPage(page_id: qPages.id, sitepath: "release")>
        	<cfset timeDev = timeDev + renderPage(page_id: qPages.id, sitepath: "dev")>
		</cfif>        
    </cfloop>
    
<cfoutput>Time Dev: #timeDev# avg: #timeDev / qPages.getRowCount()#<br /></cfoutput>
<cfoutput>Time Release: #timeRelease# avg: #timeRelease / qPages.getRowCount()#<br /></cfoutput>

