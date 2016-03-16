<!--- get the referer var --->
<cfset session.referer = cgi.http_referer>
<cfset session.query_string = cgi.query_string>
<cfset session.reviewState = ''>

<!--- find and check the page_ID
finding an ID means that a page needs review from an email --->
<cfset findPage = find('#application.idvar#=', session.referer)>
<cfif findPage neq 0>
	<cfset reviewPage = mid(session.referer, findPage + 8, len(session.referer))>
	<cfif isNumeric(reviewPage)>
    	<cfset session.reviewPage = reviewPage>
    </cfif>

    <cfif find('state', session.referer) neq 0>
    	<cfset session.reviewState = 'pending'>
    </cfif>
</cfif>

<!--- also check the query string.  If the user is already logged in, this is where the page_id will be --->
<cfset findPage = find('#application.idvar#=', session.query_string)>
<cfif findPage neq 0>
	<cfset reviewPage = mid(session.query_string, findPage + 8, len(session.query_string))>
	<cfif isNumeric(reviewPage)>
    	<cfset session.reviewPage = reviewPage>
    </cfif>
    
    <cfif find('state', session.query_string) neq 0>
    	<cfset session.reviewState = 'pending'>
    </cfif>
</cfif>

<HEAD>
<SCRIPT language="JavaScript">
   window.location="main.cfm";
</SCRIPT>
</HEAD>


