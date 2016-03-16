<cfcomponent name="shortcodes">

<cfset variables.sc = "">
<cfset variables.codes = structNew()>
<cfset variables.head_code = structNew()>
<cfset variables.override_directory = "">

<cffunction name="getlist" output="false">
   <cfreturn variables.head_code>
</cffunction>

<cffunction name="getCodeCache" output="false">
	<cfreturn variables.codes>
</cffunction>

<cffunction name="GetHeadCode" output="false">
   <cfreturn variables.head_code>
</cffunction>

<cffunction name="init" output="false" returntype="shortcodes">
	<cfargument name="site_config" required="true">

	<cfset variables.sc = arguments.site_config>

	<cfreturn this>
</cffunction>

<cffunction name="setOverrideDirectory" output="false" returntype="void">
	<cfargument name="directory" type="string" required="true">
	<cfset variables.override_directory = arguments.directory>
</cffunction>

<cffunction name="doShortCode" output="false" returntype="string">
	<cfargument name="content" type="string" required="true">
	<cfargument name="site_config" required="false" default="#variables.sc#">
	<cfargument name="clearCodes" required="false" type="boolean" default="false">

	<cfset var c = "">
	<cfset var retval = "">

	<cfinvoke method="parseCodes" returnvariable="c">
		<cfinvokeargument name="html" value="#content#">
	</cfinvoke>

	<cfinvoke method="nestCodes">
	    <cfinvokeargument name="c" value="#c#">
	</cfinvoke>

	<cfinvoke method="runCodes" returnvariable="retval">
	    <cfinvokeargument name="c" value="#c#">
	    <cfinvokeargument name="html" value="#content#">
	    <cfinvokeargument name="site_config" value="#arguments.site_config#">
	    <cfinvokeargument name="clearCodes" value="arguments.clearCodes">
	</cfinvoke>

	<cfreturn retval>
</cffunction>

