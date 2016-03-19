<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
This is the display of the frameworks MessageBox.
You can customize this as you want via your own css and the
messagebox_style_override setting flag in your configuration file.

----------------------------------------------------------------------->
<!--- Set the css class --->
<cfif msgStruct.type eq "error">
	<cfset msgClass = "alert-danger">
	<cfset msgType = "Error">
<cfelseif msgStruct.type eq "warning">
	<cfset msgClass = "alert-warning">
	<cfset msgType = "Warning">
<cfelse>
	<cfset msgClass = "alert-info">
	<cfset msgType = "Info">
</cfif>
<cfoutput>
<div class="alert #msgClass# fade in">
	<a href="##" class="close" data-dismiss="alert" aria-label="close">&times;</a>
	<strong>#msgType#</strong> #msgStruct.message#</div>
</cfoutput>
<cfsetting enablecfoutputonly="false">