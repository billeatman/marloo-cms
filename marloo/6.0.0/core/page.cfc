<cfcomponent displayname="page">

<!--- properties --->
<cfset variables.admin = "">
<cfset variables.page_id = "" >
<cfset variables.datasource = "">
<cfset variables.site_config = "">

<!--- internal queries --->
<cfset variables.qPage = "">
<cfset variables.qParent = "">
<cfset variables.qPeers = "">
<cfset variables.qChildren = "">
<cfset variables.qQuicklinks = "">
<cfset variables.Breadcrumbs = "">

<!--- attributes that have overrides --->	
<cfset variables.pageTitle = "">	
<cfset variables.textDescription = "">
<cfset variables.modifiedDate = now()>
<cfset variables.ownerEmail = "">

<!--- pseudo-constructor --->
<cffunction name="init" returntype="any" access="public" output="false">
   	<cfargument name="page_id" type="string" required="true">
   	<cfargument name="history_id" type="string" required="false" default="">
	<cfargument name="site_config" type="struct" required="true">
	<cfargument name="admin" type="boolean" required="false">

	<cfif isNull(arguments.admin)>
		<cfset arguments.admin = arguments.site_config.admin>		
	</cfif> 

	<!--- Set page object vars --->   
	<cfset variables.site_config = arguments.site_config>         
   	<cfset variables.datasource = arguments.site_config.datasource>  
	<cfset variables.admin = arguments.admin>
	<cfset variables.page_id = arguments.page_id>

	<!--- get the page --->
	<cfset variables.qPage = getPageQuery(
			page_id: arguments.page_id,
			history_id: arguments.history_id,
			admin: variables.admin,
			datasource: variables.datasource	  	
	)>

	<!--- make sure page exists --->
	<cfif NOT isQuery(variables.qPage) OR variables.qPage.recordCount EQ 0>
		<cfreturn false>
	</cfif>

	<!--- set the page variables --->
	<cfset variables.pageTitle = trim(variables.qPage.title)>
	<cfset variables.page_id = variables.qPage.id>

	<cfif isDate(qPage.submittedDate)>		
		<cfset variables.modifiedDate = qPage.submittedDate>
	<cfelse>
		<cfset variables.modifiedDate = qpage.modifiedDate>
	</cfif>

	<cfset variables.ownerEmail = qPage.owner>
	
	<cfreturn this>	  
</cffunction>

<cffunction name="getPageQuery" returntype="ANY" access="private" output="false">
   	<cfargument name="page_id" type="string" required="true">
   	<cfargument name="history_id" type="string" required="false" default="">
   	<cfargument name="admin" type="boolean" required="true">
   	<cfargument name="datasource" type="string" required="true">

    <!--- get the requested history page --->
    <cfif arguments.history_id neq "" and arguments.admin eq true>
        <cfquery datasource="#arguments.datasource#" name="local.qMyPage">
          select [id]
                ,[idParent]
                ,[idHistory]
                ,[securityGroup]
                ,[title]
                ,[info]
                ,[visible]
                ,[modifiedDate]
                ,[modifiedBy]
                ,[createdDate]
                ,[createdBy]
                ,[deleted]
                ,[locked]
                ,[lockedBy]
                ,[lockedDate]
                ,[idShortcut]
                ,[shortcutType]
                ,[shortcutExternal]
                ,[quicklink]
                ,[app]
                ,[gModifiedBy]
                ,[gModifiedDate]
                ,[editSession]
                ,[state]
                ,[usedDate]
                ,[sortIndex]
                ,[menu]
                ,[url]
                ,[template]
                ,[submittedDate]
                ,[owner]
                ,[submittedBy] 
                ,[SSL]
 			from mrl_siteHistory 
          	where idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.history_id#">
        </cfquery>
    <cfelse>
        <!--- get the requested page --->
        <cfstoredproc datasource="#arguments.datasource#" procedure="mrl_getPage" result="local.asdf">
          <cfprocparam cfsqltype="cf_sql_integer" value="#arguments.page_id#">
          <cfprocparam cfsqltype="cf_sql_bit" value="#NOT(arguments.admin)#">
          <cfprocresult name="local.qMyPage">
        </cfstoredproc>
    </cfif>    
	
	<cfreturn local.qMyPage>
