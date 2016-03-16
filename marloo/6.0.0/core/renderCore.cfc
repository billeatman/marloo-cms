<cfcomponent>

<cfset variables.content = "">
<cfset variables.site_config = "">
<cfset variables.ph = "">
<cfset variables.cache_basket = "">
<cfset variables.shortCodesObjectls = "">


<cffunction name="renderChain" access="public" output="false" returntype="string">
	<cfargument name="content" type="string" required="true">
	<cfargument name="site_config" type="struct" required="true">
	<cfargument name="filterList" type="string" required="false" default="cleanpaths,urlrewriter,shortcodes"> <!--- cleanpaths,paragraphformat,urlrewriter,shortcodes --->
	<cfargument name="history_id" type="numeric" required="false">
	<cfargument name="pageHelper" required="false">
	<cfargument name="ShortCodesObject" required="false">

	<cfset var cache_key = "">
	<cfset var shortfilterlist = arguments.filterlist>

	<cfset variables.site_config = arguments.site_config>
	<cfset variables.content = arguments.content>


	<cfif isNull(arguments.ShortCodesObject)>
		<cfset shortCodesObjectl = createObject("component", "shortcodes").init(site_config: arguments.site_config)>
	<cfelse>
		<cfset shortCodesObjectl = arguments.shortCodesObject>
	</cfif>

	<cfif isNull(arguments.history_id)>
		<cfset cache_key = "1renderContent#site_config.datasource##site_config.cfMappedPath##arguments.filterList##hash(arguments.content, 'md5')#">
	<cfelse>
		<cfset cache_key = "1renderContent#site_config.datasource##site_config.cfMappedPath##arguments.filterList##arguments.history_id#">
	</cfif>

	<cfif isNull(arguments.pageHelper)>
		<cfset variables.ph = createObject("component", "pageHelper").init(site_config: variables.site_config)>
	<cfelse>
		<cfset variables.ph = arguments.pageHelper>
	</cfif>

	<cfset variables.cache_basket = cacheGet(cache_key)>
	<cfif isNull(variables.cache_basket) OR site_config.useCache EQ false>
		<cfset variables.cache_basket = structNew()>

		<!--- Correct/clean file and image paths --->
		<cfif listContains(filterList, 'cleanpaths') NEQ 0>
			<cfset filterCleanPaths()>
		</cfif>

		<!--- fix anchors --->
		<cfif listContains(filterList, 'fixpageanchors') NEQ 0>		
			<cfset variables.content = ReplaceNoCase(variables.content, 'href="##', 'href="#variables.ph.getCurrentURL()###', 'all')>
			<cfset shortfilterlist = listDeleteAt(shortfilterlist, listContains(shortfilterList, 'fixpageanchors'))>
		</cfif>

		<!--- WE - BUGGY FIX! Paragraph Format --->
		<cfif listContains(filterList, 'paragraphformat') NEQ 0>
			<cfset shortfilterlist = listDeleteAt(shortfilterlist, listContains(shortfilterList, 'paragraphformat'))>
			<cfset variables.content = paragraphformat(variables.content)>
		</cfif>

		<!--- URLrewritter --->				
		<cfif listContains(filterList, 'urlrewriter') NEQ 0 AND variables.site_config.URLrewriter EQ true>			
			<cfset variables.content = variables.ph.changeURLStoSEO(variables.content)>
		</cfif>

    	<!--- HTMLtoXHTML --->
		<cfif listContains(filterList, 'htmltoxhtml') NEQ 0>
			<cfinvoke component="utilityCore" method="HTMLtoXHTML" returnvariable="variables.content">
				<cfinvokeargument name="html" value="#variables.content#">
			</cfinvoke>
		</cfif>

		<!--- stripHTML --->
		<cfif listContains(filterList, 'striphtml') NEQ 0>
			<cfinvoke component="utilityCore" method="stripHTML" returnvariable="variables.content">
				<cfinvokeargument name="str" value="#variables.content#">
			</cfinvoke>
		</cfif>

		<!--- Stuff we remove on second pass for shortcodes --->
		<cfif listContains(filterList, 'shortcodes') NEQ 0>
			<cfset shortfilterlist = listDeleteAt(shortfilterlist, listContains(shortfilterList, 'shortcodes'))>
			<cfset variables.cache_basket.codes = filterGetShortCodes()>

			<!--- verify shortcodes --->
			<cfset shortCodesObjectl.VerifyShortCodes(c: variables.cache_basket.codes, site_config: variables.site_config)>
		</cfif>

		<!--- We remove this after the 
		<cfif listContains(filterList, 'fixpageanchors') NEQ 0>
			<cfset shortfilterlist = listDeleteAt(shortfilterlist, listContains(shortfilterList, 'fixpageanchors'))>
		</cfif> --->

		<cfset cache_basket.content = variables.content>
		<cfset cache_basket.shortfilterlist = shortfilterlist>

		<cfif isNull(arguments.history_id)>
			<cfset cachePut(cache_key, variables.cache_basket, createTimeSpan(0,0,5,0))>
		<else>			
			<cfset cachePut(cache_key, variables.cache_basket, createTimeSpan(0,24,0,0))>
		</cfif>
	</cfif>

	<cfset variables.content = variables.cache_basket.content>
	<cfset shortfilterlist = variables.cache_basket.shortfilterlist>

	<!--- Short Codes --->
	<cfif listContains(filterList, 'shortcodes') NEQ 0>
		<cfif NOT ArrayIsEmpty(variables.cache_basket.codes.codes)>
		    <!--- shortcodes --->
	<!---	    <cfdump var="#shortCodesObjectl#">
		    <cfdump var="#variables#">
		    <cfabort> --->

		    <cfinvoke component="#shortCodesObjectl#" method="runCodes" returnvariable="variables.content">
			    <cfinvokeargument name="c" value="#variables.cache_basket.codes#">
			    <cfinvokeargument name="html" value="#variables.content#">
			    <cfinvokeargument name="site_config" value="#variables.site_config#">
		    	<cfinvokeargument name="filterlist" value="#shortfilterlist#">
		    </cfinvoke>

		    <!--- execute the renderHeadOnce ONLY once after all instances have run! --->
			<cfset local.headCode = variables.shortCodesObjectl.getHeadCode()>
			<cfset local.codeCache = variables.shortCodesObjectl.getCodeCache()> 			

			<cfloop collection="#local.codeCache#" item="local.key">
				<cfif structKeyExists(local.codeCache["#local.key#"], 'renderHeadOnce')>
					<cfsavecontent variable="local.masterHead">
					<cfset local.codeCache["#local.key#"].renderHeadOnce()>
					</cfsavecontent>

					<cfset structInsert(local.headCode, "shortcode-" & local.key, local.masterHead , false) >
				</cfif>
			</cfloop>

		</cfif>
	</cfif>

