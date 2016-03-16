<!--- 
cacheCore.cfc - Handles caching of non-objects 
Author: William eatman 
--->

<cfcomponent displayname="cacheCore" hint="Caching of binary data and strings" output="false">
	
    <cfset variables = {
        datasource = "",
        site_config = "",
        useCache = false,
        useDBCache = true
    }>

    <cffunction name="init" hint="Constructor" access="public" returntype="cacheCore">
    	<cfargument name="datasource" hint="Datasource for the cache tables" type="string" required="false">
        <cfargument name="site_config" hint="site_config" type="any" required="false" default="">
        <cfset setDatasource(datasource: arguments.datasource)>
        <cfset variables.site_config = arguments.site_config>

        <cfif isStruct(variables.site_config)>
            <cfset variables.useCache = variables.site_config.useCache>    
            <cfset variables.useDBCache = variables.site_config.useCache>    
        <cfelse>
            <cfset variables.useCache = false>
            <cfset variables.useDBCache = true>
        </cfif>

        <cfreturn this>
    </cffunction>
    
    <cffunction name="setDatasource" hint="Sets the datasource for the cache tables" access="public" returntype="void">
    	<cfargument name="datasource" hint="Datasource for the cache tables" type="string">
        <cfset variables.datasource = arguments.datasource>    
    </cffunction>
    
    <cffunction name="insertHash" hint="Insert data in the hash table" access="public" output="false" returntype="boolean">
    	<cfargument name="hash" hint="Generated hash MD5" required="true" type="string">
        <cfargument name="id" hint="Numeric Identifier" required="true" type="numeric">
        <cfargument name="caller" hint="Caller" required="true" type="string">
        <cfargument name="cacheData" hint="Data to be cached (string or binary)" required="true" type="any">
        
        <cfset var isString = 'F'>
		
        <!--- Base64 encode strings --->
		<cfif NOT isBinary(arguments.cacheData)>
			<cfset arguments.cacheData = toBase64(arguments.cacheData)>	
			<cfset isString = 'T'>
		</cfif>
		
        <!--- delete any old hash (We don't want duplicates!) --->
        <cfquery datasource="#variables.datasource#">
        	delete from mrl_dataCache where
            id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
            and hash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hash#">
            and caller = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.caller#">
        </cfquery>
        
        <!--- Insert the new hash --->
        <cfquery datasource="#variables.datasource#">
            insert into mrl_dataCache(hash, id, dateTime, cacheData, caller, isString)
            values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hash#">
                , <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                , <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                , <cfqueryparam cfsqltype="cf_sql_blob" value="#toBinary(arguments.cacheData)#">
                , <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.caller#">
				, <cfqueryparam cfsqltype="cf_sql_varchar" value="#isString#">
            )  
        </cfquery>

        <cfif variables.useCache EQ true>
            <cfset local.data = {
                cacheData = toBinary(arguments.cacheData),
                isString = isString
            }>
            <cfset cachePut ("#variables.datasource#-#arguments.caller#-#arguments.id#-#arguments.hash#", local.data, CreateTimeSpan(1, 0, 0, 0))>
        </cfif>
        
        <cfreturn true>
    </cffunction>

    <cffunction name="getCacheDate" hint="Check for hash and return date" access="public" returntype="any">
        <cfargument name="hash" hint="Generated hash MD5" required="true" type="string">
        <cfargument name="id" hint="Numeric identifier" required="true" type="numeric">
        <cfargument name="caller" hint="Caller" required="true" type="string">
        <cfset var qDate = "">

        <cfquery datasource="#variables.datasource#" name="qDate">
            select top 1 dateTime from mrl_dataCache
            where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#"> 
            and hash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hash#">
            and caller = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.caller#">
        </cfquery>       

        <cfif qDate.recordCount EQ 1>
            <cfreturn qDate.dateTime>
        </cfif>

        <cfreturn false>
    </cffunction>

    <cffunction name="checkHash" hint="Check for hash" access="public" returntype="any">
    	<cfargument name="hash" hint="Generated hash MD5" required="true" type="string">
        <cfargument name="id" hint="Numeric identifier" required="true" type="numeric">
        <cfargument name="caller" hint="Caller" required="true" type="string">
        <cfset var myHash = "">
		<cfset var cacheData = structNew()>

        <cfset cacheData.found = false>

        <cfif variables.useCache EQ true>
            <cfset local.cache = cacheGet ("#variables.datasource#-#arguments.caller#-#arguments.id#-#arguments.hash#")>            
            <cfif NOT isNull(local.cache)>
                <cfset cacheData.found = true>
                <cfset cacheData.type = "cache">
            </cfif>
        </cfif>

        <cfif cacheData.found NEQ true>           
            <cfquery datasource="#variables.datasource#" name="myHash">
            	select top 1 cacheData, isString from mrl_dataCache
                where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#"> 
                and hash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hash#">
                and caller = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.caller#">
            </cfquery>       
            
            <cfif myHash.getRowCount() eq 1>
                <cfset cacheData.found = true>
                <cfset cacheData.type = "db">
         
                <!--- add back to cache --->
                <cfif variables.useCache EQ true>
                    <cfset local.data = {
                        cacheData = myHash.cacheData,
                        isString = myHash.isString
                    }>
                    <cfset cachePut ("#variables.datasource#-#arguments.caller#-#arguments.id#-#arguments.hash#", local.data, CreateTimeSpan(1, 0, 0, 0))>
                </cfif>

            </cfif>
        </cfif>

        <cfif cacheData.found EQ true>
            <cfif cacheData.type EQ "db">
                <cfif myHash.isString eq "T">
                    <cfreturn toString(myHash.cacheData)> 
                <cfelse>
                    <cfreturn toBase64(myHash.cacheData)>
                </cfif>
            <cfelse>
                <cfif local.cache.isString eq "T">
                    <cfreturn toString(local.cache.cacheData)> 
                <cfelse>
                    <cfreturn toBase64(local.cache.cacheData)>                            
                </cfif>
            </cfif>
        </cfif>

        <cfreturn false>
    </cffunction>	

	<cffunction name="clearCacheByDate" hint="Clears cache older than passed date" access="public" returntype="boolean">
    	<cfargument name="Date" hint="Date/time object" required="true" type="date">
        <cfquery datasource="#variables.datasource#">
        	delete from mrl_dataCache where dateTime > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date#">
        </cfquery> 
        <cfreturn true>
    </cffunction>

	<cffunction name="clearCacheAll" hint="Clears all cache" access="public" returntype="boolean">
    	<cfquery datasource="#variables.datasource#">
        	delete from mrl_dataCache
        </cfquery>
    	<cfreturn true>
    </cffunction> 

	<cffunction name="clearCacheById" hint="Clears cache by numeric identifier" access="public" returntype="boolean">
    	<cfargument name="id" hint="Numeric identifier" required="true" type="numeric"> 
        <cfquery datasource="#variables.datasource#">
        	delete from mrl_dataCache where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.pageId#">
        </cfquery>
        <cfreturn true>
    </cffunction>
    
	<cffunction name="clearCacheByCaller" hint="Clears cache by caller" access="public" returntype="boolean">
    	<cfargument name="caller" hint="Caller identifier" required="true" type="string"> 
        <cfquery datasource="#variables.datasource#">
        	delete from mrl_dataCache where caller = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.caller#">
        </cfquery>
        <cfreturn true>
    </cffunction>
    
    
</cfcomponent>