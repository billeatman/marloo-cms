﻿<cfoutput>#html.doctype()#<html lang="en" ng-app="marloo-cms"><head>	<meta charset="utf-8">	<title>Marloo CMS</title>	<meta name="description" content="An open-source CMS for large-scale websites">    <meta name="author" content="Marloo CMS">	<!--- Base URL --->	<base href="#getSetting("HTMLBaseURL")#" />	<!--- plugins CSS --->	<link href="includes/dist/plugins/bootstrap-3.3.6-dist/css/bootstrap.min.css" rel="stylesheet" />	<link href='https://fonts.googleapis.com/css?family=Roboto:400,300,700' rel='stylesheet' type='text/css'>	<link href='includes/dist/plugins/themify-icons/themify-icons.css' rel='stylesheet' />	<link href='includes/dist/plugins/typicons-font/src/font/typicons.min.css' rel='stylesheet' />	<link href='includes/dist/plugins/font-awesome-4.5.0/css/font-awesome.min.css' rel='stylesheet' />	<link href='includes/dist/plugins/bootstrap-accessibility-plugin/plugins/css/bootstrap-accessibility_1.0.3.css' rel='stylesheet' />	<!--- Marloo CSS --->	<link href='includes/src/css/marloo.css' rel='stylesheet' /></head><body data-spy="scroll">#renderView()#	<script type="text/javascript" src="app.js"></script><!-- plugins JS -->	<script type="text/javascript" src="includes/dist/plugins/jquery/jquery-2.2.1.min.js"></script>	<script type="text/javascript" src="includes/dist/plugins/bootstrap-3.3.6-dist/js/bootstrap.min.js"></script>	<script type='text/javascript' src='includes/dist/plugins/bootstrap-accessibility-plugin/plugins/js/bootstrap-accessibility_1.0.3.min.js'></script>	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.3/angular.min.js"></script>	<!-- Marloo JS --></body></html></cfoutput>