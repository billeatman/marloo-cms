<cfcomponent displayname="calendar" extends="marloo.widget">
   <!--- properties --->
   <cfset variables.calwebroot = 'http://www.example.com/'>

   <cfset variables.qEvents = "">	

   <cffunction name="init" returntype="any" access="public" output="false">
<!---	  <cfset variables.qEvents = getEvents()> --->
	  <cfset super.init(argumentCollection=arguments)>
    <cfreturn this />
   </cffunction>

<cffunction name="renderEventList" returntype="any" access="public" output="true">
<cfargument name="numberOfEvents" type="numeric" required="false" default="4">
<cfargument name="category" type="string" required="false" default="">
<cfargument name="type" type="numeric" required="false" default="1">
<cfsilent>

<cfset var events = "">
<cfset var mydate = "">
<cfset var e = "">

<cfhttp method="get" url="http://www.example.com/calservice/calservice.cfc?method=getEvents&limit=#arguments.numberOfEvents#&nearestDay=false&featured=true&expandspans=false" result="jevents">

<div id="moreevents"><a href="calendar/">More Events ></a> </div>
</div>
</cffunction>

</cfcomponent>
	