<cffunction name="parseCodes" output="false" returntype="struct">
	<cfargument name="html" type="string" required="true">

	<cfset var shortcodes = structNew()>
	<cfset var shortcodes.len = arrayNew(1)>
	<cfset var shortcodes.pos = arrayNew(1)>

	<cfset var start = 1>

	<cfset var i = 0>
	<cfset var short = arrayNew(1)>
	<cfset var s = "">
	<cfset var rawStr = "">
	<cfset var raw = "">
	<cfset var ii = 0>
	<cfset var iii = 0>
	<cfset var lastarg = "">
	<cfset var myfound = "">
	<cfset var iv = "">
	<cfset var lastfound = "">

	<cfset var c = "">

	<cfloop condition="start LT len(arguments.html)">
		<!--- 
		<cfset found = refindnocase('(?x)\[\/asdf', arguments.html, start, true)>
		--->

		<cfset found = refindnocase('(?=...)\[[^\]]+\]', arguments.html, start, true)>
		<!--- <cfset found = refindnocase('[[][a-z \s]+[]]', mytext, start, true)> --->

		<cfif found['pos'][1] EQ 0>
			<!--- no more shortcodes found --->
		    <cfbreak>
		</cfif>

		<cfset start = found['pos'][1] + found['len'][1]>

		<cfset arrayAppend(shortcodes.len, found['len'][1])>
		<cfset arrayAppend(shortcodes.pos, found['pos'][1])>

	</cfloop>

	<cfloop from="1" to="#ArrayLen(shortcodes.len)#" index="i">
		<cfset arrayAppend(short, structNew())>
	    
	    <cfset s = short[arrayLen(short)]>
	    <cfset s.len = shortcodes.len[i]>
	    <cfset s.pos = shortcodes.pos[i]>
	    <cfset s.args = structNew()>
	    <cfset s.codes = arrayNew(1)>

		<cfset rawStr = mid(arguments.html, shortcodes.pos[i] + 1, shortcodes.len[i] - 2)>	
		<cfset raw = listToArray(rawStr, ' ', false, false)>
		
	    <cfset ii = 1>
	    
	    <!--- check for closure --->
	    <cfif mid(raw[1], 1, 1) eq "/">
	    	<cfif len(raw[1]) eq 1>
	        	<cfset s.method = raw[2]>
	        	<cfset s.close = true>
				<cfset ii = 3>
	        <cfelse>
	        	<cfset s.method = mid(raw[1], 2, (len(raw[1]) - 1))>
	            <cfset s.close = true>
				<cfset ii = 2>
	        </cfif>
	    <cfelse>
	    	<cfset s.method = raw[1]>
	        <cfset s.close = false>
	        <cfset ii = 2>
	    </cfif>
	   
	    <cfif ii lte arrayLen(raw) >
			<cfset ff = findnocase(raw[ii], rawStr, 1)>
	        
	        <cfset rawStr = mid(rawStr, ff, len(rawStr) - ff + 1)>	
	        <cfset raw = listToArray(rawStr, '=', false, false)>
	        
	      <!---   <cfdump var="#raw#"> --->
	        
	        <!--- collect the args --->
	        <cfset iii = 1>
	        <cfset lastarg = "">
	        <cfloop from="1" to="#arrayLen(raw)#" index="iii">
	        	<cfif (iii gt 1) AND (iii lt arrayLen(raw))>
	            	<!--- find the last space --->
	                <cfset iv = 1>
					<cfset myfound = find(' ', raw[iii], iv)>
	                <cfloop condition="myfound NEQ 0">
	                	<cfset lastfound = myfound>
	                    <cfset iv = myfound + 1>
	   	                <cfset myfound = find(' ', raw[iii], iv)>
	                </cfloop>
	                
	                <cfset s.args["#lastarg#"] = cleanVal(trim(mid(raw[iii], 1, lastfound - 1)))>
	<!---             		<br />VAL: <cfoutput>#trim(mid(raw[iii], 1, lastfound - 1))#</cfoutput>
	                    <br />ARG: <cfoutput>#trim(mid(raw[iii], lastfound, len(raw[iii]) - lastfound + 1))#</cfoutput> --->	
					<cfset lastarg = trim(mid(raw[iii], lastfound, len(raw[iii]) - lastfound + 1))>
	                <cfset s.args["#ucase(lastarg)#"] = "">
				<cfelseif (iii EQ 1)> <!--- first arg --->
	     <!---        	<br />FIRST ARG: <cfoutput>#raw[iii]#</cfoutput> --->
	                <cfset lastarg = raw[iii]>
	                <cfset s.args["#ucase(lastarg)#"] = "">
	            <cfelse>
	            	<cfset s.args["#lastarg#"] = cleanVal(raw[iii])>
		<!---             	<br />LAST VALUE: <cfoutput>#raw[iii]#</cfoutput> --->
	            </cfif> 
	        </cfloop> 
	        
	    </cfif>
	</cfloop> 

	<cfset c = structNew()>
	<cfset c.pos = 1>
	<cfset c.len = 0>
	<cfset c.len2 = 0>
	<cfset c.pos2 = len(arguments.html) + 1>
	<cfset c.method = "">
	<cfset c.codes = short>

	<cfreturn c>
</cffunction>

<cffunction name="cleanVal" access="public" returntype="string" output="false">
	<cfargument name="value" type="string" required="true">
   
    <cfif mid(value, 1, 1) EQ '"' AND mid(value, len(value), 1) EQ '"'>
    	<cfreturn mid(value, 2, len(value) - 2)>
    </cfif>
    
    <cfif mid(value, 1, 1) EQ "'" AND mid(value, len(value), 1) EQ "'">
    	<cfreturn mid(value, 2, len(value) - 2)>    	
    </cfif>
    
    <cfreturn value>
</cffunction>

