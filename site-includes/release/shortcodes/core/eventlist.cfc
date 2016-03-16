<cfcomponent extends="marloo.shortcode">

<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="category" required="false" default="">
	<cfargument name="limit" required="false" default="4">
	<cfargument name="keywords" required="false" default="">
	<cfargument name="filter" required="false" default="">
	<cfargument name="featured" required="false" default="true" type="boolean">

	<cfset local.keywords = arguments.keywords>
	<cfif arguments.filter NEQ "">
		<cfset local.keywords = arguments.filter>
	</cfif>

	<cfset var content = "">

	<cfset local.featured = arguments.featured>

	<cfif local.keywords NEQ "" AND arguments.featured EQ true>
		<cfset local.featured = false>
	</cfif>

	<cfif arguments.category NEQ "" AND arguments.featured EQ true>
		<cfset local.featured = false>
	</cfif>

    <cfsavecontent variable="content">
	<cfset renderEventListAdmissions(keywords: local.keywords, category: arguments.category, numberofevents: arguments.limit, featured: local.featured)>
    </cfsavecontent>

    <cfreturn content>
</cffunction>

<cffunction name="renderEventList" returntype="any" access="private" output="true">
	<cfargument name="numberOfEvents" type="numeric" required="false" default="4">
	<cfargument name="CalCategory" type="string" required="false" default="">
	<cfset var events = "">

	<cfhttp method="get" url="http://www.example.com/calservice/calservice.cfc?method=getEvents&limit=#arguments.numberOfEvents#&nearestDay=false&featured=true&expandspans=false" result="jevents">
	<cfif isJSON(jevents.filecontent)>
		<cfset events = deserializeJSON(jevents.filecontent)>
	</cfif>

	<div id="calendarContent">          
	<cfif isArray(events)>
	  <CFLOOP array="#events#" index="e">
	    <cfset mydate = createDate(e.year, e.month, e.day)>
	    <div class="calendardatecontainer" style="display: inline; float: right;"><a href="page.cfm?page_id=2258&CalID=#e.calid#">
	      <div class="calendarmonth" align="center">#DateFormat(mydate, "mmm")#<br />
	      </div>
	      <div class="calendardate" align="center">#DateFormat(mydate, "dd")#<br />
	      </div>
	      </a> </div>
	    <div class="eventcontatiner">
	      <div class="eventTitle" align="left"><a href="page.cfm?page_id=2258&CalID=#e.calid#">#e.description#</a></div>
	        <div class="eventTime">#e.time#</div>
	    </div>
	    </CFLOOP>            
	</cfif>
	<div id="moreevents"><a href="calendar/">More Events ></a> </div>
	</div>
</cffunction>


</cfcomponent>