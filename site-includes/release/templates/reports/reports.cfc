<cfcomponent extends="marloo.template">

<cffunction name="RenderPage" access="public" returntype="any" output="true">
<html>
<head>

</head>
<body class="main">
<!--- print button --->
<SCRIPT LANGUAGE="JavaScript"> 
// This script was supplied free by Hypergurl 
// http://www.hypergurl.com 
<!-- hide script and begin 
if (window.print) { 
  document.write('<input type=button name=print value="Print"' + 'onClick="javascript:window.print()">'); 
} 
// End hide --> 
</script>
&nbsp;&nbsp;
<cfset RenderContent()>
</body>
</html>
</cffunction>

<cffunction name="RenderHead" access="public" output="true">
<style>
.main{
  font-family:"Courier New", Courier, monospace;
  font-size:12px;
}
</style>
</cffunction>

</cfcomponent>