<cffunction name="runCodes" access="public" returntype="string" output="false">
	<cfargument name="c" type="struct" required="true">
	<cfargument name="html" type="string" required="true">
	<cfargument name="site_config" required="false" default="#variables.sc#">
	<cfargument name="filterlist" required="false">
	<cfargument name="clearCodes" required="false" type="boolean" default="false">

    <cfset var i = "">
    <cfset var content = "">
    <cfset var prev_pos = "">
    <cfset var length = "">
    <cfset var mytext = arguments.html>

    <cfif NOT isStruct(arguments.site_config)>
    	<cfthrow message="argument site_config is not defined">
    	<cfabort>
    </cfif>

    <cfif arrayLen(c.codes) gt 0>
        <cfloop from="1" to="#arrayLen(c.codes)#" index=i>
			<cfif i EQ 1>
				<cfset content = content & mid(mytext, c.pos + c.len, c.codes[i].pos - (c.pos + c.len))> 
			<cfelse>
            	<cfif StructKeyExists(c.codes[i - 1], "pos2")>
                	<cfset prev_pos = c.codes[i - 1].pos2 + c.codes[i - 1].len2>
                <cfelse>
	                <cfset prev_pos = c.codes[i - 1].pos + c.codes[i - 1].len>
                </cfif>
                
				<cfset content = content & mid(mytext, prev_pos, c.codes[i].pos - prev_pos)> 
            </cfif>
            
			<cfset content = content & runCodes(c: c.codes[i], html: arguments.html, site_config: arguments.site_config, filterlist: arguments.filterlist)>
        </cfloop>

        <!--- last text --->
        <cfif arrayLen(c.codes) gt 0>
           	<cfset i = arrayLen(c.codes)>
			<cfif StructKeyExists(c.codes[i], "pos2")>
               	<cfset prev_pos = c.codes[i].pos2 + c.codes[i].len2>
            <cfelse>
                <cfset prev_pos = c.codes[i].pos + c.codes[i].len>
            </cfif>

    		<cfset content = content & mid(mytext, prev_pos, c.pos2 - prev_pos)>	
        </cfif>
        
        <cfset c.content = content>
    <cfelse>
		<cfif StructKeyExists(c, "pos2")>
        	<cfset c.content = mid(mytext, c.pos + c.len, c.pos2 - (c.pos + c.len))>
        <cfelse>
        	<cfset c.content = "">
        	<!--- no content --->
        </cfif>
    </cfif>

    <cfif len(c.method) gt 0>
    	<cfif arguments.clearCodes EQ true>
    		<cfset c.content = "">
    	<cfelse>
			<cfset createShortCode(c)> 
			<cfset local.code = variables.codes["#c.method#"]>

<!--- <cftry> --->
			<cfset c.content = local.code.runCode(argumentcollection: c.args, s_content: c.content)>

 			<cfinvoke component="renderCore" method="renderChain" returnvariable="c.content">
				<cfif NOT isNull(arguments.filterlist)>
					<cfinvokeargument name="filterList" value="#arguments.filterlist#">		
				</cfif> 
				<cfinvokeargument name="content" value="#c.content#">
				<cfinvokeargument name="site_config" value="#arguments.site_config#">
				<cfinvokeargument name="shortCodesObject" value="#this#">
			</cfinvoke>  
<!--- <cfcatch>
<cfdump var="#c#">
<cfabort>
</cfcatch>	
</cftry>--->
    	</cfif>   	
    </cfif> 

    <cfreturn c.content>
	
</cffunction>

