<cfsilent>
<cfset SERVER_KEY = "cfgroovy-r6055" />
<cffunction name="bootstrapGroovyFromJavaLoader" access="private" output="false" returntype="any">
	<cfset var cp = listToArray(getDirectoryFromPath(getCurrentTemplatePath()) & "groovy-all-1.6.0.jar") />
	<cfset var javaLoader = createObject("component", "JavaLoader").init(cp, true) />
	<cfreturn javaLoader.create("org.codehaus.groovy.jsr223.GroovyScriptEngineImpl").init() />
</cffunction>
<cffunction name="runScript" access="private" output="false" returntype="string">
	<cfargument name="body" type="string" required="true" />
	<cfset var engine = "" />
	<cfset var binding = "" />
	<cfset var scope = "" />
	<cfset var context = "" />
	<cfset var sw = createObject("java", "java.io.StringWriter").init() />
	<cfset var pw = createObject("java", "java.io.PrintWriter").init(sw) />
	<cfset var s = "" />
	<cfif NOT structKeyExists(server, SERVER_KEY)>
		<cfset s = structNew() />
		<cfset s["scriptCache"] = createObject("java", "java.util.WeakHashMap").init() />
		<cfset s["CompilableClass"] = getPageContext().getClass().forName("javax.script.Compilable") />
		<cfset server[SERVER_KEY] = s />
	</cfif>
	<cfif NOT structKeyExists(server[SERVER_KEY], "#attributes.lang#Engine")>
		<cftry>
			<cfset server[SERVER_KEY]["#attributes.lang#Engine"] = createObject("java", "javax.script.ScriptEngineManager")
				.getEngineByName(attributes.lang) />
			<cfcatch type="java.lang.ClassNotFoundException" />
			<cfcatch type="Railo.commons.lang.classexception" />
			<cfcatch type="Object" />
			<cfcatch type="Invalid Class" />
		</cftry>
		<cfif NOT structKeyExists(server[SERVER_KEY], "#attributes.lang#Engine")>
			<cfif attributes.lang EQ "groovy">
				<cfset server[SERVER_KEY]["#attributes.lang#Engine"] = bootstrapGroovyFromJavaLoader() />
			<cfelse>
				<cfthrow type="CFGroovy.UnknownLanguageException"
					message="The language you specified (#attributes.lang#) is not recognized."
					detail="You must ensure you're running Java 1.6 or greater, and have the necessary JAR(s) on your classpath." />
			</cfif>
		</cfif>
	</cfif>
	<cfset engine = server[SERVER_KEY]["#attributes.lang#Engine"] />
	<cfset binding = engine.createBindings() />
	<cfset binding.put("variables", attributes.variables) />
	<cfset binding.put("pageContext", getPageContext()) />
	<cfloop list="url,form,request,cgi,session,application,server,cluster" index="scope">
		<cfif isDefined(scope)>
			<cfset binding.put(scope, evaluate(scope)) />
		</cfif>
	</cfloop>
	<cfloop list="#lCase(structKeyList(attributes))#" index="scope">
		<cfif listFind("language,lang,script,variables", scope) EQ 0>
			<cfset binding.put(scope, attributes[scope]) />
		</cfif>
	</cfloop>
	<cfset body = trim(body) />
	<cfif len(body) EQ 0>
		<cfthrow type="CFGroovy.EmptyScriptException"
			message="You attempted to execute an empty script.  This is not allowed"
			detail="Groovy scripts must have at least one expression in them.  Forgetting to use &lt;cfoutput> around your &lt;g:script> tag when &lt;cfsetting enableCfOutputOnly=""true"" /> is a common cause of this problem." />
	</cfif>
	<cfset context = engine.getContext().getClass().newInstance() />
	<cfset context.setBindings(binding, context.ENGINE_SCOPE) />
	<cfset context.setWriter(pw) />
	<cfset context.setErrorWriter(pw) />
	<cfif server[SERVER_KEY]["CompilableClass"].isAssignableFrom(engine.getClass())>
		<cfset script = server[SERVER_KEY].scriptCache.get(body) />
		<cfif structKeyExists(variables, "script")>
			<cfset script = script.get() />
		</cfif>
		<cfif NOT structKeyExists(variables, "script")>
			<cfset script = engine.compile(body) />
			<cfset server[SERVER_KEY].scriptCache.put(body, createObject("java", "java.lang.ref.WeakReference").init(script)) />
		</cfif>
		<cftry>
			<cfset script.eval(context) />
			<cfcatch type="javax.script.ScriptException">
				<cfloop condition="structKeyExists(cfcatch, 'cause')">
					<cfset cfcatch = cfcatch.cause />
				</cfloop>
				<cfthrow object="#cfcatch#" />
			</cfcatch>
		</cftry>
	<cfelse>
		<cfset engine.eval(body, context) />
	</cfif>
	<cfreturn sw.toString() />
</cffunction>
<cfif thisTag.executionMode EQ "start">
	<cfparam name="attributes.language" default="groovy" />
	<cfparam name="attributes.lang" default="#attributes.language#" />
	<cfparam name="attributes.variables" default="#caller#" />
	<cfif NOT structKeyExists(attributes, "script") AND NOT thisTag.hasEndTag>
		<cfthrow type="CFGroovy.NoScriptException"
			message="No script was supplied <g:script> tag."
			detail="The <g:script> tag required either a body or a 'script' attribute contining the Groovy script to execute." />
	</cfif>
<cfelse><!--- executionMode EQ "end" --->
	<cfif NOT structKeyExists(attributes, "script")>
		<cfset attributes.script = thisTag.generatedContent />
	</cfif>
	<cfset thisTag.generatedContent = "" />
</cfif>
<!--- forgive the missing linebreak - it's to avoid an unwanted line break in the caller's output --->
</cfsilent><cfif structKeyExists(attributes, "script") AND (NOT thisTag.hasEndTag OR thisTag.executionMode EQ "end")><cfoutput>#runScript(attributes.script)#</cfoutput></cfif>