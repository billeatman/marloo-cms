<cfcomponent>

<cfset variables.page = "">
<cfset variables.sc = "">
<cfset variables.ph = "">
<cfset variables.templateName = "">
<cfset variables.page_title = "">
<cfset variables.metaCore = "">
<cfset variables.isSiteContext = true>    
<cfset variables.context = "">
<cfset variables.basepath = "">
<cfset variables.contextSwitch = 0>
<cfset variables.shortCodesObject = "">
<cfset variables.use_head = false>
<cfset variables.filterList = "admissions_hacks,fixpageanchors,cleanpaths,urlrewriter,shortcodes">
<!---	<cfinvokeargument name="filterList" value="eastereggs,fixpageanchors,cleanpaths,urlrewriter,shortcodes"> --->

<cfset variables.authorized = true>
<cfset variables.title_suffix = true>
<cfset variables.ascii_logo = "">
<cfset variables.isRenderFor = false>
<cfset variables.baseCFCPath = "">

<!--- pseudo-constructor --->
<cffunction name="init" returntype="void" access="public" output="false">
	<cfargument name="page" type="any" required="true">
	<cfargument name="site_config" type="struct" required="true">
	<cfargument name="template_context" type="struct" required="false">
	<cfargument name="use_head" type="boolean" default="true">
	<cfargument name="CMS_auth" type="string" required="false">
	<cfargument name="title_suffix" type="boolean" required="false" default="true">

	<cfif isDefined("arguments.CMS_auth")>
	  <cftry>
	  <cfif NOT isDefined("SESSION.Auth.groups.#arguments.CMS_auth#") and isStruct(application.site_config)>
	  	<h1>Not authorized</h2>
      	<cfabort>
  	  </cfif>
  	  <cfcatch>
	  	<h1>Not authorized</h2>
	  	<cfabort>
  	  </cfcatch>
  	  </cftry>
	</cfif>

	<cfif NOT isNull(arguments.template_context)>
		<cfif lcase(arguments.template_context.sitename) NEQ lcase(arguments.site_config.CMS.sitename)>
			<cfset variables.context = arguments.template_context>
			<cfset variables.isSiteContext = false>
			<cfset variables.basepath = arguments.template_context.basepath>
		</cfif>
	</cfif>

	<cfset variables.use_Head = arguments.use_head>

	<cfset variables.shortCodesObject = createObject("component", "core.shortcodes").init(site_config: arguments.site_config)>

	<cfset variables.page = arguments.page>

	<cfset variables.title_suffix = arguments.title_suffix>

	<!--- copy the passed config to the template --->
	<cfset structAppend(variables, arguments, true)>
      
	<!--- create a shorthand for site_config --->
	<cfset variables.sc = arguments.site_config>

	<cfset variables.baseCFCPath = "#sc.cfMappedPath#.#sc.sitepath#">

	<!--- create the page helper --->
	<cfset variables.ph = createObject("component", "core.pageHelper").init(site_config: variables.sc)>

	<!--- create meta core --->
	<cfset variables.metaCore = createObject("component", "core.metaCore").init(site_config: variables.sc, generate_open_graph: true)>
	
	<cfif isContext()>		
		<cfset variables.basepath = variables.ph.getBasePath()>
	</cfif>

	<!--- create the page utility --->
	<cfset variables.util = createObject("component", "core.utilityCore")>
	<cfset variables.codes = createObject("component", "core.shortcodes").init(site_config: variables.sc)>

	<!--- Enforce Conn SSL page requirements --->
	<cfif variables.page.isSSL() OR isEditor()>
       	<cfset ph.setSSL(true)>
    <cfelse>
		<cfset ph.setSSL(false)>		  	      
 	</cfif>  
	
    <!--- Set the cookies needed for the Web Admin --->
	<cfif sc.admin eq true AND page.isStatic() eq false>
    	<cfcookie name="#sc.CMS.sitename#EDITHISTORY" value="#variables.page.getPage().idhistory#">
    </cfif>
	
    <cfcookie name="#sc.CMS.sitename#EDITPAGE" value="#variables.page.getID()#">
    <cfcookie name="#sc.CMS.sitename#EDITTIME" value="#now()#">	

    <!--- Adds the JS needed for the Web Admin --->
    <!--- <cfset addEditorJS()>	--->
</cffunction>

<cffunction name="UseHead" access="public" output="false">
	<cfargument name="value" type="boolean" required="false" default="true"> 
	<cfset variables.useHead = arguments.value>
</cffunction>

