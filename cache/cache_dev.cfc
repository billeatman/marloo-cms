<!--- 
caching of non-objects 
Author: William eatman 
--->
<cfcomponent displayname="cacheCore" hint="Caching of binary data and strings." output="false">

<cfset variables.cacheMiss = false>

<cffunction name="getCaller" access="private" returntype="struct" output="false" hint="gets the caller from the Java stacktrace." >
    <!--- ok, so this function digs through the stack trace.  This may break between major CF versions and is a HACK --->
	
    <cfset LOCAL.caller = structNew()>
    <cfif arrayLen(LOCAL.stacktraceArray) GTE 1>
    	<cfset LOCAL.caller.funcName = getToken(LOCAL.stacktraceArray[1], 2, ".") />
    	<cfset LOCAL.caller.cfcName = getToken(LOCAL.stacktraceArray[1], 1, ".") />
   	<cfelse>
    	<cfset LOCAL.caller.funcName = "" />
    	<cfset LOCAL.caller.cfcName = "" />
    </cfif>

    <cfreturn LOCAL.caller>
 
</cffunction> 
	
<cffunction name="init" hint="Constructor" access="public" returntype="cacheCoreExtreme">
   	<cfargument name="datasource" hint="Datasource for the cache tables" type="string">
    <cfargument name="idHistory" type="numeric" required="true">

    <cfset setDatasource(datasource: arguments.datasource)>
        
    <!--- create the dep stack --->
  	<cfset variables.cache = structNew()>
    <cfset variables.depStack = arrayNew(1)>

    <cfset variables.idHistory = arguments.idHistory>
    <cfset loadCache()>
        
    <cfreturn this>
</cffunction>
    
<cffunction name="setDatasource" hint="Sets the datasource for the cache tables" access="public" returntype="void">
  	<cfargument name="datasource" hint="Datasource for the cache tables" type="string">
    <cfset variables.datasource = arguments.datasource>    
</cffunction>
    
<cffunction name="registerDependency" access="public" returntype="void" output="false" description="Registers a page dependency.">
  	<cfargument name="cacheBag" required="true" type="struct" hint="cacheBag">
	<cfargument name="dep" type="string" required="true">
    <cfargument name="type" type="string" required="true">
        
    <cfset var depStruct = structNew()>
    <cfset depStruct.dep = arguments.dep>
    <cfset depStruct.type = arguments.type>
        
    <cfset arrayAppend(variables.depstack[cacheBag.callerId].depList, depStruct)>
</cffunction>
    
<cffunction name="dataToBin" access="private" returntype="struct" hint="Converts a variables to binary to database storage."> 
  	<cfargument name="data" required="true" type="any" hint="Non complex object to convert to binary data">
		
    <cfset var LOCAL = structNew()>
    <cfset LOCAL.ret = structNew()>
        
	<cfif NOT isBinary(arguments.data)>
    	<cfif isArray(arguments.data) OR isStruct(arguments.data)>    
        	<cfset LOCAL.ret.data = serializeJSON(arguments.data)>
            <cfset LOCAL.ret.type = "json">
		<cfelseif isXML(arguments.data)>
           	<cfset LOCAL.ret.data = toString(arguments.data)>
            <cfset LOCAL.ret.type = "xml">
		<cfelseif isNumeric(arguments.data)>
			<cfset LOCAL.ret.data = toString(arguments.data)>
       		<cfset LOCAL.ret.type = "numeric">				
		<cfelse>
			<cfset LOCAL.ret.data = arguments.data>
       		<cfset LOCAL.ret.type = "string">
       	</cfif>
		
        <cfset LOCAL.ret.data = toBase64(LOCAL.ret.data)>        
        <cfset LOCAL.ret.data = toBinary(LOCAL.ret.data)>
	<cfelse>
        <cfset LOCAL.ret.type = "bin">
	    <cfset LOCAL.ret.data = arguments.data>	
    </cfif> 
    	
    <cfreturn LOCAL.ret>
</cffunction>
    
