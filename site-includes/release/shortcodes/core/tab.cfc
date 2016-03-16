<cfcomponent extends="marloo.shortcode">

<cfset variables.namedTabs = structNew()>

<cffunction name="renderHeadOnce" output="true">
<script language="javascript">
$(document).ready(function() {
	// Get the key value pairs of tab names and uuids
	var tabHashes = #serializeJSON(variables.namedTabs)#;
	//console.log('tabHashes', tabHashes);

	// generic tab reset code 
    $('.tabs > ul li').click(function(){
      	$(this).parents('.tabs').find('.current').removeClass('current');
      	$(this).addClass('current');
      	$($(this).find('a').attr('href')).addClass('current');
      	return false;
    });

	// If the url hash is a tab name
	if (window.location.hash.slice(1) in tabHashes){
		var openTab = $('.tabs ul li a[href=##' + tabHashes[window.location.hash.slice(1)] + ']');

		if (openTab.length){
	      $(openTab).parents('.tabs').find('.current').removeClass('current');
	      $(openTab).parent().addClass('current');
	      $($(openTab).attr('href')).addClass('current');
		}
	}
});
</script>
<!---

 $('.tabs > ul li').click(function(){
      $(this).parents('.tabs').find('.current').removeClass('current');
      $(this).addClass('current');
      $($(this).find('a').attr('href')).addClass('current');
      return false;
    });

<cfdump var="#variables.namedtabs#">
<cfabort>
--->

</cffunction>

<cffunction name="runCode" returntype="string" output="false">		
	<cfargument name="s_content" required="false" default="">
	<cfargument name="title" required="true" type="string">
	<cfargument name="name" required="false" type="string">

	<cfset var content = "">
	<cfset var UUID = CreateUUID()>

<!---
	<cfdump var="#arguments#">
	<cfabort>
--->

	<cfif isDefined("arguments.name")>
		<cfset variables.namedTabs["#arguments.name#"] = UUID>
	</cfif>

	<cfoutput>
	<cfsavecontent variable="content">
		<div id="#UUID#" <cfif isDefined("arguments.name")>name="#arguments.name#"</cfif> class="tab" data-title="#arguments.title#">#arguments.s_content#</div>
	</cfsavecontent>
	</cfoutput>

	<cfreturn content>

</cffunction>

</cfcomponent>
