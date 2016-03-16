<cfquery datasource="#application.datasource#" name="qActiveUsers">
select *, datediff(minute, lastAction, getdate()) as inactiveTime from mrl_userActivityLog
where datediff(minute, lastAction, getdate()) < 60
order by inactiveTime asc
</cfquery>

<h2>Active Users</h2>
<cfoutput query="qActiveUsers">
#inactiveTime#, #mail#<br />
</cfoutput>
