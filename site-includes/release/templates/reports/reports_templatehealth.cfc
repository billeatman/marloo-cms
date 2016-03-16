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

  <cfquery name="qPages" datasource="#application.datasource#">
  select id, template from mrl_sitePublic
  order by template
  </cfquery>

  <cfquery name="qTemplates" datasource="#application.datasource#">
  select template, count(id) as [pagecount] from mrl_sitePublic
group by template
  </cfquery>


  <cfreturn this>
</cffunction>

<cffunction name="RenderContent" access="public" output="true">

<strong>Number Of Pages: <cfoutput>#qPages.getRecordCount()#</cfoutput></strong><br /><br />


<div style="float: right;">
<cfchart
         chartHeight="600"
         chartWidth="800"
         format="png"
         scalefrom="0"
         <!--- scaleto="#arraylen(pages_all)#" --->           
         pieslicestyle="sliced">
  <cfchartseries
               type="pie"
               serieslabel="Site Pages"
               seriescolor="blue">
    <cfloop query="qtemplates">
    <cfchartdata item="#qtemplates.template#" value="#qtemplates.pagecount#">
    </cfloop>

  </cfchartseries>
</cfchart>
</div>

<cfreturn>


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
