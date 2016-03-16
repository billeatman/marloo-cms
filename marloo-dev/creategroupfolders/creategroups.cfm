<cfquery datasource="#application.datasource#" name="qGroups">
	select groupname from mrl_pageGroup
</cfquery>


<cfloop query="qGroups">
	<cfset mydirectory = application.path.editorroot & "dev\creategroups\" & qGroups.groupname>
    <cfset mydirectory = lcase(mydirectory)>
    <cfoutput>#mydirectory#</cfoutput><br />
	<cfdirectory action="create" directory="#mydirectory#">
</cfloop>