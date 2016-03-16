<cfcomponent extends="utilityCore">

    <cfset variables.datasource = ''>    

    <cfset variables.pageCaller = -1>
    <cfset variables.VARCHARMAX = 1000>
    
    <cfset cache = createObject("component", "cacheCore").init(datasource: variables.datasource)>
    
    <cffunction access="public" output="false" name="isAdmin" returntype="boolean" hint="returns true if the browsing within in the CMS">
        <cfreturn isDefined("session.sessionid") and isDefined("session.user.login")>
    </cffunction>
     
    <!--- Get latest draft idHistory --->
    <cffunction access="public" output="false" name="getLatestDraft" returntype="query">
        <cfargument name="page_id" type="numeric" required="true">  

        <cfquery datasource="#application.datasource#" name="LOCAL.qPage">
            select top 1 [id]
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
              ,[category]
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
              ,[template]
              ,[url] from mrl_siteHistory
            where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.page_id#"> and state != 'preview'
            order by usedDate desc
        </cfquery>

        <cfreturn LOCAL.qPage>
    </cffunction>

    <cffunction access="public" output="false" name="getPageById" returntype="struct">
        <!--- Core Page Functions --->
        <cfargument name="pageId" required="true">
        <cfargument name="historyId" required="false" default="">
        <cfargument name="site_config" required="true">
<!---
        <cfargument name="admin" require="false" default="false">
        <cfargument name="datasource" required="false" type="string" default="#variables.datasource#">
--->        
        <cfset var page = "">
        <cfset var cacheData = "">
        <cfset var myHash = "">
        
        <cfif arguments.site_config.datasource neq "">
            <cfset cache.setDatasource(arguments.site_config.datasource)>
            <cfset variables.datasource = arguments.site_config.datasource>    
        </cfif> 

        <cfset myHash = hash("pageid#arguments.pageid#historyid#arguments.historyid#admin#arguments.site_config.admin#getPageById", "md5")>

        <cfset page = createObject("component", "page").init(page_id: arguments.pageid, history_id: arguments.historyid, site_config: arguments.site_config)>
        <cfreturn page>
    </cffunction>

    <!--- WE 10/05/2012 Added Nearest Sentence --->
    <cffunction access="public" output="false" name="getPageSummary" returntype="string">
        <cfargument name="pageId" type="numeric" required="false" default="-1">
        <cfargument name="historyId" type="numeric" required="false" default="-1">
        <cfargument name="site_config" type="struct" required="true">
        <cfargument name="maxLength" type="numeric" required="false" default="100">
        <cfargument name="minLength" type="numeric" required="false" default="#arguments.maxLength - 25#">
        <cfargument name="nearestSentence" type="boolean" required="false" default="false">
                
        <cfset var myHash = "">
        <cfset var myText = "">
        <cfset var xmlArray = "">
        <cfset var mySummary = "">
        <cfset var firstPeriod = "">
        <cfset var nextBlank = "">
        <cfset var loopi = "0">

        <cfif arguments.pageId EQ -1 AND arguments.historyId EQ -1>
            <cfthrow message="pageId or historyId required" >           
        </cfif>
              
        <cfif arguments.minLength lt 1>
            <cfset arguments.minLength = 1>
        </cfif>
       
        <cfset cache.setDatasource(arguments.site_config.CMS.datasource)>
        <cfset variables.datasource = arguments.site_config.CMS.datasource>    
                
        <cfif arguments.historyId eq -1>
            <cfset arguments.historyId = getIdHistory(pageId)>
        </cfif>
        
        <cfset myHash = hash("#arguments.maxLength#-#arguments.nearestSentence#-#arguments.minLength#historyid#arguments.historyid#getPageSummary", "md5")>
        <cfset cacheData = cache.checkHash(myHash, arguments.historyId, "getPageSummary")>  
        <cfif cacheData neq false>
            <!--- do nothing, we have it :) --->
            <cfset mySummary = cacheData>
        <cfelse>       
            <cfset mySummary = getPageInfoRaw(historyId: arguments.historyId, datasource: variables.datasource)>

            <cfinvoke component="renderCore" method="renderChain" returnvariable="mySummary">
                <cfinvokeargument name="filterList" value="htmltoxhtml,striphtml,shortcodes">
                <cfinvokeargument name="content" value="#mySummary#">
                <cfinvokeargument name="site_config" value="#arguments.site_config#">
                <cfinvokeargument name="history_id" value="#arguments.historyid#">
            </cfinvoke>
