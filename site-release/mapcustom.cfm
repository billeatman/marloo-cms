<!--- put custom cfm/html files in here always use paths relative to the site root --->

<cfif NOT isDefined('site_config')>
	<cfabort>
</cfif>

<!--- 
change freq: never, yearly, monthly, weekly, daily
--->

<cfoutput>
<!--- Homepage --->
<url>
	<loc>#siteroot##basepath#</loc>
	<lastmod>#dateFormat(now(), "yyyy-mm-dd")#</lastmod>
	<changefreq>daily</changefreq>
	<priority>0.9</priority>
</url>
<!---
<!--- Search Results --->
<url>
	<loc>#siteroot##basepath#searchresults.cfm</loc>
	<lastmod>#dateFormat(now(), "yyyy-01-01")#</lastmod>
	<changefreq>never</changefreq>
	<priority>0.5</priority>
</url>
--->
<!--- static path --->
<url>
	<loc>#siteroot##basepath#staticpath/</loc>
	<lastmod>#dateFormat(now(), "yyyy-mm-dd")#</lastmod>
	<changefreq>daily</changefreq>
	<priority>0.8</priority>
</url>
</cfoutput>
