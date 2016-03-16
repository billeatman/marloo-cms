<cfcomponent extends="marloo.shortcode">

<cfset variables.edirectory = "">
<cfset variables.baseCFCPath = "">
<cfset variables.ph = "">
<cfset variables.utilityCode = "">
<cfset variables.jsoup = "">
<cfset variables.edirectory = "">

<cffunction name="init" output="false" returntype="ANY">
	<cfargument name="head_code" required="true" type="struct">
	<cfargument name="site_config" required="true">

	<cfset super.init(argumentCollection=arguments)>

	<!--- create the page helper --->
	<cfset variables.ph = createObject("component", "marloo.core.pageHelper").init(site_config: variables.sc)>

	<cfset variables.utilityCore = createObject('component', 'marloo.core.utilityCore')>
	<cfset variables.jsoup = variables.utilityCore.getJsoup()>
<!---
	<cfset variables.edirectory = createWidget(widgetName: "edirectory")>
--->
	<cfreturn this>
</cffunction>

<cffunction name="runCode" returntype="string" output="true">
	<cfargument name="type" required="true" default="400">
	<cfargument name="s_content" required="false" default="">
	<cfargument name="quote" required="false">
	<cfargument name="name" required="false">
	<cfargument name="email" required="false">
	<cfargument name="title" required="false">

	<cfset var t1 = getTickCount()>
	<cfset var mytimes = arrayNew(1)>

	<cfset var content = "">
	<!--- <cfset var utilityCore = createObject('component', '#baseCFCPath#.core.utilityCore')> --->

	<cfset local.details = "">

	<!--- Clean the input --->
	<cfset local.dom = jsoup.parse(s_content)>

	<cfset local.first_image = "">
	<cfloop array="#local.dom.select("img")#" index="local.node">
		<cfif local.first_image EQ "">
			<cfset local.first_image = local.node>
		</cfif>
		<cfset local.node.remove()>
	</cfloop>

	<!--- remove blank p tags --->
	<cfloop array="#local.dom.select("p")#" index="local.node">
 	<!---	<cfreturn local.node.hasText() & "##" & trim(local.node.text()) & "##"> --->
		<cfif (NOT local.node.hasText()) OR (trim(local.node.text()) EQ chr(160))>
			<cfset local.node.remove()>
		</cfif>
	</cfloop>

	<cfset arguments.s_content = local.dom.body().html()>

	<cfsavecontent variable="content">
		<div class="testimonial">
			<cfif local.first_image NEQ "">
				<cfset local.first_image.removeAttr("style")>
				<cfset local.first_image.removeAttr("height")>
				<cfset local.first_image.removeAttr("width")>
				<cfoutput>#local.first_image.toString()#</cfoutput>
			</cfif>
			<cfoutput>#arguments.s_content#</cfoutput>
			<cfif isDefined('arguments.quote')>
				<cfoutput><p>#arguments.quote#</p></cfoutput>
			</cfif>
			<cfif isQuery(local.details) AND local.details.getRecordCount() EQ 1>
				<cfoutput><p><a title="#local.details.givenName# #local.details.sn#" href="#variables.ph.getSiteRoot()#directory/?mail=#arguments.email#">#local.details.givenName# #local.details.sn#</a><br /><span class="title">#local.details.title#</span></cfoutput></p>				
			<cfelse>
				<p>
				<cfif isDefined('arguments.name') AND isDefined('arguments.email')>
					<a href="mailto:#arguments.email#">#arguments.name#</a>			
				<cfelseif isDefined('arguments.name')>
					#arguments.name#
				</cfif>
				<cfif isDefined('arguments.title')>
					<br /><span class="title">#arguments.title#</span>
				</cfif>
				</p>
			</cfif>
		</div>
	</cfsavecontent>

	<cfreturn content>
</cffunction>

</cfcomponent>
