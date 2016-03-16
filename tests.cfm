<html>
	<head>
		<title></title>
	</head>
	<body>
		<h1>LEO - Tests</h1>
		
		<cfset r = new testbox.system.testBox( directory="marloo-admin/tests") >
		<cfoutput>#r.run()#</cfoutput>
	</body>
</html> 