<!--- Admissions Hacks --->
<cfif listContains(filterList, 'admissions_hacks') AND listContains(filterList, 'shortcodes') NEQ 0 AND listContains(filterList, 'striphtml') EQ 0>
	<cfif compare(mid(ltrim(variables.content), 1, 17), '<figure class="fe') EQ 0>		
		<cfset local.firstFigEnd = find('</figure>', variables.content) + 9>
		<cfset variables.content = mid(variables.content, 1, local.firstFigEnd) & "<div class='content'>" & mid(variables.content, local.firstFigEnd, len(variables.content) - local.firstFigEnd + 1) & "</div>">
	<cfelse>
		<cfset variables.content = "<div class='content'>" & variables.content & "</div>">
	</cfif>	
</cfif>
<!--- end of admissions hacks --->

	<cfreturn variables.content>
</cffunction>

<cffunction name="filterGetShortCodes" access="private" output="false" returntype="ANY">
	<cfset var c = "">

	<!--- filter out <p> and </p> tags around shortcodes --->
	<cfset variables.content = ReplaceNoCase(variables.content, '<p>[', '[', 'all')>
	<cfset variables.content = ReplaceNoCase(variables.content, ']</p>', ']', 'all')>

    <cfinvoke component="#shortCodesObjectl#" method="parseCodes" returnvariable="c">
	    <cfinvokeargument name="html" value="#variables.content#">
	</cfinvoke>

	<!--- shortcodes --->
	<cfinvoke component="#shortCodesObjectl#" method="nestCodes">
	    <cfinvokeargument name="c" value="#c#">
	</cfinvoke>

	<cfreturn c>
</cffunction>

<cffunction name="filterCleanPaths" access="private" output="false" returntype="void" >
    <cfset var webGroups = variables.site_config.CMS.web.groups>
    <cfset var web = variables.site_config.CMS.web>
    <cfset var path = variables.site_config.CMS.path>
	<cfset var relativeGroupPath = "">

	<cfif findnocase(path.editorroot, getBaseTemplatePath()) eq 0 AND mid(web.siteroot, len(web.siteroot) - 5, 1) EQ ".">
    	<!--- CMS SITEDEV/RELEASE (I Think) --->
      	<cfreturn>
  	<cfelse>
  		<!--- "Production Site" --->

      	<!--- extract the sitefiles url suffix --->
		<cfset relativeGroupPath = mid(web.groups, findnocase("sitefiles", web.groups), len(web.groups) - findnocase("sitefiles", web.groups) + 1)>

		<cfset variables.content = ReplaceNoCase(variables.content, 'src="#relativeGroupPath#', 'src="#webGroups#', 'all')>
    	<cfset variables.content = ReplaceNoCase(variables.content, 'href="#relativeGroupPath#', 'href="#webGroups#', 'all')>
    	<cfset variables.content = ReplaceNoCase(variables.content, 'href="#relativeGroupPath#', 'href="#webGroups#', 'all')>

		<cfif cgi.server_port_secure>
			<cfset variables.content = ReplaceNoCase(variables.content, 'http://', 'https://', 'all')>
		</cfif>

  	</cfif>
</cffunction>

</cfcomponent>
