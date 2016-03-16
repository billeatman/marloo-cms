<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="username" required="true">
	<cfargument name="formhash" required="true">
	<cfargument name="autoresize" required="false" default="true">
	<cfargument name="header" required="false" default="show">
    <cfargument name="height" required="false">
	<cfset var content = "">

    <cfsavecontent variable="content">
    	<cfoutput>
    	<div id="wufoo-#arguments.formhash#">
Fill out my <a href="http://#arguments.username#.wufoo.com/forms/#arguments.formhash#">online form</a>.
</div>
<script type="text/javascript">var #arguments.formhash#;(function(d, t) {
var s = d.createElement(t), options = {
'userName':'#arguments.username#', 
'formHash':'#arguments.formhash#', 
autoResize : true,
<cfif isDefined("arguments.height")>    
'height':'#arguments.height#',
</cfif>
'async':true,
'host':'wufoo.com',
'header':'#arguments.header#',
 ssl: true}
s.src = ('https:' == d.location.protocol ? 'https://' : 'http://') + 'wufoo.com/scripts/embed/form.js';
s.onload = s.onreadystatechange = function() {
var rs = this.readyState; if (rs) if (rs != 'complete') if (rs != 'loaded') return;
try { z7x3k1 = new WufooForm();z7x3k1.initialize(options);z7x3k1.display(); } catch (e) {}};
var scr = d.getElementsByTagName(t)[0], par = scr.parentNode; par.insertBefore(s, scr);
})(document, 'script');</script>
    </cfoutput>
    </cfsavecontent>

    <cfreturn content>
</cffunction>

</cfcomponent>

