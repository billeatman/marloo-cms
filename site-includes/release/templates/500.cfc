<cfcomponent extends="marloo.template">

<!--- pseudo-constructor --->
<cffunction name="init" returntype="any" access="public" output="true">
    <!--- create dummy page object --->
	<cfset var page_object = createObject("component", "marloo.core.pageStatic")>

	<!--- Overrides for static page head --->
	<cfset page_object.setPageTitle('Internal Error 500')>
	<cfset page_object.setTextDescription('An internal error prevented the request')>		

	<cfset super.init(argumentCollection=arguments, page: page_object)>

	<!--- meta overrides --->
	<cfset addMeta(robots: 'noindex, nofollow')>

	<!--- set the proper statuscode --->
	<cfheader statuscode="500" statustext="Internal Server Error">

  	<cfreturn this>
</cffunction>

<cffunction name="renderContent" access="public" output="true">
	<h2>500</h2>
	<p>An internal server error occured.</p>  
</cffunction>

<cffunction name="renderBreadCrumbs" returnType="void" access="public" output="true">
<!---   	<a href="#ph.GetSiteRoot()#" title="Home">Home</a> &gt; <a href="#ph.GetCurrentURL()#" title="Internal Error">Internal Error</a> --->

<article id="breadcrumbs">
<a title="Home" href="#ph.GetSiteRoot()#">Homepage</a>
>
<a title="Internal Error" href="#ph.GetCurrentURL()#">Internal Error</a>
</article>

</cffunction>

</cfcomponent>



