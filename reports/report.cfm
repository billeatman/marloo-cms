<!--- messy script to get the user access report ---><head>
<title>User Access</title>
<style>
body {
	font-family: Arial, Helvetica, sans-serif;
	background: white;
	font-size:10px;
	margin-left: 25px;
	margin-top: 25px;
}

h2 {
	color: #324F81;
	font-size: 16px;
}

.user-table {
	border: thin;
	border-style: solid;
	border-color:#666;
	padding: 0px;
	margin: 0px;
	border-spacing: 0px;
	border-left: none;
	border-top: none;
	border-right: none;
	border-bottom: none;
	table-layout: fixed;
	width: 100%;
}

.user-table tr{
/*	border:thin;
	border-style:solid;
	border-color:red;
	padding: 0px;
	margin: 0px;
	border-spacing: 0px;*/
}

.user-table tr td{
/*	border:thin;
	border-style:solid;
	border-color:#666;
	border-bottom: none;
	border-right: none;*/
}

.thead-groups{
	font-weight:normal;
	border: none;
	border-style: none;
	border-color:#666;
	border-bottom: none;
	border-right: none;
	background-color: #FFF;
	width: 30px;
	overflow: visible;
	text-align: left;
	white-space:nowrap;
	height: 32px;
	background-image: url(../assets/images/horizontal-table.png);
	background-repeat:no-repeat;
	/*padding-left: 8px;*/
}

.thead-groups-last{
	background-image: url(../assets/images/horizontal-table.png);
	background-repeat:no-repeat;
}

.groups-text{
	-webkit-transform: rotate(-60deg); 
	-moz-transform: rotate(-60deg);
	transform: rotate(-60deg);
	margin-left: 16px;
	color:#333;
/*	filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);*/
}

.td-border {
	border:thin;
	border-style:solid;
	border-color:#666;
	border-bottom: none;
	border-right: none;
}

.access-spacer {
	border:thin;
	border-style:solid;
	border-color:#666;
	border-top: none;
	border-bottom: none;
	border-right: none;
}

.access-last-row {
	border:thin;
	border-style:solid;
	border-color:#666;
	border-right: none;
}

.access-user {
	background-color: #DAE6F7;
	width: 300px;
}

.access-selected {
	background-color:#324F81;
	color: #CCC;
	width: 30px;
	overflow:hidden;
	text-align: center;
}

.access-notselected {
	background-color:#white;
	color: #666;
	width: 30px;
	overflow:hidden;
}

.access-error {
	background-color: red;
}

.thead-first {
	background:#FFF;
	width: 300px;
}
.header-div {
	position: relative;
	top: 100px;
}

</style>
</head>

<SCRIPT LANGUAGE="JavaScript"> 
// This script was supplied free by Hypergurl 
// http://www.hypergurl.com 
<!-- hide script and begin 
if (window.print) { 
	document.write('<form><input type=button name=print value="Print Report"' + 'onClick="javascript:window.print()"></form>'); 
} 
// End hide --> 
</script>

<CFIF NOT isDefined("SESSION.Auth.groups.toplevel")>
  <cflocation url="search.cfm" >
</CFIF>

<!--- <cfquery datasource="#application.datasource#" name="queryGroupsAll">
Select securityGroup, Lower(groupDesc) as groupDesc, Lower(email) as email, groupName from 
(SELECT distinct securityGroup, groups.groupDesc as groupDesc, groups.OwnerMail as email, groups.groupName 
from mrl_sitePublic as sp
join mrl_pageGroup as groups on groupname = sp.securityGroup) as mygroups
order by email ASC
</cfquery>
--->

<cfquery datasource="#application.datasource#" name="queryGroupsAll">
Select groupname as securityGroup, Lower(groupDesc) as groupDesc, Lower(ownermail) as email, groupName from mrl_pageGroup where type = 'pagegroup'
order by email ASC
</cfquery>


<cfquery dbtype="query" name="queryOwners">
SELECT distinct email from queryGroupsAll
order by email ASC
</cfquery>


<cfloop query="queryOwners">
	
    <div class="header-div">
    <H2>Owner:<cfoutput>&nbsp;#queryOwners.email#</cfoutput></H2>
    </div>
    <div style="height: 80px;"></div>
    <table class="user-table">
    <!--- Get the owners groups --->
    <cfquery dbtype="query" name="queryGroups">
    select securityGroup, groupDesc, groupName
    from queryGroupsAll
    where email = '#queryOwners.email#'
    </cfquery>
    <thead>
    <th class="thead-first"></th>
    <cfloop query="queryGroups">
        <th class="thead-groups">
        <cfoutput><div class="groups-text">#queryGroups.groupDesc#</div></cfoutput>
        </th>
    </cfloop>
        <th class="thead-groups-last">&nbsp;
        
        </th>    
    </thead>
	<cfquery datasource="#application.datasource#" name="groupUsers">    
		select distinct lower([login]) as email from mrl_pageGroupMember where groupName in (select distinct groupName from mrl_pageGroup where ownerMail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#queryOwners.email#">) 
        and [login] is not null
        and groupName in (select groupName from mrl_pageGroup where groupname in (select distinct securityGroup from mrl_page))
    </cfquery>
    
    <cfset rowLength = groupUsers.getRowCount()>
    <cfset i = 1>
    <cfloop query="groupUsers">
    <tr>
    	<td class="access-user td-border <cfif i eq rowLength>access-last-row</cfif>"><cfoutput>&nbsp;#groupUsers.email#</cfoutput></td>
        <cfloop query="queryGroups">
            <cfquery datasource="#application.datasource#" name="access">
            select count(*) as mycount from mrl_pageGroupMember where
			groupName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#queryGroups.groupName#"> and [login] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#groupUsers.email#">
            </cfquery>
            <td class="<cfif i eq rowLength>access-last-row</cfif> td-border <cfif access.mycount eq 1>access-selected<cfelseif access.mycount gt 1>access-error<cfelse>access-notselected</cfif>"> 
            <cfif access.mycount eq 1>
            yes
            <cfelse>
            	<cfif access.mycount gt 1>
            	??? Yes
                <cfelse>
                &nbsp;
                </cfif>
  
            </cfif>
            </td>
        </cfloop>
        <td class="access-spacer">&nbsp;</td>
    </tr>
    <cfset i = i + 1>
    </cfloop>
    </table>
    
</cfloop>