<cffunction name="getPage" access="public" output="false">
	<cfsavecontent variable="local.pageHTML">
		<cfset renderPage()>
	</cfsavecontent>

	<cfif variables.use_head EQ true>	
    	<cfset variables.metaCore.addMeta(description: "#StripCR(page.getTextDescription(maxLength: 155, nearestSentence: true))#")>

		<cfset variables.page_title = page.getPageTitle()>

		<cfset local.og_meta = structNew()>
    	<cfset local.og_meta["og:title"] = variables.page_title>
    	<cfset variables.metaCore.addMeta(argumentCollection: local.og_meta, key_attribute: 'property', overwrite: false)>

		<cfif isDefined("sc.CMS.site.titleSuffix") AND variables.title_suffix EQ true>
			<cfset variables.page_title = variables.page_title & " - #sc.CMS.site.titleSuffix#">
		</cfif>

		<!--- hack to work around not being able to use "og:..." as a key --->
		<cfset local.og_meta = structNew()>
    	<cfset local.og_meta["og:url"] = URLEncodedFormat(variables.ph.getCurrentUrl())>
    	<cfset variables.metaCore.addMeta(argumentCollection: local.og_meta, key_attribute: 'property')>

		<cfset var meta = structNew()>

		<cfsavecontent variable="local.pageHead1">
<cfoutput>#renderHead()#</cfoutput>
		</cfsavecontent>

		<cfsavecontent variable="local.pageHead2">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><cfoutput>#variables.page_title#</cfoutput></title>
<cfif variables.ascii_logo NEQ "">
	<cfoutput>#variables.ascii_logo#</cfoutput>
</cfif>

<cfif ph.isConnSSL()>
	<cfset local.siteroot = ReplaceNoCase(ph.GetSiteRoot(), 'http://', 'https://')>
<cfelse>
	<cfset local.siteroot = ph.GetSiteRoot()>
</cfif>

<base href="<cfoutput>#local.siteroot#</cfoutput>" /> <!--- #ph.getBasePath()# --->	
<cfset variables.metaCore.renderMeta()>
<cfoutput>#local.pageHead1#</cfoutput>
		</cfsavecontent>	
		<cfhtmlHead text="#local.pageHEAD2#">
	</cfif>	

	<cfreturn local.pageHTML>
</cffunction>

<cffunction name="addMeta" access="public" output="false">
	<cfset variables.metaCore.addMeta(argumentCollection: arguments)>
</cffunction>

<cffunction name="renderPage" access="public" output="true">
	&nbsp;
</cffunction>

<cffunction name="isContext" access="private" output="false" returntype="boolean">
	<cfreturn variables.isSiteContext>
</cffunction>

<cffunction name="getTemplateRoot" access="public" output="false">
	<cfif isContext() EQ false>
		<cfreturn variables.context.basepath>
	</cfif>
	<cfreturn variables.basepath>
</cffunction>

<cffunction name="useTemplateContext" access="public" output="false">
<!--- Use the actual site context root instead of the template context root --->
<cfif NOT isContext()>
	<cfset variables.contextSwitch = variables.contextSwitch - 1>
</cfif>		
</cffunction>

<cffunction name="useSiteContext" access="public" output="false">
<!--- Reset the proper template context root after rendering content --->
<cfif NOT isContext()>
	<cfset variables.contextSwitch = variables.contextSwitch + 1>
</cfif>
</cffunction>

<cffunction name="getContext" access="public" output="false" returntype="numeric">
	<cfreturn variables.contextSwitch>
</cffunction>

<cffunction name="processContent" access="public" output="false" returntype="string">
	<cfargument name="content" default="" type="string" required="false">
	<cfargument name="filterList" default="#variables.filterList#" required="false">

	<cfinvoke component="core.renderCore" method="renderChain" returnvariable="local.content">
		<cfinvokeargument name="filterList" value="#arguments.filterList#">
		<cfif content EQ "">
			<cfinvokeargument name="content" value="#variables.page.getInfo()#">		
		<cfelse>
			<cfinvokeargument name="content" value="#arguments.content#">		
		</cfif>
		<cfinvokeargument name="site_config" value="#variables.sc#">
		<cfinvokeargument name="pageHelper" value="#variables.ph#">
		<cfif content EQ "">
			<cfinvokeargument name="history_id" value="#variables.page.getPage().IDhistory#">
		</cfif>	
		<cfinvokeargument name="shortCodesObject" value="#variables.shortCodesObject#">
	</cfinvoke>	

	<cfreturn local.content>
</cffunction>

<cffunction name="renderContent" access="public" output="true">
<cfsilent>

<cfset var content = "">

<cfinvoke component="core.renderCore" method="renderChain" returnvariable="content">
	<cfinvokeargument name="filterList" value="#variables.filterList#">
	<cfinvokeargument name="content" value="#variables.page.getInfo()#">
	<cfinvokeargument name="site_config" value="#variables.sc#">
	<cfinvokeargument name="pageHelper" value="#variables.ph#">
	<cfinvokeargument name="history_id" value="#variables.page.getPage().IDhistory#">
	<cfinvokeargument name="shortCodesObject" value="#variables.shortCodesObject#">
