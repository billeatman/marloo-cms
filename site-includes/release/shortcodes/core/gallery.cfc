<cfcomponent extends="marloo.shortcode">

<cffunction name="getContentImages" hint="Get the content images">
	<cfargument name="s_content" type="string" required="true">

	<cfset var utilityCore = createObject('component', '#getCoreCFCPath()#.utilityCore')>
	<cfset var cache_key = "">

	<cfif trim(arguments.s_content) EQ "">
		<cfreturn arguments.s_content>
	</cfif>

	<cfset cache_key = "galleryshortcode#variables.sc.datasource##hash(SerializeJSON(arguments), 'md5')#">

	<cfset local.cache_basket = cacheGet(cache_key)>

	<cfif isNull(local.cache_basket) OR variables.sc.useCache EQ false>
	   	<cfset local.xhtml = utilityCore.HTMLtoXHTML(s_content)>
	   	<cfset local.xml = utilityCore.HTMLtoXML(local.xhtml)>
	   	<cfset local.images = XMLSearch(local.xml, "//*[local-name()='img']")>
		<cfset local.id = createUUID()>

		<cfset local.aspectTotal = 0>
		<cfset local.ii = 0>

		<cfset local.images2 = arrayNew(1)>

		<cfloop array="#local.images#" index="local.i">
			<cftry>	
				<cfset local.strpos = len(sc.CMS.web.groups)>

				<!--- https to http --->
				<cfset local.i.xmlAttributes.src = ReplaceNoCase(local.i.xmlAttributes.src, 'https://', 'http://')>
				<cfset local.src = mid(local.i.xmlAttributes.src, local.strpos + 1, len(local.i.xmlAttributes.src))>
				<cfset local.filepath = URLDecode(local.src)>
				<cfset local.filepath = sc.CMS.path.groups & replacenocase(local.filepath, '/', '\', 'all')>
				<cfset local.filepath = getToken(local.filepath, 1, '?')>
		        <cfset local.src = sc.CMS.web.groups & local.src>
		        <cfset local.alt = local.i.xmlAttributes.alt>
				<cfset local.info = ImageInfo(ImageRead(local.filepath))>
				<cfset local.aspect = local.info.width / local.info.height>
				<cfset local.aspectTotal = local.aspectTotal + local.aspect>

				<cfset ArrayAppend(local.images2, StructNew())>
				<cfset local.ii = local.ii + 1>
				
				<!--- replace xml with struct --->
				<cfset local.image2 = local.images2[ArrayLen(local.images2)]>
				<cfset local.image2.filepath = local.filepath>
				<cfset local.image2.width = local.info.width>
				<cfset local.image2.height = local.info.height>
				<cfset local.image2.src = local.src>
				<cfset local.image2.alt = local.alt>
				<cfset local.image2.aspect = local.aspect>
				<cfcatch>
				<!--- read error probably occured... skip to next  --->
				</cfcatch>
			</cftry>
		</cfloop>

		<cfif local.ii EQ 0>
			<cfset local.ii = 1>
		</cfif>

		<cfset local.aspectAvg = local.aspectTotal / local.ii>

		<cfloop array="#local.images2#" index="local.i">
			<cfif local.aspectAvg lt local.i.aspect>
				<cfset local.i.newwidth = int(local.i.height * local.aspectAvg)>
				<cfset local.i.newheight = local.i.height>			
			<cfelse>
				<cfset local.i.newheight = int(local.i.width / local.aspectAvg)>
				<cfset local.i.newwidth = local.i.width>
			</cfif>
		</cfloop>

		<cfset cachePut(cache_key, local.images2, createTimeSpan(0,24,0,0))>
	<cfelse>
		<cfset local.images2 = local.cache_basket>
	</cfif>

	<!--- hack to fix http or https after caching.  Most caching will take place in the CMS in https --->
	<cfloop array="#local.images2#" index="local.i">
		<cfif cgi.server_port_secure>
            <cfset local.i.src = ReplaceNoCase(local.i.src, 'http://', 'https://')>
        <cfelse>
            <cfset local.i.src = ReplaceNoCase(local.i.src, 'https://', 'http://')>        	
        </cfif>
	</cfloop>

	<cfreturn local.images2>
</cffunction>


<cffunction name="defaultGallery">
	


</cffunction>

	
<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="width" required="false" default="564">
	<cfargument name="height" required="false" default="10000">
	<cfargument name="s_content" required="false" default="" hint="shortcode data string">
	<cfargument name="type" required="false" default="">

	<cfset var content = "">
	<cfset var contentImages = getContentImages(argumentCollection: arguments)>

	<cfoutput>
    <cfsavecontent variable="content">
	<div class="gallery">
	<cfset local.web.groups = replaceNoCase(sc.CMS.web.groups, 'http://', '')>
	<cfset local.web.groups = replaceNoCase(local.web.groups, 'https://', '')>
  	<cfloop array="#contentImages#" index="local.i">
 	    <cfif findnocase(local.web.groups, local.i.src) neq 0>
   		<cfsilent>
      		<cfinvoke component="#getCoreCFCPath()#.imageCore" method="imageCacher" returnvariable="local.webPath">
          		<cfinvokeargument name="imagePath" value="#local.i.filepath#">
       	        <cfinvokeargument name="imageChain" value='[{"FUNC":"imageCropHead","WIDTH":#local.i.newwidth#,"HEIGHT":#local.i.newheight#},{"FUNC":"imageScaleToFit","WIDTH":#arguments.width#,"HEIGHT":#arguments.height#}]'>
	        	<cfinvokeargument name="site_config" value="#sc#">
        	</cfinvoke>
       		</cfsilent>
       	<figure class="item">
			<img src="#local.webPath#" alt="#local.i.alt#" /> 
       		<figcaption>#local.i.alt#</figcaption>
       	</figure>
    	</cfif>
    </cfloop>
    </div>

    </cfsavecontent>
    </cfoutput>

    <cfreturn content>
</cffunction>

</cfcomponent>
