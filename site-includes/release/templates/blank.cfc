<cfcomponent extends="marloo.template">


<cffunction name="renderHead" output="true">
<cfif ph.isConnSSL()>
  <link href='https://fonts.googleapis.com/css?family=Merriweather:300|Open+Sans:700|Open+Sans+Condensed:300' rel='stylesheet' type='text/css'>
<cfelse>
  <link href='http://fonts.googleapis.com/css?family=Merriweather:300|Open+Sans:700|Open+Sans+Condensed:300' rel='stylesheet' type='text/css'>
</cfif>
<link rel="stylesheet" type="text/css" href="admissions_base/styles/blank.css" />

<cfinvoke component="analytics" method="getGoogleAnalytics" returnvariable="local.googleAnalytics" />
<cfoutput>#local.googleAnalytics#</cfoutput>

<!-- scroll to top of page -->
<script type="text/javascript">
function scrollUp(){
window.parent.parent.scrollTo(0,0);
alert('scrolled');
}
</script>

<cfset super.renderHead(argumentCollection=arguments)>
</cffunction>

<cffunction name="RenderPage" access="public" returntype="any" output="true">
<!DOCTYPE html>
<head>
</head>
<body>
	
  <cfset RenderContent()>
</body>
</html>
</cffunction>

</cfcomponent>