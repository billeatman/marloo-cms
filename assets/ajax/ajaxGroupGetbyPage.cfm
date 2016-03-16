<cfparam name="id" default="-1"> 
<cfprocessingdirective suppressWhiteSpace = "yes">

<cfif id eq -1 OR NOT isNumeric(id)>
	<cfabort>
</cfif>

<!--- Get Page Group --->
<CFQUERY DATASOURCE="#application.datasource#" NAME="queryPage">
SELECT securityGroup
FROM mrl_siteAdmin
WHERE id=#id#
</CFQUERY>

<cfif NOT queryPage.getRowCount() eq 1>
	<cfabort>
</cfif>

<cfset securityGroup = queryPage.securityGroup>

<cfoutput>#securityGroup#</cfoutput>
</cfprocessingdirective>
