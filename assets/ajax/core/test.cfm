    <!--- create the page helper --->
    <cfset variables.ph = createObject("component", "marloo.core.pageHelper").init(
        datasource: application.datasource, 
        useRedirectTable: false, 
        URLRewriter: true,
        site_config: application.site_config
    )>
    
    <!--- create the page helper --->
    <cfset variables.phtable = createObject("component", "marloo.core.pageHelper").init(
        datasource: application.datasource, 
        useRedirectTable: true, 
        URLRewriter: true,
        site_config: application.site_config
    )>

    <cfset pageURLTable = phtable.pageIdToURL(page_id: 0)>
    <cfset pageURL = ph.pageIdToURL(page_id: 0)>

    <cfdump var="#variables#">