<cffunction name="verifyShortCodes" access="public" output="false" hint="Creates and removes missing shartcodes">
	<cfargument name="c" type="struct" required="false">
	<cfargument name="site_config" required="false" default="#variables.sc#">

	<cfset local.removeList = "">

	<cfloop from='1' to='#arraylen(arguments.c.codes)#' index="local.i">
		<cfset local.code = arguments.c.codes[local.i]>
		<!--- create codes for future use --->
		<cfset local.exists = createShortCode(local.code)>

		<cfif arraylen(local.code.codes) GT 0>
			<cfset verifyShortCodes(local.code, arguments.site_config)>
		</cfif>

		<cfif NOT local.exists EQ TRUE>
			<cfset local.removeList = listAppend(local.removeList, local.i)>
		</cfif>
	</cfloop>

	<!--- remove the invalid codes --->
	<cfset local.removeList = ListSort(local.removeList, 'numeric', 'desc')>
	<cfloop list="#local.removeList#" index="local.i">
		<cfset ArrayDeleteAt(arguments.c.codes, local.i)>
	</cfloop>
</cffunction>

<cffunction name="createShortCode" access="public" returntype="ANY">
	<cfargument name="c" type="struct" required="true">
	<cfargument name="site_config" required="false" default="#variables.sc#">
	<cfargument name="tryNumber" type="numeric" default="1" required="false">

	<cftry>
		<!--- put the code in memory for future use --->   	
		<cfif NOT structKeyExists(variables.codes, c.method)>
			<cfif variables.override_directory NEQ "" AND arguments.tryNumber EQ 1>				
 				<cfset variables.codes["#c.method#"] = createObject("component", "#arguments.site_config.cfMappedPath#.#arguments.site_config.sitepath#.shortcodes.#variables.override_directory#_#c.method#").init(site_config: arguments.site_config, head_code: variables.head_code)>
			<cfelse>
				<cfset variables.codes["#c.method#"] = createObject("component", "#arguments.site_config.cfMappedPath#.#arguments.site_config.sitepath#.shortcodes.core.#c.method#").init(site_config: arguments.site_config, head_code: variables.head_code)>
			</cfif>
		</cfif>
			
		<cfcatch>
			<!--- <cfset c.content = "" --->
			<cfif structKeyExists(cfcatch, "missingFileName") AND variables.override_directory NEQ "" AND arguments.tryNumber EQ 1>
				<cfreturn createShortCode(c, arguments.site_config, 2)>					
			<cfelseif structKeyExists(cfcatch, "missingFileName")>
				<cfreturn false>
			<cfelse>
				<cfrethrow>
			</cfif>
		</cfcatch>	
	</cftry>

	<cfreturn true>
</cffunction>

<cffunction name="nestCodes" access="public" returnType="void" output="false">
	<cfargument name="c" type="struct" required="true">

	<cfset var i = "">
    <cfset var j = "">
    <cfset var iii = ""> 

    <cfloop from="1" to="#arrayLen(c.codes)#" index="i">
   	<cfif i gt arrayLen(c.codes)>
    	<cfbreak>
    </cfif>
    
	<cfif c.codes[i].close neq true>
        <cfloop from="#i#" to="#arrayLen(c.codes)#" index="j">
        	<cfif c.codes[i].method EQ c.codes[j].method AND c.codes[j].close EQ true>
               
                <!--- collect the short codes --->
                <cfset c.codes[i].LEN2 = c.codes[j].LEN>
                <cfset c.codes[i].POS2 = c.codes[j].POS>
				
				<cfif j - i gt 1>
                	<cfloop from="#i + 1#" to="#j - 1#" index="iii">
                    	<cfset arrayAppend(c.codes[i].codes, c.codes[iii])>
                    </cfloop>
                
                   	<cfloop to="#i + 1#" from="#j#" index="iii" step="-1">
	                  	<cfset arrayDeleteAt(c.codes, iii)>
                    </cfloop>
                    
                    <cfset nestCodes(c.codes[i])>
                    
                    <cfbreak>
                <cfelse>
                	<cfset arrayDeleteAt(c.codes, j)>
                    <cfbreak>
                </cfif>
                
            </cfif>
        </cfloop>
    </cfif>
	</cfloop>
</cffunction> 

</cfcomponent>



