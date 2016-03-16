<cfsilent>
<cfif thisTag.executionMode EQ "start">
	<cfset runtimeExists = structKeyExists(server, "cfgroovy") />
	<cfif NOT structKeyExists(attributes, "action")
			OR listFindNoCase("clearCache,getCacheInfo", attributes.action) EQ 0>
		<cfthrow type="IllegalAttributeSetException"
			message="You must provide an 'action' attribute.  Valid values are clearCache, getCacheInfo." />
	</cfif>
	<cfif attributes.action EQ "clearCache">
		<cfif runtimeExists>
			<cfset server.cfgroovy["scriptCache"].clear() />
		</cfif>
	<cfelseif attributes.action EQ "getCacheInfo">
		<cfif NOT structKeyExists(attributes, "result")>
			<cfthrow type="IllegalAttributeSetException"
				message="You must provide a 'result' attribute when you use the 'getCacheInfo' action." />
		</cfif>
		<cfset info = structNew() />
		<cfif runtimeExists>
			<cfset info["usingEhcache"] = false />
			<cfset info["cacheSize"] = server.cfgroovy["scriptCache"].size() />
		<cfelse>
			<cfset info["usingEhcache"] = "unknown" />
			<cfset info["cacheSize"] = 0 />
		</cfif>
		<cfset caller[attributes.result] = info />
	<cfelse>
		<cfthrow type="BarneyIsAJackassException"
			message="Barney failed, and his code allows you to reach this point."
			detail="The attribute validation above should prevent this code from ever executing, but Barney screwed something up and things are inconsistent." />
	</cfif>
<cfelse><!--- end tag --->
</cfif>
</cfsilent>