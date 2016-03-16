<cfparam name="id" default="">
<cfparam name="title" default="">
<cfparam name="info" default="">
<cfparam name="securityGroup" default="">
<cfparam name="resultpage" default="1" type="integer">

<!--- copy the URL and FORM scope to the variables scope --->
<cfset StructAppend(variables, form, false)>
<cfset StructAppend(variables, url, false)>

<!--- <cftry> --->
<cfinvoke argumentcollection="#variables#" component="assets.ajax.search" method="getPageCount" returnvariable="queryTotalCount">
<cfinvoke argumentcollection="#variables#" component="assets.ajax.search" method="getPages" returnvariable="qPages">
<!--- <cfcatch>
<cflocation url="search.cfm">
</cfcatch>
</cftry> --->


<html>
<head>
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">

<title>Search Results</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link href="assets/style/search.css?asdf=3" rel="stylesheet" type="text/css">
</head>
<body>
	<img src="assets/images/background1.jpg" alt="background image" id="bg" />
	<div id="whiteresults2"> 
	</div> 
    
    <div class="summary"><cfoutput>
      <h5>#queryTotalCount.TotalCount# #application.pagedesc#<cfif queryTotalCount.TotalCount gt 1>s
        </cfif> 
        found</h5>
    </cfoutput>
    <!--- If we are not on the first page, display the Previous button --->  
	<cfif queryTotalCount.TotalCount gt 25>
	   <div id="pages">
	   <cfif resultPage gt 1> <!--- Previous button --->
    	   <cfoutput><a href="results.cfm?id=#id#&title=#URLencodedformat(title)#&securityGroup=#URLencodedformat(securityGroup)#&info=#urlencodedformat(info)#&resultPage=#resultPage - 1#" name="Previous Button"><img alt="Previous" style="border:none;" src="assets/images/arrows-l1.png"></a></cfoutput>
	   </cfif>              
       <span style="vertical-align:top;">
       <cfloop index = "i" from = "1" to = "#ceiling(queryTotalCount.TotalCount / 25)#">
		   <cfif i eq resultPage>  <!--- dont give a link to the result page we are currently on --->
           		<cfoutput><strong>#i#</strong></cfoutput>&nbsp;
	       <cfelse>
           		<cfoutput><a style="color:blue" href="results.cfm?id=#id#&title=#URLencodedformat(title)#&securityGroup=#URLencodedformat(securityGroup)#&info=#urlencodedformat(info)#&resultPage=#i#">#i#</a></cfoutput>&nbsp;
           </cfif>
       </cfloop>
       </span>
       <!--- If we are not on the last page, display the Next button --->
       <cfif resultPage lt ceiling(queryTotalCount.TotalCount / 25)>  <!--- Next button --->
    	   <cfoutput><a href="results.cfm?id=#id#&title=#URLencodedformat(title)#&securityGroup=#URLencodedformat(securityGroup)#&info=#urlencodedformat(info)#&resultPage=#resultPage + 1#" name="Next Button"><img alt="Next" src="assets/images/arrows-r1.png"></a></cfoutput>
	   </cfif>
       </div>
    </cfif>
    </div>

	<div id="results" style="overflow: auto;">
		<cfinvoke component="assets.ajax.search" method="displayQuery">
			<cfinvokeargument name="qPages" value="#qPages#">
		</cfinvoke>
	</div>

</body>
</html>
