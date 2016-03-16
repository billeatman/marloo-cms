<cfcomponent extends="marloo.shortcode">

<cffunction name="init">
	<cfset super.init(argumentCollection=arguments)>
	<!--- create the page helper --->
<!--- 	<cfset baseCFCPath = "#site_config.cfMappedPath#.#site_config.sitepath#">
	<cfset variables.ph = createObject("component", "#baseCFCPath#.core.pageHelper").init(site_config: variables.sc)>
--->
	<cfreturn this>
</cffunction>

<cffunction name="runCode" returntype="string" output="false">		
	<cfargument name="s_content" required="false" default="">
	<cfargument name="selected" required="false" default="0" type="numeric">

	<cfset var content = "">
	<cfset var utilityCore = createObject('component', 'marloo.core.utilityCore')>
	<cfset var ph = createObject('component', 'marloo.core.pageHelper').init(site_config: variables.sc)>

	<cfset arguments.selected = arguments.selected + 1>

   	<cfset local.xhtml = utilityCore.HTMLtoXHTML(arguments.s_content)>
   	<cfset local.xml = utilityCore.HTMLtoXML(local.xhtml)>
   	<cfset local.tabs = XMLSearch(local.xml, "//*[local-name()='div']")>

   	<cfset local.tabsli = arrayNew(1)>

   	<cfloop array="#local.tabs#" index="local.i">
   		<cfif structkeyExists(local.i.XmlAttributes, 'data-title')>   			
	   		<cfset ArrayAppend(local.tabsli, structNew())>
	   		<cfset local.tabli = local.tabsli[arrayLen(local.tabsli)]>

	   		<cfset local.tabli.href = "###local.i.XmlAttributes.id#">
	   		<cfset local.tabli.id = local.i.XmlAttributes.id>
	   		<cfset local.tabli.title = "#local.i.XmlAttributes['data-title']#">
  		</cfif>
   	</cfloop>

   	<cfif arrayLen(local.tabsli) EQ 0>
   		<cfreturn arguments.s_content>
   	</cfif>

   	<cfset local.id = local.tabsli[arguments.selected].id>
   	<cfset local.start = findNoCase(local.id, arguments.s_content)>   	
   	<cfset local.start = findNoCase('class="tab"', arguments.s_content, local.start) - 1>

   	<cfset local.new_s_content = mid(arguments.s_content, 1, local.start) & 'class="tab current"' & mid(arguments.s_content, local.start + 12, len(arguments.s_content) - local.start + 12)>

	<cfsavecontent variable="content">
		<!--- <div class="tabs">
			<ul>
				<li class="current"><a href="#tab1">Tab 1</a></li>
				<li><a href="#tab2">Tab 2</a></li>
				<li><a href="#tab3">Tab 3</a></li>
			</ul>
			<div>
				<div class="tab current" id="tab1">Tab 1 inner content</div>
				<div class="tab" id="tab2">Tab 2 inner content</div>
				<div class="tab" id="tab3">Tab 3 inner content</div>
			</div>
		</div> --->	
	<div class="tabs">
		<ul>
			<cfoutput>
			<cfloop from="1" to="#ArrayLen(local.tabsli)#" index="local.i">
				<cfset local.tabli = local.tabsli[local.i]>
				<li <cfif local.i EQ arguments.selected>class="current"</cfif>><a href="#local.tabli.href#">#local.tabli.title#</a></li>							
			</cfloop>
			</cfoutput>
		</ul>
		<div>
			<cfoutput>#local.new_s_content#</cfoutput>
		</div>
	</div>
	</cfsavecontent>

	<cfreturn content>
</cffunction>

</cfcomponent>
