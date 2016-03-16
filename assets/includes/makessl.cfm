<cfif application.ssl eq true>
	<cfif not cgi.server_port_secure>
	   <cflocation url="https://#cgi.server_name##cgi.script_name#"/>  <!--- ?#cgi.query_string#" /> --->
	</cfif>
</cfif>