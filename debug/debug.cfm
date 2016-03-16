<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Debug Info</title>
</head>

<CFIF NOT isDefined("SESSION.Auth.groups.toplevel")>
  Not Authorized!
<cfabort>
</CFIF>

<body>
<cfoutput>
<a href="#application.web.editorroot#site-dev/?#session.urltoken#" target="_blank">#application.sitename# - DEV</a><br />
<a href="#application.web.editorroot#site-release/?#session.urltoken#" target="_blank">#application.sitename# - RELEASE</a><br />
<br />
<a href="#application.web.editorroot#configToDatabase.cfm" target="_blank">Read Config File</a><br />
<br />
</cfoutput>

<cfdump expand="no" var="#session#" label="SESSION">
<cfdump expand="no" var="#application#" label="APPLICATION">
</body>
</html>
