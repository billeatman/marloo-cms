<!--- Pages by Owner Report --->
<!--- Author: William Eatman --->

<CFIF NOT isDefined("SESSION.Auth.groups.toplevel")>
  <cflocation url="search.cfm" >
</CFIF>

<cfparam name="reportDate" default="#now()#">

<cfscript>
function jsDateFormat(date){
   if( isDate(date))   return 'new Date(#year(date)#, #(month(date)-1)#, #day(date)#, #hour(date)#, #minute(date)#, #second(date)#)';
   else return "null";
}
</cfscript>


<cfif NOT isDate('#reportDate#')>
	<cfset reportDate = "#now() + 1#">
<cfelse>
	<cfset reportDate = parseDateTime('#reportDate#')>
</cfif>

<cfinclude template="../assets/includes/ext2.cfm">



<script language="javascript">
Ext.form.DateField.prototype.menuListeners.hide = function(m,d){
//do whatever here, like this.onBlur();
	//alert('selected');
//	this.setValue(d);
	this.fireEvent('dateselected');
};

Ext.onReady(function(){
//	alert('ext ready');		
	var mydate = <cfoutput>#jsDateFormat(reportDate)#</cfoutput>;
	var mydatefield = new Ext.form.DateField({
		applyTo: 'iddate',
		value: mydate
	});
	mydatefield.on('dateselected', function(){
	//	alert(this.getValue());
	//	mydate.setDate(this.getValue() + 1);
		Ext.MessageBox.show({
           msg: 'Please Wait...',
           progressText: 'Generating Report...',
           width:300,
           wait:true,
           waitConfig: {interval:200},
       });

		document.location = 'report2.cfm?reportDate=' + this.getValue();	
	});
});
</script>

<cfset reportDate = DateAdd("d", 1, reportDate)>


<cfquery datasource="#application.datasource#" name="queryGroupsAll">
Select securityGroup, groupid, groupDesc as groupDesc, Lower(email) as email from 
(SELECT distinct securityGroup, groups.groupDesc as groupDesc, groups.OwnerMail as email, groups.groupid as groupID 
from mrl_sitePublic as sp
join edirectory.dbo.mrl_pageGroup as groups on groupname = sp.securityGroup) as mygroups
order by email ASC
</cfquery>

<cfquery dbtype="query" name="queryOwners">
SELECT distinct email from queryGroupsAll
order by email ASC
</cfquery>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><cfoutput>#application.pagedesc# by Owner</cfoutput>s</title>
<style>
.x-date-middle {

    padding-top:2px;padding-bottom:2px;

    width:130px; /* FF3 */

} 
.main{
	font-family:"Courier New", Courier, monospace;
	font-size:12px;
	padding: 10px;
}
.reportTable {
	font-family:"Courier New", Courier, monospace;
	font-size:12px;
	padding: 0px;
}
.reportTable tr td{
	font-family:"Courier New", Courier, monospace;
	font-size:12px;
	padding: 2px;
	
}
</style>
</head>
<body class="main">

<table border="0px" class="reportTable">
<tr>
<td valign="bottom" colspan="2">
<SCRIPT LANGUAGE="JavaScript"> 
// This script was supplied free by Hypergurl 
// http://www.hypergurl.com 
<!-- hide script and begin 
if (window.print) { 
	document.write('<input type=button name=print value="Print"' + 'onClick="javascript:window.print()">&nbsp;(landscape recommended)&nbsp;'); 
} 
// End hide --> 
</script>
</td>
</tr>
<tr>
<td>
Pages older than or equal to: &nbsp;
</td>
<td>
<input type="text" id="iddate">
</td>
</tr>
</table>
    <table cellpadding="2px" class="reportTable">
    
    <cfloop query="queryOwners">
        <tr>
        <td colspan="6"><H2>Owner: <cfoutput>#queryOwners.email#</cfoutput></H2></td>
        </tr>
        <tr>
            <td align="center"><strong><cfoutput>#application.pagedesc#</cfoutput> ID</strong></td>
            <td align="center"><strong>Title</strong></td>
            <td align="center"><strong>Submitted Date</strong></td>
            <td align="center"><strong>Submitted By</strong></td>
            <td align="center"><strong>Created Date</strong></td>
            <td align="center"><strong>Created By</strong></td>
        </tr>
        <!--- Get the owners groups --->
        <cfquery dbtype="query" name="queryGroups">
        select securityGroup, groupDesc, groupID
        from queryGroupsAll
        where email = '#queryOwners.email#'
        </cfquery>

        <cfloop query="queryGroups">
        
            <cfquery datasource="#application.datasource#" name="queryGroupPages">
                select * from mrl_sitePublic
                where securityGroup = <cfqueryparam cfsqltype="cf_sql_varchar" value="#queryGroups.securityGroup#"> 
                and modifiedDate < <cfqueryparam cfsqltype="cf_sql_date" value="#reportDate#">
                Order by modifiedDate ASC
            </cfquery>
            
            <cfif queryGroupPages.getRowCount() gt 0>
                <tr>
                <td colspan="6" bgcolor="#CCCCCC"><strong><cfoutput>#queryGroups.groupDesc#</cfoutput></strong></td>
                </tr>                
                <cfloop query="queryGroupPages"> 
					<cfoutput>
                        <tr>
                        <td>#queryGroupPages.id#</td>
                        <td>#queryGroupPages.title#</td>
                        <td>#dateformat(queryGroupPages.submittedDate)#</td>
                        <td>#queryGroupPages.submittedby#</td>
                        <td>#dateformat(queryGroupPages.createdDate)#</td>
                        <td>#queryGroupPages.createdby#</td>
                        </tr>
                    </cfoutput>
            	</cfloop>
             </cfif>   
        </cfloop>
         
    </cfloop>
    </table>
</body>
</html>