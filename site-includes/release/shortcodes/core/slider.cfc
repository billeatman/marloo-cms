<cfcomponent extends="marloo.shortcode">
	
<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="width" required="false" default="564">
	<cfargument name="height" required="false" default="10000">
	<cfargument name="s_content" required="false" default="">

	<cfset var content = "">
	<cfset var baseCFCPath = "#sc.cfMappedPath#.#sc.sitepath#">
	<cfset var utilityCore = createObject('component', '#baseCFCPath#.core.utilityCore')>
	<cfset var cache_key = "">

	<cfif trim(arguments.s_content) EQ "">
		<cfreturn arguments.s_content>
	</cfif>


	<cfset arguments.width = 564>
	<cfset arguments.height = 10000>

	<cfset cache_key = "slidershortcode#variables.sc.datasource##hash(SerializeJSON(arguments), 'md5')#">

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
			<cfset ArrayAppend(local.images2, StructNew())>

			<cfset local.ii = local.ii + 1>
			<cfset local.strpos = len(sc.CMS.web.groups)>      
			<cfset local.src = mid(local.i.xmlAttributes.src, local.strpos + 1, len(local.i.xmlAttributes.src))>
			<cfset local.filepath = URLDecode(local.src)>
			<cfset local.filepath = sc.CMS.path.groups & replacenocase(local.filepath, '/', '\', 'all')>
			<cfset local.filepath = getToken(local.filepath, 1, '?')>
	        <cfset local.src = sc.CMS.web.groups & local.src>
	        <cfset local.alt = local.i.xmlAttributes.alt>
			<cfset local.info = ImageInfo(ImageRead(local.filepath))>
			<cfset local.aspect = local.info.width / local.info.height>
			<cfset local.aspectTotal = local.aspectTotal + local.aspect>
			
			<!--- replace xml with struct --->
			<cfset local.image2 = local.images2[ArrayLen(local.images2)]>
			<cfset local.image2.filepath = local.filepath>
			<cfset local.image2.width = local.info.width>
			<cfset local.image2.height = local.info.height>
			<cfset local.image2.src = local.src>
			<cfset local.image2.alt = local.alt>
			<cfset local.image2.aspect = local.aspect>
		</cfloop>

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

	<cfoutput>
    <cfsavecontent variable="content">
	<ul id="slider1" class="slideshow">
  	<cfloop array="#local.images2#" index="local.i">
	    <cfif findnocase(sc.CMS.web.groups, local.i.src) neq 0>
    		<cfsilent>
      		<cfinvoke component="#baseCFCPath#.core.imageCore" method="imageCacher" returnvariable="local.webPath">
          		<cfinvokeargument name="imagePath" value="#local.i.filepath#">
       	        <cfinvokeargument name="imageChain" value='[{"FUNC":"imageCropHead","WIDTH":#local.i.newwidth#,"HEIGHT":#local.i.newheight#},{"FUNC":"imageScaleToFit","WIDTH":#arguments.width#,"HEIGHT":#arguments.height#}]'>
	        	<cfinvokeargument name="site_config" value="#sc#">
        	</cfinvoke>
       		</cfsilent>

     	<li><img src="#local.webPath#" alt="#local.i.alt#" /></li>
    	</cfif>
    </cfloop>
    </ul>
<!---
	<div class="gallery">
 			<cfloop array="#local.images2#" index="local.i">
		        <cfif findnocase(sc.CMS.web.groups, local.i.src) neq 0>
		        	<cfsilent>

			      	<cfinvoke component="#baseCFCPath#.core.imageCore" method="imageCacher" returnvariable="local.webPath">
			          	<cfinvokeargument name="imagePath" value="#local.i.filepath#">
			            <cfinvokeargument name="imageChain" value='[{"FUNC":"imageCropHead","WIDTH":#local.i.newwidth#,"HEIGHT":#local.i.newheight#},{"FUNC":"imageScaleToFit","WIDTH":#arguments.width#,"HEIGHT":#arguments.height#}]'>
				        <cfinvokeargument name="site_config" value="#sc#">
			        </cfinvoke>

		        	</cfsilent>
		        	<figure class="item">
						<img src="#local.webPath#" alt="#local.alt#" /> 
		        		<figcaption>#local.alt#</figcaption>
		        	</figure>
		        </cfif>
 			</cfloop>
	</div>
	--->

    </cfsavecontent>
    </cfoutput>
    

    <cfreturn content>
</cffunction>

</cfcomponent>