</cffunction>

<cffunction access="public" name="isSSL" output="false" returntype="boolean">
	<cfreturn "#variables.qPage.SSL eq 'T'#"> 
</cffunction>

<cffunction access="public" name="getSecurityGroup" output="false" returntype="string">
	<cfreturn variables.qPage.securityGroup>
</cffunction>
 	
<!--- TRUE the CMS is running, FALSE the CMS is not running ---> 
<cffunction access="public" name="isEditor" output="false" returntype="boolean">
 	<cfset var editor = false>
 	<cfset var sitename = variables.site_config.CMS.sitename> 	

 	<cfif IsDefined("cookie.#sitename#EDITTOOLBAR")>			
 		<cfset editor = true>
    </cfif>
 
    <cfreturn editor>
</cffunction> 

<!--- load config into the variable scope --->
<cffunction name="getTemplate" access="public" output="false" returntype="string">
    <cfreturn variables.qPage.template>
</cffunction>
   
<!--- gets children pages --->	   
<cffunction name="getChildren" access="public" output="false" returntype="query">
   	<cfargument name="page_id" required="false" type="numeric" default="#variables.page_id#">
	<cfargument name="summary" required="false" type="boolean" default="true" > 

	<cfif arguments.summary EQ false AND arguments.page_id EQ getID() AND isQuery(variables.qChildren)>
		 <cfreturn variables.qChildren>
	</cfif>

	<!--- get the breadcrumbs --->
	<cfinvoke component="pageHelper" method="getChildren" returnvariable="local.qChildren">
		<cfinvokeargument name="page_id" value="#arguments.page_id#" >
		<cfinvokeargument name="datasource" value="#variables.datasource#" >
		<cfinvokeargument name="useAlphaorder" value="#variables.site_config.CMS.tree['ALPHAORDER']#">
		<cfinvokeargument name="summary" value="#arguments.summary#"> 
	</cfinvoke>

	<cfif arguments.summary EQ false AND arguments.page_id EQ getID() AND isQuery(variables.qChildren)>
		 <cfset variables.qChildren = local.qChildren>
	</cfif>

   	<cfreturn local.qChildren>
</cffunction>

<cffunction name="hasChildren" returntype="boolean">
	<cfreturn getChildren().recordCount gt 0>
</cffunction>

<cffunction name="hasSiblings" returntype="boolean">
	<cfreturn getPeers().recordCount gt 0>
</cffunction>

<cffunction name="hasPeers" returntype="boolean">
	<cfreturn getPeers().recordCount gt 0>
</cffunction>

   
<!--- get quicklinks --->
<!--- WE - fix speed issues with needing getChildren(summary: false) --->
<cffunction name="getQuicklinks" access="public" output="false" returntype="query">
	<cfset var qChildren = getChildren(summary: false)>

	<cfif isQuery(variables.getQuicklinks)>
		 <cfreturn variables.getQuicklinks>
	</cfif>

	<cfquery dbtype="query" name="variables.qQuicklinks">
		select menu, id from qChildren
		where quicklink = 'T'        
		<cfif variables.site_config.CMS.tree.alphaorder eq true>
		order by menu ASC
	    <cfelse>
	    order by sortIndex ASC
	    </cfif>	
	</cfquery>

	<cfreturn variables.qQuicklinks>
</cffunction>

<!--- gets parent page --->	   
<cffunction name="getParent" access="public" output="false" returntype="query">
	<cfif isQuery(variables.qParent)>
		<cfreturn variables.qParent>
	</cfif>

	<!--- get the parent page --->
	<cfstoredproc datasource="#variables.DataSource#" procedure="mrl_getPage">
		<cfprocparam cfsqltype="cf_sql_integer" value="#variables.qPage.idParent#">
	   	<cfprocresult name="variables.qParent">
	</cfstoredproc>
	  
    <cfreturn variables.qParent>
</cffunction>

