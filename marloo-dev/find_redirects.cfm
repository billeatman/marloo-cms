<cfsetting requesttimeout="999999">

<cfset path = "#GetDirectoryFromPath(GetCurrentTemplatePath())#">    
    
<cfset datasource = "marloo-ds">

<cfdirectory type="file" recurse="true" filter="index.cfm" name="qIndex" directory="#path#">

<cfloop query="qIndex">
	<cfset webPath = replaceNoCase(qIndex.directory, "c:\inetpub\marloo-cms\", "http://www.example.com/")>
	<cfset webPath = replace(webPath, "\", "/", "all")>

	<cfhttp url="#webPath#/index.cfm" method="head" redirect="false" result="redirect">

	<cfif find("301", redirect.statusCode) EQ 1>
		<cfhttp url="#redirect.responseHeader.location#" method="head" redirect="true" result="redirectLoc">
		<cfif find("200", redirectLoc.statuscode)>
			<cfoutput>#webPath# - #redirect.responseHeader.location# - #redirectLoc.statuscode#</cfoutput>			
		<cfelse>
			<span style="color: red;">
			<cfoutput>#webPath# - #redirect.responseHeader.location# - #redirectLoc.statuscode#</cfoutput>
			</span>			
		</cfif>

		<!--- parse url --->
		<cfset urlvars = GetToken(redirect.responseHeader.location, 2, "?")>
		<cfset newURL = GetToken(redirect.responseHeader.location, 1, "?")>
		<cfset firstVar = true>

		<cfset uVars = structNew()>
		<cfset uVars.utm_campaign = "">
		<cfset uVars.utm_medium = "">
		<cfset uVars.utm_source = "">
		<cfset uVars.utm_term = "">

		<cfloop list="#urlvars#" delimiters="&" index="i">
			<cfset structInsert(uVars, GetToken(i, 1, "="), GetToken(i, 2, "="), true)>
			<cfif find("utm_", GetToken(i, 1, "=")) EQ 0>
				<cfif firstVar EQ true>
					<cfset firstVar = false>
					<cfset newURL = newURL & '?'>
				<cfelse>
					<cfset newURL = newURL & '&'>
				</cfif>
				<cfset newURL = newURL & trim(i)>
			</cfif>
		</cfloop>

		<cfdump var="#uVars#">

		<cfhttp url="#newURL#" method="head" redirect="true" result="redirectLoc">
		<cfif find("200", redirectLoc.statuscode)>
			<cfoutput>#newURL#</cfoutput>			
		<cfelse>
			<span style="color: red;">
			<cfoutput><strong>#newURL#</strong></cfoutput>
			</span>			
		</cfif>

		<cfset redirect = trim(lcase(replace(webPath, "http://www.example.com/", "")))>

		<cfquery datasource="#datasource#" name="qRedirect">
	INSERT INTO [dbo].[mrl_redirect]
           ([url]
           ,[redirectToUrl]
           ,[MD5]
           ,[redirect]
           ,[redirectType]
           ,[usedDate]
           ,[createdDate]
           ,[createdBy]
           ,[modifiedDate]
           ,[modifiedBy]
           ,[deleted]
           ,[idHistory]
			)
     VALUES
           ('#redirect#'
           ,'#trim(newURL)#'
           ,'#hash(redirect, 'MD5')#'
           ,'#trim(lcase(replace(webPath, "http://www.example.com/", "")))#'
           ,'marketing'
           ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
           ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
           ,'user@example.com'
           ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
           ,'user@example.com'
           ,'F'
           , '0'
            )

           SELECT SCOPE_IDENTITY() as r_id
        </cfquery>

        <cfquery datasource="#datasource#">
	        
INSERT INTO [dbo].[mrl_redirectUTM]
           ([r_id]
           ,[utm_campaign]
           ,[utm_source]
           ,[utm_medium]
           ,[utm_term]
           )
     VALUES
           ( '#qRedirect.r_id#'
           , <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(uVars.utm_campaign)#" null="#len(trim(uVars.utm_campaign)) EQ 0#">
           , <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(uVars.utm_source)#" null="#len(trim(uVars.utm_source)) EQ 0#">
           , <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(uVars.utm_medium)#" null="#len(trim(uVars.utm_medium)) EQ 0#">
           , <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(uVars.utm_term)#" null="#len(trim(uVars.utm_term)) EQ 0#">
           )

        </cfquery>

		<br /><hr><br />
	</cfif> 

</cfloop>