<cffunction name="binToData" access="private" returntype="any" hint="Converts bin data from SQL into a variable.">
   	<cfargument name="bin" required="true" type="binary" hint="binary data">
    <cfargument name="type" required="true" type="string" hint="type so we know how to convert: string, xml, json, bin">
        
    <cfset var LOCAL = structNew()>
        
    <cfswitch expression="#arguments.type#">
	   	<cfcase value="string">
          	<cfset LOCAL.myVar = toString(arguments.bin)>
        </cfcase>
        <cfcase value="xml">
           	<cfset LOCAL.myVar = toString(arguments.bin)>
            <cfset LOCAL.myVar = XMLParse(LOCAL.myVar)>
        </cfcase>
    	<cfcase value="json">
           	<cfset LOCAL.myVar = toString(arguments.bin)>
            <cfset LOCAL.myVar = deserializeJSON(LOCAL.myVar)>            	
        </cfcase>
        <cfcase value="numeric">
           	<cfset LOCAL.myVar = trim(toString(arguments.bin))>
        </cfcase>
        <cfdefaultcase>
           	<cfset LOCAL.myVar = arguments.bin>
        </cfdefaultcase>
  	</cfswitch>
        
    <cfreturn LOCAL.myVar>
</cffunction>
	
<cffunction name="insertHash" hint="Insert data in the hash table" access="public" returntype="boolean" output="true">
	<cfargument name="cacheBag" required="true" type="struct" hint="cacheBag" >
    <cfargument name="data" required="true" type="any" hint="Data to be cached (string or binary)" >
    <cfargument name="hashDependent" required="false" type="boolean" hint="cache is based entirely on the hash key" default="false">

	<cfset var LOCAL = structNew()>
	
	<cfset LOCAL.success = true>

	<cfset LOCAL.binData = dataToBin(arguments.data)>
    <cfset LOCAL.caller = getCaller()>
        
    <!--- check that the caller matches the caller name in the deplist --->
	<cfif "#LOCAL.caller.cfcName#.#LOCAL.caller.funcName#" NEQ variables.depStack[arguments.cacheBag.callerId].caller>
		<cfset LOCAL.success = false>        	
    </cfif>        
        
        
    <!--- role up the dependencies --->
    <cfif LOCAL.success EQ true>
		<cfloop to="#arguments.cacheBag.callerId + 1#" from="#ArrayLen(variables.depStack)#" index="LOCAL.i" step="-1">
        	<!--- concat the arrays --->
			<cfscript>
		   		for(LOCAL.index = 1; LOCAL.index LTE ArrayLen(variables.depStack[LOCAL.i].deplist); LOCAL.index = LOCAL.index + 1) {
			  		ArrayAppend(variables.depStack[LOCAL.i - 1].deplist, variables.depStack[LOCAL.i].deplist[LOCAL.index]);
		   		}
			</cfscript>
            <cfset ArrayDeleteAt(variables.depStack, LOCAL.i)>
        </cfloop>
  	</cfif>
    
        <!--- create the cache entry --->
        <cfset variables.cache["#arguments.cacheBag.hash#"] = structNew()>
        <cfset local.c = variables.cache["#arguments.cacheBag.hash#"]>
		<cfset local.c.binData = LOCAL.binData>
        <cfset local.c.deps = variables.depStack[arguments.cacheBag.callerId]>
        <cfset local.c.hashDependent = arguments.hashDependent>
        <cfset local.c.hits = 1>
        
        <!--- change dependency on the stack to represent the hash --->
        <!--- create a new struct because we moved the old struct by ref --->
		<cfset variables.depStack[arguments.cacheBag.callerId] = structNew()>
        <cfset variables.depStack[arguments.cacheBag.callerId].caller = local.c.deps.caller>
        <cfset variables.depStack[arguments.cacheBag.callerId].deplist = arraynew(1)>
        
        <cfset arrayAppend(variables.depStack[arguments.cacheBag.callerId].deplist, structNew())>
        <cfset variables.depStack[arguments.cacheBag.callerId].deplist[1].dep = arguments.cacheBag.hash>
        <cfset variables.depStack[arguments.cacheBag.callerId].deplist[1].type = "hash">
        <cfset variables.depStack[arguments.cacheBag.callerId].deplist[1].hashDependent = arguments.hashDependent>
        
        
     
        <cfreturn true>

    </cffunction>

	<cffunction name="generateHash" returntype="string" access="private" hint="generates an md5 hash given a structure and a function name.">
    	<cfargument name="args" type="struct" hint="struct of an argument scope" required="false">
        <cfargument name="caller" type="struct" hint="caller struct returned from 'getCaller' function" required="true"> 
    
    	<cfset var LOCAL = structNew()>
        <cfset LOCAL.preHashString = "">
        
        <cfset LOCAL.argList = StructKeyList(arguments.args)>
        <cfset LOCAL.argList = listSort(LOCAL.argList, "text", "asc", ",")>
        
        <cfloop list="#LOCAL.argList#" index="LOCAL.index">
        	<!--- make sure we leave the 'cachebag' out of hash --->
			<cfif LOCAL.index NEQ "CACHE"> 
        		<cfset LOCAL.preHashString = LOCAL.preHashString & LOCAL.index & serializeJSON(arguments.args['#LOCAL.index#'])>
        	</cfif>
        </cfloop>
    
    	<cfset LOCAL.preHashString = arguments.caller.cfcName & arguments.caller.funcName & LOCAL.preHashString>
        <cfset LOCAL.hash = hash(LOCAL.preHashString, 'md5')>
    
   		<cfreturn LOCAL.hash>
    </cffunction>

    <cffunction name="checkHash" hint="Check for hash" access="public" returntype="any">
        <cfargument name="args" required="false" hint="argument scope of the caller function">
        <cfargument name="cache" required="false" default="false" hint="Set false for NEVER CACHE">
        
        <cfset var LOCAL = structNew()>        
        
        <cfset LOCAL.caller = getCaller()>
        
		<cfif arguments.cache EQ true>
        	<cfset LOCAL.hash = generateHash(args: arguments.args, caller: LOCAL.caller)>
        <cfelse>
        	<cfset LOCAL.hash = "">
        </cfif>
        
          
		<!--- check for hit --->
        <cfif StructKeyExists(variables.cache, LOCAL.hash)> 
        	<cfset LOCAL.retval = structNew()>
            <cfset LOCAL.retval.hit = true>
            <cfset LOCAL.retval.data = binToData(variables.cache["#LOCAL.hash#"].bindata.data, variables.cache["#LOCAL.hash#"].bindata.type)>  
        	<cfset variables.cache["#LOCAL.hash#"].hits = variables.cache["#LOCAL.hash#"].hits + 1> 
            <cfreturn LOCAL.retval>
        </cfif>
 
        <cfif cache EQ true>
        	<cfset variables.cacheMiss = true>
       		<!--- <cfdump var="#LOCAL#">
            <cfabort> --->
        </cfif>
        
		<cfset LOCAL.retval = structNew()>
        <cfset LOCAL.retval.hit = false>
        <cfset LOCAL.retval.hash = LOCAL.hash>
        <cfset LOCAL.cache = arguments.cache>
        
        <!--- add the caller to the depStack --->
        <cfset arrayAppend(variables.depStack, structNew())>
        <cfset variables.depStack[arrayLen(variables.depStack)].caller = LOCAL.caller.cfcName & "." & LOCAL.caller.funcName>

		<cfset LOCAL.retval.callerID = arrayLen(variables.depStack)>

		<cfset variables.depStack[arrayLen(variables.depStack)].depList = arrayNew(1)>
    
        <cfreturn LOCAL.retval>
    
			
    </cffunction>	
  
	<cffunction name="loadCache" access="public" returntype="void" output="true">
    	<cfset var LOCAL = structNew()>
        
        <cfquery datasource="#variables.datasource#" name="LOCAL.qCache">
        	Select data, type, hashDependent, hash, deps from cacheData 
			where [hash] not in (
				select [hash] from cacheDataDeps as cd
				where id_history not in (
					select idHistory as id_history from globalMaster as gm
				) and [hash] in (select [hash] from cacheDataPages as cdp1 where id_history = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.idHistory#">)
			) and [hash] in (select [hash] from cacheDataPages as cdp2 where id_history = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.idHistory#">)
        </cfquery>

        <cfloop query="LOCAL.qCache">
            <!--- create the cache entry --->
            <!--- duplicated CODE - move to private function --->
			<cfset variables.cache["#LOCAL.qCache.hash#"] = structNew()>
            <cfset local.c = variables.cache["#LOCAL.qCache.hash#"]>
            <cfset local.c.binData = structNew()>
            <cfset local.c.binData.data = LOCAL.qCache.data>
            <cfset local.c.binData.type = LOCAL.qCache.type>
            
			<cfset local.c.deps = deserializeJSON(toString(LOCAL.qCache.deps))>
            <cfset local.c.hashDependent = LOCAL.qCache.hashDependent>
            <cfset local.c.hits = 0>
        </cfloop>
 
        <!--- <cfdump var="#variables.cache#"> --->
    </cffunction>
  
  	<cffunction name="saveCache" access="public" returntype="void" output="true">
		<cfset var LOCAL = structNew()>

      	<cfif variables.cacheMiss EQ true>
			<cfset LOCAL.pageDeps = getPageDeps()>
            <cfset dependencyWalker()>
            
            <cfset LOCAL.cacheKeys = StructKeyList(variables.cache)>
            <cfset LOCAL.myList = "">
            
            <!--- ONLY FOR DEV --->  
            <cfquery datasource="#variables.datasource#">
              	DELETE FROM [cacheData]
            </cfquery>

			<!--- save hashes --->
            <cfloop list="#LOCAL.cacheKeys#" index="LOCAL.index">
                <!--- <cfset LOCAL.myList = ListAppend(LOCAL.myList, resolveHash(LOCAL.index))> --->							        	
				<cfset LOCAL.cacheItem = variables.cache["#LOCAL.index#"]>
                <cfquery datasource="#variables.datasource#">
                	INSERT INTO [cacheData]
           				([hash]
                        ,[dateTime]
           			 	,[data]
                       	,[caller]
                       	,[type]
                       	,[cfcName]
                       	,[deps]
                        ,[hashDependent]
                        )
 	                VALUES
                       	(<cfqueryparam cfsqltype="cf_sql_varchar" value="#LOCAL.index#">
                       	,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                        ,<cfqueryparam cfsqltype="cf_sql_blob" value="#LOCAL.cacheItem.bindata.data#">
                       	,<cfqueryparam cfsqltype="cf_sql_varchar" value="#getToken(LOCAL.cacheItem.deps.caller, 2, '.')#">
                       	,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LOCAL.cacheItem.bindata.type#">
                       	,<cfqueryparam cfsqltype="cf_sql_varchar" value="#getToken(LOCAL.cacheItem.deps.caller, 1, '.')#">
                       	,<cfqueryparam cfsqltype="cf_sql_blob" value="#toBinary(toBase64(serializeJSON(LOCAL.cacheItem.deps)))#">
                        ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LOCAL.cacheItem.hashDependent#">
                        )
                </cfquery>
			</cfloop>
            
            <!--- save page hashes --->
            <cfquery datasource="#variables.datasource#">
            	DELETE from cacheDataPages
                where id_history = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.idHistory#">
            </cfquery>            
            
            <cfloop list="#LOCAL.pageDeps.hashList#" index="LOCAL.index">
                <!--- <cfset LOCAL.myList = ListAppend(LOCAL.myList, resolveHash(LOCAL.index))> --->							        	
				<cfset LOCAL.cacheItem = variables.cache["#LOCAL.index#"]>
                <cfquery datasource="#variables.datasource#">
                	INSERT INTO [cacheDataPages]
           				([hash]
                        ,[id_history]
                        )
 	                VALUES
                       	(<cfqueryparam cfsqltype="cf_sql_varchar" value="#LOCAL.index#">
                       	,<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.idHistory#">
                        )
                </cfquery>
			</cfloop>

			<!--- save hash deps --->
            <cfquery datasource="#variables.datasource#">
	        	DELETE from cacheDataDeps
                where hash in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#LOCAL.cacheKeys#">)
           	</cfquery>            

            <cfloop list="#LOCAL.cacheKeys#" index="LOCAL.index">
                <!--- <cfset LOCAL.myList = ListAppend(LOCAL.myList, resolveHash(LOCAL.index))> --->							        	
				<cfset LOCAL.cacheItem = variables.cache["#LOCAL.index#"]>
                <cfif LOCAL.cacheItem.hashDependent NEQ true>
                    <cfloop list="#LOCAL.cacheItem.deps.idList#" index="LOCAL.idHistory">
                        <cfquery datasource="#variables.datasource#">
                            INSERT INTO [cacheDataDeps]
                                ([hash]
                                ,[id_history]
                                )
                            VALUES
                                (<cfqueryparam cfsqltype="cf_sql_varchar" value="#LOCAL.index#">
                                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#LOCAL.idHistory#">
                                )
                        </cfquery>
                    </cfloop>
             	</cfif>
			</cfloop>
            
        </cfif>     
           
    </cffunction>
    
    <cffunction name="dumpVars" access="public" returntype="any" output="true">
  
        <cfdump var="#getCaller()#" label="Caller Function">
        
        <cfdump var="#variables.depStack#" label="Dependency Stack">
        <cfdump var="#variables.cache#" label="Cache Data"> 
    	
    </cffunction>

	<cffunction name="dependencyWalker" access="public" output="false" hint="Builds a list of history id dependencies.">
    	<cfset var LOCAL = structNew()>
        
        <cfset LOCAL.cacheKeys = StructKeyList(variables.cache)>
		<cfset LOCAL.myList = "">
                
        <cfloop list="#LOCAL.cacheKeys#" index="LOCAL.index">
 			<cfset LOCAL.myList = ListAppend(LOCAL.myList, resolveHash(LOCAL.index))>							        	
        </cfloop>
        
        <cfset LOCAL.myList = listRemoveDuplicates(LOCAL.myList)>
    </cffunction>
    
    <cffunction name="getPageDeps" access="public" output="true" hint="Builds a list of history id dependencies.">
    	<cfset var LOCAL = structNew()>
		<cfset LOCAL.myList = "">
        <cfset LOCAL.hashlist = "">

        
        <cfloop array="#variables.depStack#" index="LOCAL.i">
        	<cfloop array="#LOCAL.i.deplist#" index="LOCAL.ii">
            	<cfif LOCAL.ii.type EQ "hash">
                	<cfif LOCAL.ii.hashDependent EQ false>
						<cfset LOCAL.myList = ListAppend(LOCAL.myList, resolveHash(LOCAL.ii.dep))>	
    				</cfif>            	
                	<cfset LOCAL.hashlist = ListAppend(LOCAL.hashlist, LOCAL.ii.dep)>
                </cfif> 
            </cfloop>
        </cfloop>        

    	
        <cfset LOCAL.retVal = structNew()>
        <cfset LOCAL.retVal.idList = listRemoveDuplicates(LOCAL.myList)>
        <cfset LOCAL.retVal.hashList = listRemoveDuplicates(LOCAL.hashlist)> 

        <cfreturn LOCAL.retVal>
    
    </cffunction>
    

	<cffunction name="resolveHash" access="private" output="false" hint="Builds a list of dependencies for a given hash.">
    	<cfargument name="hash" required="true">
        
        <cfset var LOCAL = structNew()>
        
        <cfset LOCAL.cache = variables.cache['#arguments.hash#']>
        
        <cfif isDefined("LOCAL.cache.deps.idList")>
        	<cfreturn LOCAL.cache.deps.idList>
        </cfif>
        
        <!--- create empty list --->
        <cfset LOCAL.cache.deps.idList = "">
        
        <cfloop array="#LOCAL.cache.deps.deplist#" index="LOCAL.depItem">
			<cfif LOCAL.depItem.type EQ 'hash'>
            	<cfset LOCAL.subidList = resolveHash(LOCAL.depItem.dep)>
            	<cfset LOCAL.cache.deps.idList = ListAppend(LOCAL.cache.deps.idList, LOCAL.subidList)>
			<cfelseif LOCAL.depItem.type EQ 'id'>
            	<!--- resolve id to id history --->
			<cfelseif LOCAL.depItem.type EQ 'history_id'>
            	<cfset LOCAL.cache.deps.idList = ListAppend(LOCAL.cache.deps.idList, LOCAL.depItem.dep)>			            	
            </cfif>            	
        </cfloop>
        
		<cfset LOCAL.cache.deps.idList = listRemoveDuplicates(LOCAL.cache.deps.idList)>        
        
        <cfreturn LOCAL.cache.deps.idList>    
    </cffunction>
    
    <cffunction name="listRemoveDuplicates" returntype="string" access="private" hint="Removes duplicate list items.">
    	<cfargument name="list" required="true" type="string">
        
        <cfset var i = 0>
        <cfset var listStruct = structNew()>
        <cfset var newList = "">

        <cfreturn newList>
    </cffunction>
  
    
</cfcomponent>