<cffunction name="getTextDescription" access="public" returntype="string" output="false">
	<cfargument name="maxLength" type="numeric" required="no" default="100">
	<cfargument name="minLength" type="numeric" required="no" default="75">
    <cfargument name="nearestSentence" type="boolean" required="false" default="false">
    
	<cfset var myTextDescription = "">

	<cfif variables.textDescription NEQ "">
		<cfinvoke component="utilityCore" method="stringToSummary" returnvariable="mytextDescription">
			<cfinvokeargument name="maxLength" value="#arguments.maxLength#">
        	<cfinvokeargument name="minLength" value="#arguments.minLength#">
        	<cfinvokeargument name="nearestSentence" value="#arguments.nearestSentence#">
			<cfinvokeargument name="sourceStr" value="#variables.textDescription#">
		</cfinvoke>
	<cfelse>			
    	<cfinvoke component="pageCore" method="getPageSummary" returnvariable="myTextDescription">
     		<cfinvokeargument name="site_config" value="#variables.site_config#">
     		<cfinvokeargument name="historyId" value="#variables.qPage.idhistory#">
         	<cfinvokeargument name="maxLength" value="#arguments.maxLength#">
         	<cfinvokeargument name="minLength" value="#arguments.minLength#">
         	<cfinvokeargument name="nearestSentence" value="#arguments.nearestSentence#">
     	</cfinvoke>
	</cfif>

    <cfreturn myTextDescription>
</cffunction>
	
<cffunction name="setTextDescription" access="public" returntype="void" output="false">
	<cfargument name="textDescription" type="string" required="true">
	<cfset variables.textDescription = arguments.textDescription>
</cffunction>
   
<cffunction name="getID" access="public" returntype="numeric" output="false">
   	<cfreturn variables.page_id>
</cffunction>

<cffunction name="getIDHistory" access="public" returntype="numeric" output="false">
   	<cfreturn variables.qPage.IdHistory>
</cffunction>

   
<cffunction name="getPage" access="public" returntype="query" output="false">
	<cfreturn variables.qPage>
</cffunction>

<cffunction name="getInfo" access="public" returntype="string" output="false">
	<cfreturn variables.qPage.info>		
</cffunction>

<cffunction name="getContent" access="public" returntype="string" output="false">
	<cfreturn variables.qPage.info>		
</cffunction>

<cffunction name="getTitle" access="public" returntype="string" output="false">
	<cfreturn getPageTitle()>	
</cffunction>

<cffunction name="getPageTitle" access="public" returntype="string" output="false">
	<cfreturn variables.pageTitle>
</cffunction>

<cffunction name="setTitle" access="public" returntype="string" output="false">
	<cfreturn setPageTitle(argumentCollection: arguments)>	
</cffunction>

<cffunction name="setPageTitle" access="public" returntype="void" output="false">
   <cfargument name="pageTitle" type="string" required="true">

   <cfset variables.pageTitle = arguments.pageTitle>
</cffunction>

<cffunction name="setModifiedDate" access="public" output="false">
	<cfargument name="date" type="date" required="true">
	<cfset variables.modifiedDate = arguments.date>
</cffunction>

<cffunction name="getModifiedDate" access="public" output="false" returntype="date">
	<cfreturn variables.modifiedDate>
</cffunction>

<cffunction name="setOwnerEmail" access="public" output="false">
	<cfargument name="email" type="string" required="true">
	<cfset variables.OwnerEmail = arguments.email>
</cffunction>

<cffunction name="getOwnerEmail" access="public" output="false" returntype="string">
	<cfreturn variables.OwnerEmail>
</cffunction>

<cffunction name="dumpVars" returntype="void" access="public" output="true">
	<cfdump var="#variables#">
</cffunction>
   
<cffunction name="isStatic" access="public" returntype="boolean" output="false">
   	<cfreturn false>
</cffunction>

<!--- get page breadcrumbs --->	   
<cffunction name="getBreadCrumbs" access="public" returntype="ANY" output="false">
	<cfif isStruct(variables.BreadCrumbs)>
	 	<cfreturn variables.BreadCrumbs>
	</cfif>		

	<!--- get the breadcrumbs --->
	<cfinvoke component="pageHelper" method="getBreadcrumbs" returnvariable="variables.Breadcrumbs" argumentcollection="#arguments#">
		<cfinvokeargument name="page_id" value="#variables.page_id#" >
		<cfinvokeargument name="datasource" value="#variables.datasource#" >
		<cfinvokeargument name="site_config" value="#variables.site_config#" >
	</cfinvoke>
	  
	<!--- set the menu to match the id history menu value --->
   	<cfif getPage().idhistory neq "" and variables.admin eq true>
     	<cfset QuerySetCell(variables.Breadcrumbs.query, "menu", variables.qPage.menu, variables.Breadcrumbs.query.recordcount)>
	</cfif>

	<cfreturn variables.Breadcrumbs>
