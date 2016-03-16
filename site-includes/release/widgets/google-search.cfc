<cfcomponent displayname="google-search" extends="marloo.widget">

<cffunction name="init" access="public" returntype="google-search" output="false">
  <cfset local.me = super.init(argumentCollection: arguments)>

<cfsavecontent variable="local.headstuff">
	<!-- Added by google-search widget -->
	<!-- Put the following javascript before the closing </head> tag. -->
	<script>
	  (function() {
	    var cx = '<cfoutput>#variables.sc.cms.searchAPIKeys.google#</cfoutput>';
	    var gcse = document.createElement('script'); 
	    gcse.type = 'text/javascript'; 
	    gcse.async = true;
	    gcse.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') +
	        '//www.google.com/cse/cse.js?cx=' + cx;
	    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(gcse, s);
	  })();
	</script>
	</cfsavecontent>

	<cfset addHTMLHead(local.headstuff)>
    
    <cfreturn local.me>
</cffunction>

<cffunction name="render" returntype="void" output="true">
<!-- Added by google-search widget -->
<!-- Place this tag where you want the search box to render -->
<!-- Results URL is saved in CSE control panel "Get Code" tab. -->
<gcse:searchbox-only resultsUrl="/searchresults.cfm"></gcse:searchbox-only>
</cffunction>

</cfcomponent>