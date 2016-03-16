<cfcomponent extends="reports">


<!--- pseudo-constructor --->
<cffunction name="init" returntype="any" access="public" output="false">
  <!--- create dummy page object --->
  <cfset var page_object = createObject("component", "marloo.core.pageStatic")>

  <!--- Overrides for static page head --->
  <cfset page_object.setPageTitle('Site Health')>
  <cfset page_object.setTextDescription('')>   

  <!--- SSL don't care - use whatever the site is already using --->
  <cfset page_object.isSSL(cgi.server_port_secure)>

  <cfset super.init(argumentCollection=arguments, page: page_object, CMS_auth: 'toplevel')>

  <!--- set the timeout high --->
  <cfsetting requesttimeout="2000000">

  <!--- get the sitemap --->
  <cfset document_base_url = Mid(application.web.groups, 1, findnocase('/sitefiles', application.web.groups))>
  
  <cfif NOT lcase(left(document_base_url, 4)) EQ 'http'>
    <cfset document_base_url = "http:" & document_base_url>
  </cfif> 

  <cfset sitemap_path = document_base_url & "map.cfc?method=getSitemapXML">

  <cfhttp url="#sitemap_path#" method="get" result="sitemap_xml">

  <cfset page_array = xmlparse(sitemap_xml.filecontent).urlset.xmlChildren>

  <!--- arrays of pages --->
  <cfset pages_slow = arraynew(1)>
  <cfset pages_redirects = arraynew(1)>
  <cfset pages_broken = arraynew(1)>
  <cfset pages_all = arraynew(1)>
  <cfset pages_good = arraynew(1)>

  <cfloop array="#page_array#" index="i">
    <cfset t1 = getTickCount()>
      <cfhttp url="#i.loc.XmlText#" method="get" result="page_response" redirect="false">
    <cfset t2 = getTickCount()>

    <cfset mypage = structNew()>

    <!--- Check for redirects 301,302, or 304 --->
    <cftry>      
    <cfif page_response.responseheader.status_code EQ 301 or page_response.responseheader.status_code EQ 302 OR page_response.responseheader.status_code EQ 304>
      <cfset mypage.redirect = true>
      <cfset mypage.location = page_response.responseHeader.location>
      <cfset t1 = getTickCount()>
        <cfhttp url="#i.loc.XmlText#" method="get" result="page_response" redirect="true">
      <cfset t2 = getTickCount()>
    <cfelse>
      <cfset mypage.redirect = false>
    </cfif>

    <cfset mypage.url = i.loc.XmlText>
    <cfset mypage.status_code = page_response.responseHeader.status_code>
    <cfset mypage.time = t2 - t1>

    <cfset arrayAppend(pages_all, mypage)>
    <cfset page_good = true>
    
    <cfif mypage.time gt 150 and mypage.redirect eq false>
        <cfset arrayAppend(pages_slow, mypage)>
        <cfset page_good = false>
    </cfif>

    <cfif mypage.status_code neq 200>
        <cfset arrayAppend(pages_broken, mypage)>
        <cfset page_good = false>
    </cfif>

    <cfif mypage.redirect eq true>
        <cfset arrayAppend(pages_redirects, mypage)>
    </cfif>

    <cfif page_good EQ true>
        <cfset arrayAppend(pages_good, mypage)>
    </cfif>
    <cfcatch>
    </cfcatch>
    </cftry>

  </cfloop>

  <cfreturn this>
</cffunction>

<cffunction name="RenderContent" access="public" output="true">

<strong>Number Of Pages: <cfoutput>#ArrayLen(pages_all)#</cfoutput></strong><br /><br />

<div style="float: right;">
<cfchart
         format="png"
         scalefrom="0"
         scaleto="#arraylen(pages_all)#"
         pieslicestyle="sliced">
  <cfchartseries
               type="pie"
               serieslabel="Site Pages"
               seriescolor="blue">
    <cfchartdata item="Broken" value="#arrayLen(pages_broken)#">
    <cfchartdata item="Slow" value="#arrayLen(pages_slow)#">
    <cfchartdata item="Redirects" value="#arrayLen(pages_redirects)#">
    <cfchartdata item="Healthy" value="#arrayLen(pages_good)#">
  </cfchartseries>
</cfchart>
</div>

<cfif arrayLen(pages_broken) NEQ 0>
<h2>Broken Pages - #arrayLen(pages_broken)#</h2>
<cfloop array="#pages_broken#" index="p">
   <span style="background: red; color: white;"><cfoutput>#p.url# - #p.time#ms</cfoutput> - <cfoutput>#p.status_code#</cfoutput></span><br />
</cfloop>
</cfif>

<cfif arrayLen(pages_slow) NEQ 0>
<h2>Slow Pages - #arrayLen(pages_slow)#</h2>
<cfloop array="#pages_slow#" index="p">
   <span style="background: yellow;"><cfoutput>#p.url# - #p.time#ms</cfoutput></span><br> 
</cfloop>
</cfif>

<cfif arrayLen(pages_redirects) NEQ 0> 
<h2>Redirect Pages - #arrayLen(pages_redirects)#</h2>
<cfloop array="#pages_redirects#" index="p">
   <cfoutput>#p.url# --> #p.location#</cfoutput><br> 
</cfloop>
</cfif>

<cfif arrayLen(Pages_good) NEQ 0>
<h2>Healthy Pages - #arrayLen(pages_good)#</h2>
<cfloop array="#pages_good#" index="p">
   <cfoutput>#p.url# - #p.time#ms</cfoutput><br> 
</cfloop>
</cfif>

<cfreturn>

</cffunction>

</cfcomponent>