</cffunction>

<cffunction name="getSiblings" access="public" returntype="query" output="false">
	<cfreturn getPeers(argumentCollection: arguments)>	
</cffunction>

<cffunction name="getPeers" access="public" returntype="query" output="false">
	<cfif isQuery(variables.qPeers)>
  	 	<cfreturn variables.qPeers>
  	</cfif>	

	<!--- get the breadcrumbs --->
	<cfinvoke component="pageHelper" method="getPeers" returnvariable="variables.qPeers">
		<cfinvokeargument name="page_id" value="#variables.page_id#" >
		<cfinvokeargument name="datasource" value="#variables.datasource#" >
		<cfinvokeargument name="useAlphaorder" value="#variables.site_config.CMS.tree['ALPHAORDER']#">
	</cfinvoke>
		
	<cfreturn variables.qPeers>
</cffunction>

<cffunction access="public" name="findNearestPageBy" output="false" returntype="any">
	<cfargument name="title" type="string" required="true">

	<!--- find the nearest page --->
	<cfquery name="local.qPage" datasource="#variables.datasource#">
		with c 
		as 
		( 
			select id, idparent, menu, url, (0) as level, visible, deleted FROM mrl_siteAdmin 
			where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.page_id#"> 
			
			union all 
			
			select b.id, b.idparent, b.menu, b.url, c.level + 1, b.visible, b.deleted FROM mrl_siteAdmin b
			join c on c.idparent = b.id
			where (b.id != '0' and b.id is not null)
		) 
	
		select top(1) d.id, d.idparent, [level], d.title, d.id from c
		join mrl_siteAdmin d on d.idparent = c.id
		where d.deleted <> 'T' and title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
		order by level asc
	</cfquery> 

	<!--- create the page object for the page --->
	<cfif local.qPage.recordCount NEQ 0>
		<cfreturn local.qPage.id>
	</cfif>

	<cfreturn />
</cffunction>

