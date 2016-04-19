<!--- All methods in this helper will be available in all handlers, views & layouts --->

<!--- Thanks Ben! - http://www.bennadel.com/blog/2501-Converting-ColdFusion-Date-Time-Values-Into-ISO-8601-Time-Strings.htm --->
<cffunction name="ToISO8601" access="private" returntype="string">
	<cfargument name="date" type="date" required="false">  
	<cfargument name="convertToUTC" type="boolean" required="false" default="false">

	<!--- return a blank string if a null is passed --->
	<cfif NOT isDefined("arguments.date")>
		<cfreturn "">
	</cfif>

	<cfset local.date = arguments.date>

	<cfif arguments.convertToUTC>
		<cfset local.date = dateConvert("local2utc", local.date)>
	</cfif>

	<cfset local.date = dateFormat( date, "yyyy-mm-dd" ) & "T" & timeFormat( date, "HH:mm:ss" )>

    <cfif arguments.convertToUTC>
        <cfset local.date = local.date & "Z">
    </cfif>

    <!---
    https://developers.google.com/google-apps/calendar/concepts

    2011-06-03T10:00:00 — no milliseconds and no offset.
    2011-06-03T10:00:00.000 — no offset.
    2011-06-03T10:00:00-07:00 — no milliseconds with a numerical offset.
    2011-06-03T10:00:00Z — no milliseconds with an offset set to 00:00.
    2011-06-03T10:00:00.000-07:00 — with milliseconds and a numerical offset.
    2011-06-03T10:00:00.000Z — with milliseconds and an offset set to 00:00.
    --->

	<cfreturn local.date>
</cffunction>