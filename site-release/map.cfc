<cfcomponent>

<!--- returns an XML sitemap --->
<cffunction name="getSitemapXML" access="remote" output="false" returntype="any" returnFormat="plain"> 
    <cfheader name="Content-Type" value="application/xml">
    
    <!--- get the config for the site --->
    <cfinvoke component="siteConfig" method="getConfig" returnvariable="site_config" />
    
    <cfinvoke component="marloo.core.pageHelper" method="getBasePath" returnvariable="basepath" />
    
    <cfset siteroot = lcase("http://#cgi.HTTP_HOST#")>
    <cfset pagename = "page.cfm">
    <cfset idvar = "page_ID">
    
    <cfquery datasource="#site_config.datasource#" name="qPages">
    select ApprovedDate, ID, SSL from mrl_sitePublic
    </cfquery>
    
    <cfset cacheKey = "CMS-#siteroot#-sitemap#site_config.URLrewriter##site_config.cms.ssl#">
    <cfset sitemap = cacheGet(cacheKey)>
    <cfif isNull(sitemap) OR site_config.useCache NEQ true>
    
        <cfset sitemap = structNew()>
    
        <cfxml variable="sitemap" casesensitive="false">
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        
        <cfinclude template="mapcustom.cfm">
        
        <cfloop query="qPages">
        
            <cfif ucase(qPages.SSL) EQ 'T' AND site_config.cms.ssl EQ true>
                <cfset siteroot = lcase("https://#cgi.HTTP_HOST#")>
            <cfelse>
                <cfset siteroot = lcase("http://#cgi.HTTP_HOST#")>
            </cfif>
            
            <cfset pageAtt = structnew()>
        
            <cfif site_config.URLrewriter EQ true>
                <!--- SEO rewritter logic --->
                <cfinvoke component="marloo.core.pageHelper" method="pageIdToURL" returnvariable="urlPath">
                    <cfinvokeargument name="page_id" value="#qPages.id#">
                    <cfinvokeargument name="datasource" value="#site_config.datasource#"> 
                    <cfinvokeargument name="URLrewriter" value="#site_config.URLrewriter#">   
                    <cfinvokeargument name="site_config" value="#site_config#">
                </cfinvoke>
                
                <cfif isNumeric(urlPath)>
                    <cfset pageAtt.loc = lcase("#siteroot##basepath##pagename#?#idvar#=#qPages.id#")>
                <cfelse>
                    <cfset pageAtt.loc = lcase("#siteroot#/#urlPath#")>
                </cfif>
            <cfelse>
                <!--- loc --->
                <cfset pageAtt.loc = lcase("#siteroot##basepath##pagename#?#idvar#=#qPages.id#")>
            </cfif>

            <!--- lastmod --->
            <cfset pageAtt.lastmod = lcase("#dateFormat(qPages.approvedDate, 'yyyy-mm-dd')#")>
            <!--- priority --->
            <cfset pageAtt.priority = lcase("0.5")>

            <!--- if the current id is also the root --->
            <cfif qPages.id EQ site_config.cms.tree.rootid>
                <cfset pageAtt.loc = lcase("#site_config.cms.web.siteroot#")>
                <cfset pageAtt.priority = lcase("0.9")>
            </cfif>

            
            <cfquery datasource="#site_config.datasource#" name="qHistory">
                select count(*) as count from mrl_pageState where [action] = 'approved' and [id] = '#qPages.id#' and actionDate > <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd('yyyy', -1, now())#">
            </cfquery>
            
            <cfset freq = 'yearly'>
            
            <cfif qHistory.count gt 50>
                <cfset freq = 'daily'>
            <cfelseif qHistory.count gt 12>
                <cfset freq = 'weekly'>
            <cfelseif qHistory.count gt 1>
                <cfset freq = 'monthly'>
            </cfif>
            
            <!--- changefreq --->
            <cfset pageAtt.changefreq = freq>
            
        <cfoutput>
        <url>
            <loc>#xmlFormat(pageAtt.loc)#</loc>
            <lastmod>#xmlFormat(pageAtt.lastmod)#</lastmod>
            <changefreq>#xmlFormat(pageAtt.changefreq)#</changefreq>
            <priority>#xmlFormat(pageAtt.priority)#</priority>
        </url>
        </cfoutput>
        
        </cfloop>
            
        </urlset>
        </cfxml>

        <cfset siteroot = lcase("http://#cgi.HTTP_HOST#")>
<!---     http://neilkilbride.blogspot.com/2008/04/removing-xmldocument-white-space-c.html --->
        <cfset sitemap = lcase(reReplace(toString(sitemap), ">\s*<", "><", 'all'))>
        <cfset cachePut(cacheKey, sitemap, '.5')>
    <cfelse>
    </cfif>
        
    <cfreturn toString(sitemap)>
</cffunction>

</cfcomponent>