<cffunction name="getSlides" access="public" returntype="array" output="false" hint="returns an array of slides">
	<cfargument name="width" type="numeric" required="true">
	<cfargument name="height" type="numeric" required="false" default="0" hint="Set to 0 for ratio based on first image">
	<cfargument name="quality" type="numeric" required="false" default=".70">
	<cfargument name="cropType" type="string" required="false" default="head" hint="center,head">
	<cfargument name="randomize" type="boolean" required="false" default="false" hint="randomize array of slides">

	<cfif NOT ListFind('center,head', arguments.cropType)>
		<cfthrow message="cropType must be either 'center' or 'head'">
	</cfif>

	<cfset local.slides = arrayNew(1)>

	<!--- first check if this is already a slides page --->
	<cfif isSlidesPage() EQ true>
		<cfset local.pageSlides = this>
	<cfelse>
		<cfset local.slidesPageId = findNearestPageBy(title: "_slides")>
		
		<cfif isNull(local.slidesPageId)>
			<cfreturn local.slides>
		</cfif>

		<cfset local.pageSlides = NEW page(page_id: local.slidesPageId, admin: true, site_config: variables.site_config)>
	</cfif>

	<cfset local.cache = createObject("component", "cacheCore").init(datasource: site_config.datasource, site_config: variables.site_config)>
    <cfset local.hash = hash("getSlides#local.pageSlides.getIdHistory()##arguments.width##arguments.height##arguments.quality#", "md5")>
	    
    <cfset local.cacheData = cache.checkHash(local.hash, local.pageSlides.getIdHistory(), "getSlides")>	

	<cfif local.cacheData NEQ false AND site_config.useCache>
		<!--- do nothing, we have it :) --->
        <cfset local.slides = objectload(tobinary(local.cacheData))>
    <!---    <cfset local.slides = deserializeJSON(local.cacheData)> --->
	<cfelse>
		<cfset local.baseCFCPath = "#site_config.cfMappedPath#.#site_config.sitepath#">
		<cfset local.utilityCore = createObject('component', 'utilityCore')>
		<cfset local.jsoup = local.utilityCore.getJsoup()>
		<cfset local.dom = jsoup.parse(local.pageSlides.getContent())>
		<cfset local.images = local.dom.select('img')>

		<cfset local.i = 1>

		<!--- create the page helper --->
		<cfset local.ph = createObject("component", "pageHelper").init(site_config: site_config)>

		<cfloop array="#local.images#" index="local.image">
			<cfdump var="#local.image.attr('src')#">
			<cfset local.slide = structNew()>
			<cfset local.slide.alt = local.image.attr('alt')>				
			<cfif local.image.parent().tagName() EQ 'a'>
				<cfset local.slide.a = structNew()> 
				<cfset local.slide.a.href = local.image.parent().attr('href')>
				<cfset local.slide.a.title = local.image.parent().attr('title')>
			</cfif>
			<cfset local.slide.paths = local.ph.webToFilePath(local.image.attr('src'))>

			<!--- Set the ratio based on first image if height = zero --->
			<cfif local.i EQ 1 AND arguments.height EQ 0>
  			    <cfset local.imageAttribs = ImageInfo(ImageRead(local.slide.paths.filepath))>
				<cfset local.multiplier = arguments.width / local.imageAttribs.width>
				<cfset arguments.height = round(local.imageAttribs.height * local.multiplier)>
			</cfif>

			<cfinvoke component="imageCore" method="imageCacher" returnvariable="local.slide.RESIZED">
				<cfinvokeargument name="imagePath" value="#local.slide.paths.filepath#">
				<cfinvokeargument name="revKey" value="#local.image.attr('src')#">
				<!---
				<cfinvokeargument name="imageChain" value='[{"FUNC":"imageResize","WIDTH":#arguments.width#.0,"HEIGHT":""},{"FUNC":"imageCrop#arguments.cropType#","WIDTH":#arguments.width#,"HEIGHT":#arguments.height#}]'>
				--->
				<cfinvokeargument name="imageChain" value='[{"FUNC":"imageZoomToFit#arguments.cropType#","WIDTH":#arguments.width#,"HEIGHT":#arguments.height#}]'>
				<cfinvokeargument name="site_config" value="#site_config#">
				<cfinvokeargument name="quality" value="#arguments.quality#">					
			</cfinvoke>

			<cfset arrayAppend(local.slides, local.slide)>
			<cfset local.i = local.i + 1>
		</cfloop>

		<cfset cache.insertHash(local.hash, local.pageSlides.getIdHistory(), "getSlides", toBase64(objectSave(local.slides)))>
	</cfif>

	<!--- hack to fix http or https after caching.  Most caching will take place in the CMS in https --->
	<cfloop array="#local.slides#" index="local.i">
		<cfif cgi.server_port_secure>
            <cfset local.i.resized = ReplaceNoCase(local.i.resized, 'http://', 'https://')>
        <cfelse>
            <cfset local.i.resized = ReplaceNoCase(local.i.resized, 'https://', 'http://')>        	
        </cfif>
	</cfloop>

	<cfif arguments.randomize EQ true>
		<!--- Shuffle it (ie. randomly sort it). --->
		<!--- http://www.bennadel.com/blog/280-randomly-sort-a-coldfusion-array-updated-thanks-mark-mandel.htm --->
		<cfset CreateObject(
		"java",
		"java.util.Collections"
		).Shuffle(local.slides) /> 
	</cfif>

	<cfreturn local.slides>
</cffunction>

<cffunction name="isSlidesPage" access="public" returntype="boolean" output="false">
	<cfreturn lcase(getTitle()) EQ '_slides'>		
</cffunction>

<cffunction name="isOrphan" access="public" returnType="boolean" output="false">
	<!---
	<cfquery datasource="#variables.datasource#" name="local.qOrphan">
		select id from mrl_sitePublic
		where id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getPage().idParent#">
	</cfquery>

	<cfreturn local.qOrphan.recordCount LT 1>
	--->

	<cfreturn getBreadCrumbs(useCache: false).orphaned>
</cffunction>



</cfcomponent>
	