<!---
            <cfset mySummary = HTMLtoXHTML(mySummary)>
            <cfset mySummary = stripHTML(mySummary)> --->
            <cfset mySummary = stringToSummary(sourceStr: mySummary, maxLength: arguments.maxLength, minLength: arguments.minLength, nearestSentence: arguments.nearestSentence)>           
            <cfset cache.insertHash(myHash, arguments.historyId, "getPageSummary", mySummary)>
        </cfif>

        <cfreturn mySummary>
    </cffunction>
    
    <cffunction access="public" output="false" name="getPageImages" returntype="any">
        <cfargument name="pageId" required="true">
        <cfargument name="historyId" type="numeric" required="false" default="-1">
        <cfargument name="site_config" type="struct" required="false">
        
        <cfset var myHash = "">
        <cfset var arraySize = 0>

        <cfif NOT isNull(arguments.site_config)>
            <cfset cache.setDatasource(arguments.site_config.datasource)>
            <cfset variables.datasource = arguments.site_config.datasource>                
        </cfif>
        
        <cfif arguments.historyId eq -1>
            <cfset arguments.historyId = getIdHistory(pageId)>
        </cfif>

        <cfset myHash = hash("pageid#arguments.pageid#historyid#arguments.historyid#getPageImages", "md5")>
        
        <cfset cacheData = cache.checkHash(myHash, arguments.pageId, "getPageImages")>
        <cfif cacheData neq false>
            <!--- do nothing, we have it :) --->
            Hit!<br/>
            <cfset imageArray = DeserializeJSON(cacheData)>
        <cfelse>       
            Miss!<br> 
            <cfset myImages = XMLPageSearch(pageId: arguments.pageId, historyId: arguments.historyId, xPathString: "//*[local-name()='img']")>
           
            <cfset imageArray = arraynew(1)>

            <cfset local.ph = New pageHelper(site_config: arguments.site_config)>

            <cfloop array="#myImages#" index="i">

                <cfset arraySize = ArrayLen(imageArray)>
                <!--- Hack that NEEDS to be fixed --->
                <cfif structkeyExists(i, "xmlAttributes")>
                    <cfset arrayappend(imageArray, i.xmlAttributes)>
                <cfelse>
                    <cfif structkeyExists(i, "img")>
                        <cfif structkeyExists(i.img, "xmlAttributes")>
                            <cfset arrayappend(imageArray, i.img.xmlAttributes)>
                        </cfif>
                    </cfif>
                </cfif>

                <cfif ArrayLen(imageArray) gt arraySize>
                    <cfset arraySize = ArrayLen(imageArray)>

                    <!--- look for ? at end of file --->
                    <cfif findNoCase('?', imageArray[arraySize].src) neq 0>
                        <cfset imageArray[arraySize].src = mid(imageArray[arraySize].src, 1, findNoCase('?', imageArray[arraySize].src) - 1)>
                    </cfif>     

                    <cfset local.paths = local.ph.webToFilePath(imageArray[arraySize].src)>
                    <cfif local.paths.filePath NEQ "">
                        <cfset imageArray[arraySize]["filepath"] = local.paths.filePath>
                        <cfset imageArray[arraySize].src = local.paths.webPath>                        
                    </cfif>
                </cfif>

            </cfloop>

            <cfset cache.insertHash(myHash, arguments.pageId, "getPageImages", serializeJSON(imageArray))>
        </cfif>
  
        <cfreturn imageArray>
    </cffunction> 

    <cffunction access="public" output="false" name="getPageAnchors" returntype="any">
        <cfargument name="pageId" required="true">
        <cfargument name="historyId" type="numeric" required="false" default="-1">
        <cfargument name="datasource" required="false" type="string" default="">
        <cfset var myHash = "">
        <cfset var arraySize = 0>
        
        <cfif arguments.datasource neq "">
            <cfset cache.setDatasource(arguments.datasource)>
            <cfset variables.datasource = arguments.datasource>    
        </cfif> 
        
        <cfif arguments.historyId eq -1>
            <cfset arguments.historyId = getIdHistory(pageId)>
        </cfif>

        <cfset myHash = hash("pageid#arguments.pageid#historyid#arguments.historyid#getPageAnchors", "md5")>
        
        <cfset cacheData = cache.checkHash(myHash, arguments.pageId, "getPageAnchors")>
        <cfif cacheData neq false>
            <!--- do nothing, we have it :) --->
            Hit!<br/>
            <cfset anchorArray = DeserializeJSON(cacheData)>
        <cfelse>       
            Miss!<br> 
            <cfset myAnchors = XMLPageSearch(pageId: arguments.pageId, historyId: arguments.historyId, xPathString: "//*[local-name()='a']")>
           
            <cfset anchorArray = arraynew(1)>

            <cfloop array="#myAnchors#" index="i">
                <cfset arraySize = ArrayLen(anchorArray)>
                <!--- Hack that NEEDS to be fixed --->
                <cfif structkeyExists(i, "xmlAttributes")>
                    <cfset arrayappend(anchorArray, i.xmlAttributes)>
                <cfelse>
                    <cfif structkeyExists(i, "a")>
                        <cfif structkeyExists(i.a, "xmlAttributes")>
                            <cfset arrayappend(anchorArray, i.a.xmlAttributes)>
                        </cfif>
                    </cfif>
                </cfif>                
            </cfloop>

            <cfset cache.insertHash(myHash, arguments.pageId, "getPageAnchors", serializeJSON(anchorArray))>
        </cfif>
  
        <cfreturn anchorArray>
    </cffunction> 

    <cffunction name="getIdHistory" access="public" returntype="numeric">
        <cfargument name="pageId" required="true" type="numeric">
        <cfargument name="datasource" required="false" type="string" default="#variables.datasource#">
            <cfquery datasource="#arguments.datasource#" name="qIdHistory">
                select idHistory 
                from mrl_siteAdmin 
                where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.pageId#">
            </cfquery>
            
            <cfif qIdHistory.getRowCount() eq 1>            
                <cfreturn qIdHistory.idHistory>
            <cfelse>
                <cfreturn -1>
            </cfif>  
    </cffunction> 

    <cffunction name="getPageInfoRaw" access="public" output="false" returntype="string">
        <cfargument name="historyId" type="numeric" required="true">
        <cfargument name="datasource" type="string" required="false" default="#variables.datasource#">
        
        <cfset var qPageInfo = "">
        <cfset var cacheData = "">
        <cfset var cacheHash = hash("getPageInfoRaw historyId#arguments.historyId#", "md5")>
        
        <cfset cacheData = cache.checkHash(cacheHash, arguments.historyId, "getPageInfoRaw")>
        
        <cfif cacheData neq false>
            <cfreturn cacheData>
        <cfelse>
            <cfquery datasource="#variables.datasource#" name="qPageInfo">
                select info 
                from mrl_siteHistory 
                where idHistory = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.historyId#">
            </cfquery>
        </cfif>
        
        <cfset cache.insertHash(cacheHash, arguments.historyId, "getPageInfoRaw", qPageInfo.Info)>
                
        <cfreturn qPageInfo.Info>
    </cffunction>

    <cffunction name="getPageXML" access="public" returntype="xml" output="false">
        <cfargument name="historyId" type="numeric" required="false" default="-1">
        <cfargument name="pageId" type="numeric" required="true">
        <cfargument name="datasource" type="string" required="false" default="#variables.datasource#">
        <cfset var xmlString = "">
        <cfif arguments.datasource neq "">
            <cfset cache.setDatasource(arguments.datasource)>
            <cfset variables.datasource = arguments.datasource>    
        </cfif> 
                
        <!--- check pagexml cache layer --->
        <cfset XMLQueryHash2 = hash("historyId#arguments.historyId#pageid#arguments.pageId#", "md5")>
        <cfset cacheData = cache.checkHash(XMLQueryHash2, arguments.pageId, "pageXML")>
        <cfif cacheData neq false>
            <!--- do nothing, we have it :) --->
            Hit 2<br/>
            <cfset pageXML2 = xmlparse(cacheData)>
        <cfelse>
            Miss 2<br/>
            
            <cfset pageInfo = getPageInfoRaw(datasource: arguments.datasource, historyId: arguments.historyId)>

            <cfset pageXML2 = HTMLtoXML(pageInfo)>
            
            <cfset xmlString = toString(pageXML2)>
            <cfif len(xmlString) lt variables.VARCHARMAX>      
                <cfset cache.insertHash(XMLQueryHash2, arguments.pageId, "pageXML", toString(pageXML2))>
            </cfif>
        </cfif>

        <cfreturn pageXML2>

    </cffunction>

    <!--- wrapper --->
    <cffunction name="XMLPageSearch" access="public" returntype="any" output="false">
        <cfargument name="pageId" type="numeric" required="true">
        <cfargument name="historyId" type="numeric" required="false" default="-1">
        <cfargument name="xPathString" type="string" required="true">
                
        <cfif arguments.historyId eq -1>
            <cfset arguments.historyId = getIdHistory(pageId)>
        </cfif>        
        
        <cfset XMLQueryHash = hash("#arguments.xPathString#pageid#arguments.pageid#historyid#arguments.historyid#", "md5")>
    
        <!--- check first cache layer--->
        <cfset cacheData = cache.checkHash(XMLQueryHash, arguments.pageId, 'xmlquery')>

        <cfif cacheData neq false>
            <cfset myArray = arrayNew(1)>
            <cfif isXML(cacheData)>
                <cfset XMLcache = XmlParse(cacheData)>                       
                <cfset ArrayAppend(myArray ,XMLcache)>
            <cfelse>
                <cfset ArrayAppend(myArray ,cacheData)>
            </cfif>
            Hit 1<br>
            
            <cfreturn myArray>
        </cfif>
        Miss 1<br>
           
        <!--- call get Page XML --->
        <cfset pageXML2 = getPageXML(historyId: arguments.historyId, pageId: arguments.pageId)>                 

        <cfset myXML = XMLSearch(pageXML2, arguments.xPathString)>
        
       

        <!--- we only cache single returns --->     
        <cfif ArrayLen(myXML) eq 1>
            <cfset cache.insertHash(XMLQueryHash, arguments.pageId, "xmlquery", toString(myXML[1]))>
 
            <cfset myArray = arrayNew(1)>
            <cfif isXML(myXml[1])>
                <cfset ArrayAppend(myArray , xmlparse(tostring(myXml[1])))>
            <cfelse>
                <cfset ArrayAppend(myArray , tostring(myXml[1]))>
            </cfif>
                       
            <cfreturn myArray>
        </cfif> 
        <cfreturn myXML>
           
    </cffunction>

</cfcomponent>

