<!--- last modified 10/27/09 - WE - Pagedesc not replaced in all fields --->

<!--- get a user's site specific security groups --->
<cfinvoke component="assets.ajax.search" method="getUserSiteGroups" returnvariable="qSecurityGroups"></cfinvoke>

<html>
<head>

<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<title>Search</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="assets/style/search.css" rel="stylesheet" type="text/css">
</head>
<body>
<img src="assets/images/background1.jpg" alt="background image" id="bg" /> <img src="assets/images/vista_common/png/256x256/search_256.png" id="searchimg" />
<div id="white"></div>
<div id="search">
  <FORM ACTION="results.cfm" METHOD="post" id="frm-search">
    <TABLE width="400" BORDER="0" align="center">
      <TR>
        <TD width="145" height="33"><strong> by <cfoutput>#application.pagedesc# #application.idname# or URL</cfoutput> <br>
          </strong></TD>
        <TD width="520"><div id="f1">
            <INPUT TYPE="text" Name="id" >
          </div></TD>
      </TR>
      <TR>
        <TD height="37"><div align="left"><strong>by <cfoutput>#application.pagedesc#</cfoutput> Group </strong></div></TD>
        <TD>
			<!--- <cfdump var="#querySecurityGroups#"> --->
			<cfif qSecurityGroups.getRowCount() eq 1>
            	<!--- disable the option box and create a hidden field with the real value --->
        		<input type="hidden" name="securityGroup" value="<cfoutput>#qSecurityGroups.securityGroup#</cfoutput>">
                <SELECT disabled=true>
			<cfelse>
          		<SELECT name="securityGroup">
			</cfif>
            <cfif qSecurityGroups.getRowCount() gt 1>
			<OPTION value="">Select Edit Area</OPTION>
			</cfif>
            <cfoutput query="qSecurityGroups">
              <OPTION value="#securityGroup#">#groupdesc#</OPTION>
            </cfoutput>
          </SELECT>
        </TD>
      </TR>
      <TR>
        <TD height="34"><strong> by <cfoutput>#application.pagedesc#</cfoutput> Title </strong></TD>
        <TD><INPUT TYPE="text" Name="title">
        </TD>
      </TR>
      <TR>
        <TD height="33"><strong> by <cfoutput>#application.pagedesc#</cfoutput> Information </strong></TD>
        <TD><INPUT TYPE="text" Name="info">
        </TD>
      </TR>
      <TR>
        <td></td>
        <TD COLSPAN="2" ALIGN="center"><div align="left">
			<INPUT TYPE="submit" VALUE="Search">
          </div></TD>
      </TR>
    </TABLE>
  </FORM>
</div>

<div id="recent">
	<h4>Recently Modified Pages</h4>
  <!--- recently modified --->
	<cfinvoke argumentcollection="#variables#" component="assets.ajax.search" method="getRecentPages" returnvariable="qPages">

	<cfinvoke component="assets.ajax.search" method="displayQuery">
		<cfinvokeargument name="qPages" value="#qPages#">
		<cfinvokeargument name="limitResults" value="5">        
	</cfinvoke>
</div>

</body>
</html>
