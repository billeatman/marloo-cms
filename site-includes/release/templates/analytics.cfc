<cfcomponent displayname="analytics" output="false">

<cffunction name="getGoogleAnalytics" access="public" output="false" returntype="string">
<cfset var analytics = "">
	
<cfsavecontent variable="analytics">	
<!--- using an "unsupported" mode in the head instead of right after the <HTML> tag.
http://www.lunametrics.com/blog/2014/12/12/google-tag-manager-snippet-placement/
--->

<!-- Google Tag Manager -->
<!-- End Google Tag Manager -->


<!-- inserted by analytics -->

</cfsavecontent>

<cfreturn analytics>

</cffunction>

</cfcomponent>