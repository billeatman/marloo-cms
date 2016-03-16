<cfcomponent extends="marloo.shortcode">

<!---
<cffunction name="renderHeadOnce" output="true">
</cffunction>	
--->	

<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="type" required="true" default="400">
	<cfargument name="s_content" required="false" default="">

	<cfset var content = "">
	<cfset var baseCFCPath = "#sc.cfMappedPath#.#sc.sitepath#">
	<cfset var utilityCore = createObject('component', '#baseCFCPath#.core.utilityCore')>

   	<cfset local.xhtml = utilityCore.HTMLtoXHTML(s_content)>
   	<cfset local.xml = utilityCore.HTMLtoXML(local.xhtml)>
   	<cfset local.images = XMLSearch(local.xml, "//*[local-name()='img']")>

<!---
<figure class="featured">
							<img src="admissions_base/images/twocolumn_featured.jpg" alt="feature alt text" />
							<figcaption class="caption right">
							Photo caption goes here
							</figcaption>
						</figure>
--->

	<cfoutput>
    <cfsavecontent variable="content">
<cfloop array="#local.images#" index="local.i">
<cfif findnocase(sc.CMS.web.groups, local.i.xmlAttributes.src) neq 0>
<cfsilent>
   	<cfset local.strpos = len(sc.CMS.web.groups)>
   	<cfif isDefined("local.i.xmlAttributes.alt")>
	    <cfset local.alt = local.i.xmlAttributes.alt>
	<cfelse>
		<cfset local.alt = "">	
   	</cfif>      
    <cfset local.src = mid(local.i.xmlAttributes.src, local.strpos + 1, len(local.i.xmlAttributes.src))>
    <cfset local.filepath = URLDecode(local.src)>
	<cfset local.filepath = sc.CMS.path.groups & replacenocase(local.filepath, '/', '\', 'all')>
    <cfset local.filepath = getToken(local.filepath, 1, '?')>
    <cfset local.src = sc.CMS.web.groups & local.src>


   	<cfinvoke component="#baseCFCPath#.core.imageCore" method="imageCacher" returnvariable="local.webPath">
       	<cfinvokeargument name="imagePath" value="#local.filepath#">
        <cfinvokeargument name="imageChain" value='[{"FUNC":"imageResize","WIDTH":564, "HEIGHT":""}]'>
        <cfinvokeargument name="site_config" value="#sc#">
	</cfinvoke>
</cfsilent>
<figure class="featured">
	<img src="#local.webPath#" alt="#local.alt#" />
	<cfif local.alt NEQ "">		
	<figcaption class="caption right">
		#local.alt#
	</figcaption>
	</cfif>
</figure>
</cfif>
<!---
<cfdump var="#local#">
--->
<cfbreak>
</cfloop>

    </cfsavecontent>
	</cfoutput>

	
    
    <cfreturn content>
</cffunction>

</cfcomponent>
