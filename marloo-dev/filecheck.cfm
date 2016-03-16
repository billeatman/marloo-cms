<cfsetting requesttimeout="99999999">

<cfset destructive = true>

<cfquery datasource="#application.datasource#" name="qSecGroups">
    select groupName from mrl_pageGroup where type = 'pagegroup'
</cfquery>

<!--- <cfdump var="#qSecGroups#"> --->

<cfset siteRoot = "http://www.example.com/">

<cfloop query="qSecGroups">

    <cfdirectory action="list" directory="#application.path.groups##qSecGroups.groupName#" recurse="yes" name="qGroupFiles">
    <h3><cfoutput>#qSecGroups.groupName#</cfoutput></h3>
 
    <table>
    <cfloop query="qGroupFiles">

        <!--- skip directories --->
        <cfif lcase(qGroupFiles.type) neq 'file'>
            <cfcontinue>
        </cfif> 

        <cfset oldName = qGroupFiles.name> 
        <cfset qGroupFiles.name = replaceNoCase(qGroupFiles.name, ' ', '%20', 'all')>

        <cfif qGroupFiles.size neq 0 and lcase(qGroupFiles.name) neq "thumbs.db">
            <cfset urlSubDirectory = replace(qGroupFiles.directory, application.path.groups, "")>
            <cfset urlSubDirectory = replace(urlSubDirectory, "\", "/", "all")>
            <cfif mid(urlSubDirectory, len(urlSubDirectory), 1) neq "/">
                <cfset urlSubDirectory = urlSubDirectory & "/">
            </cfif>
            
            <cfset urlPath = "#application.web.groups##urlSubDirectory##qGroupFiles.name#">

            <cfif ucase(left(urlPath, 2) eq '//')>
                <cfset urlPath = "http:" & urlPath>
            </cfif>

            <cfset linked = false>
            
            <!--- check active pages --->
            <cfquery datasource="#application.datasource#" name="qExists">
                select id from mrl_siteAdmin where deleted = 'F' and info like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#urlSubDirectory##qGroupFiles.name#%">
            </cfquery>
            
            <cfset linkHTML = "">
            <cfif qExists.getRowCount() gt 0>
                <cfloop query="qExists">
                    <cfset linkHTML = linkHTML & "<a target='_new' href='#siteRoot##application.pagename#?#application.idvar#=#qExists.id#'>#id#</a>&nbsp;">
                </cfloop>
                <cfset linked = true>
            </cfif>

            <!--- get a query of all pending / draft pages to check --->
            <cfquery datasource="#application.datasource#" name="qExists">
                select id from mrl_siteHistory 
                where info like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#urlSubDirectory##qGroupFiles.name#%"> and idHistory in (
                select max(idhistory) as idhistory from mrl_siteHistory where id in (select id from mrl_siteAdmin where state = 'pending' or state = 'draft' or state = 'denied' and deleted = 'F') group by id) 
            </cfquery>

            <cfif qExists.getRowCount() gt 0>
                <cfloop query="qExists">
                    <cfset linkHTML = linkHTML & "<a target='_new' href='#siteRoot##application.pagename#?#application.idvar#=#qExists.id#'>#id#</a>&nbsp;">
                </cfloop>
                <cfset linked = true>
            </cfif>
            
            <cfif linked eq false and destructive EQ true>
                <cfoutput><br />#urlSubDirectory##qGroupFiles.name#<br /></cfoutput>
               <cffile action="delete" file="#qGroupFiles.directory#\#oldName#">            
            </cfif>


            <cfhttp url="#urlPath#" method="head">

            <tr>
            <cfoutput><td>#qGroupFiles.directory#\#qGroupFiles.name#</td><td>#cfhttp.statusCode#</td><td>#linkHTML#</td><td><cfif linked eq false><span style="color: red;">DELETE</span></cfif></td></cfoutput>
            </tr>
        </cfif>
    </cfloop>
    </table>
    
    <!--- <cfdump var="#qGroupFiles#"> --->
    <!--- </cfif> --->

</cfloop>