</cfinvoke>

</cfsilent>	
<!--- Application can be inserted here --->
<CFIF trim(variables.page.getPage().app) NEQ "">
   	<cfinclude template="/#variables.sc.cfMappedPath#/#variables.sc.sitepath#/apps/#variables.page.getPage().app#">
</CFIF>                        		
<cfoutput>#content#</cfoutput>
</cffunction>

<cffunction name="renderHead" output="true">
<cfif isDefined('application.pagedesc')>
<!-- Added By CMS -->
<cfoutput>#getEditorJS()#</cfoutput>
</cfif>
<!-- Added By shortcodes and widgets -->
<cfset local.codes = variables.shortCodesObject.GetList()>
<cfset local.pageHEAD = "">
<cfloop collection="#local.codes#" item="local.i">
	<cfset local.pageHEAD = local.pageHEAD & local.codes["#local.i#"]>
</cfloop>
<cfoutput>#local.pageHEAD#</cfoutput>
<cfif isRenderFor EQ true>
<!-- Added By renderFor -->
<script type="text/javascript">
	$(document).ready(function() {
		// removes empty 'for' containers - CM / WE
		$('.forContainer:empty').parent().remove();
	});
</script>
</cfif>
</cffunction>

<cffunction name="createWidget" access="public" returntype="ANY" output="false">
	<cfargument name="widgetname" type="string">
	
	<cfreturn createObject("#variables.baseCFCpath#.widgets.#widgetname#").init(argumentCollection: arguments, head_code: variables.shortCodesObject.getHeadCode(), site_config: variables.sc)>
</cffunction>

<!--- adds a JS pingMe function so we can poll the page from the editor --->
<cffunction name="getEditorJS" access="private" output="false" returnType="ANY">
<cfsavecontent variable="local.pingme">
<script type="text/javascript">var pingMe = function(){return true;}</script>
</cfsavecontent>
<cfreturn local.pingme>
</cffunction>

<cffunction name="setTemplateName" access="public" output="false" returnType="void">
	<cfargument name="name" type="string" required="true">
	<cfset variables.templateName = arguments.name>
</cffunction>

<cffunction name="getTemplateName" access="public" output="false" returntype="string">	
	<cfreturn variables.templateName>
</cffunction>

<cffunction name="getFilterList" access="public" output="false" returntype="string">
	<cfreturn variables.filterList>
</cffunction>

<cffunction name="PageIdToUrl">
	<cfargument name="page_id" type="numeric" required="true">
	
	<cfset var urlString = "page.cfm?page_id=#arguments.page_id#">
	<cfset var myurl = "">

	<cfif variables.contextSwitch LT 0>
		<cfset myurl = getTemplateRoot() & urlString>		
	<cfelse>
		<cfset myurl = variables.ph.PageIdToUrl(arguments.page_id)>
		<cfif isNumeric(myurl) OR myurl EQ false>
			<cfset myurl = "page.cfm?page_id=#arguments.page_id#">
		</cfif>
	</cfif>

	<cfif sc.admin EQ true>
		<!--- adds our cf tokens --->
		<cfset myurl = URLSessionFormat(myurl)>
	</cfif>
	
	<cfreturn myurl>
</cffunction>

<cffunction name="addHTMLhead">
	<cfargument name="text" required="true" type="string">
	<cfset structInsert(variables.shortCodesObject.getHeadCode(), "template-" & variables.templateName & '-' & CreateUUID(), arguments.text, false) >
</cffunction>

<cffunction name="setASCIIHeadLogo" returntype="void">
	<cfargument name="text" required="true" type="string">
	<cfset variables.ascii_logo = arguments.text>
</cffunction>

<!--- TRUE the CMS is running, FALSE the CMS is not running ---> 
<cffunction access="public" name="isEditor" output="false" returntype="boolean">
 	<cfset var editor = false>
 	<cfset var sitename = ucase(variables.sc.CMS.sitename)> 	

 	<cfif IsDefined("cookie.#sitename#EDITTOOLBAR")>			
 		<cfset editor = true>
    </cfif>
 
    <cfreturn editor>
</cffunction> 

<!--- works with content shortcode --->
<cffunction access="public" name="renderFor" output="true" returnType="void">
	<cfargument name="for" type="string" required="true" hint="identifier">
	<cfargument name="snapPoint" type="numeric" required="false" hint="snap point for mobile">
	<cfif isDefined("arguments.snapPoint")><cfset local.dataSnappoint = "data-snappoint=#arguments.snapPoint#"><cfelse><cfset local.dataSnappoint = ""></cfif>
<div id="for-#trim(lcase(arguments.for))#" #local.dataSnappoint# class="forContainer"></div>
<cfset variables.isRenderFor = true>
</cffunction>

</cfcomponent>
