<!---
02-14-2013
 
	WE - 12-20-2012 - Updated stringtoSEOURL to add a whitelist fixing url bugs
--->

<cfcomponent>
	<cfset variables.datasource = ''>    
	
	<cfset variables.pageCaller = -1>
    <cfset variables.VARCHARMAX = 1000>
	
<cffunction name="stringToSEOURL" access="public" returntype="string" output="false" hint="Creates an SEO friendly URL from a string.">
    <cfargument name="sourceStr" required="true" hint="Source String">

    <cfset var urlString = trim(lcase(arguments.sourceStr))>
    <cfset var i = 1>
    <cfset var l = 0>
    <cfset var whitelist = "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,-">

    <!--- weird things --->
    <cfset urlString = replaceNoCase(urlString, 'at&t', 'att', 'all')>
    <cfset urlString = replaceNoCase(urlString, '. ', '-', 'all')>
    <cfset urlString = replaceNoCase(urlString, ' | ', ' ', 'all')>
    <cfset urlString = replaceNoCase(urlString, ' - ', '-', 'all')>

    <cfset urlString = replaceNoCase(urlString, '/', '-', 'all')>
    <cfset urlString = replaceNoCase(urlString, '!', '', 'all')>
    <cfset urlString = replaceNoCase(urlString, ' ', '-', 'all')>
    <cfset urlString = replaceNoCase(urlString, '.', '', 'all')>
    <cfset urlString = replaceNoCase(urlString, chr(39), '', 'all')>
    <cfset urlString = replaceNoCase(urlString, chr(47), '', 'all')>
    <cfset urlString = replaceNoCase(urlString, chr(38), 'and', 'all')>


    <!--- ONLY allow whitelist characters --->
    <cfloop condition="i LTE len(urlString)">
        <cfif listFind(whitelist, mid(urlString, i, 1)) EQ 0>
            <cfset l = len(urlString)>
            <cfset urlString = replace(urlString, mid(urlString, i, 1), '')>
            <cfset i = i - (l - len(urlString))>
        </cfif> 
        <cfset i = i + 1>
    </cfloop>

    <!--- make sure last and beginning character are not '-' --->
    <cfif mid(urlString, 1, 1) eq '-'>
        <cfset urlString = mid(urlString, 2, len(urlString) - 1)>
    </cfif>

    <cfif mid(urlString, len(urlString), 1) eq '-'>
        <cfset urlString = mid(urlString, 1, len(urlString) - 1)>
    </cfif>

    <cfset urlString = urlEncodedFormat(urlString, 'utf-8')>
    <cfset urlString = replaceNoCase(urlString, '%2D', '-', 'all')>
    <cfreturn urlString>

</cffunction>

    <!--- 
	<cffunction name="stringToSEOURL" access="public" returntype="string" output="false" hint="Creates an SEO friendly URL from a string.">
    	<cfargument name="sourceStr" required="true" hint="Source String">
    	
        <cfset var url = trim(lcase(arguments.sourceStr))>
        <cfset var i = 1>
        <cfset var whitelist = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,-">
        
        <cfset url = replaceNoCase(url, ' | ', ' ', 'all')>
        <cfset url = replaceNoCase(url, '!', '', 'all')>
        <cfset url = replaceNoCase(url, ' - ', '-', 'all')>
        <cfset url = replaceNoCase(url, ' ', '-', 'all')>
        <cfset url = replaceNoCase(url, '.', '', 'all')>
        <cfset url = replaceNoCase(url, chr(39), '', 'all')>
        <cfset url = replaceNoCase(url, chr(47), '', 'all')>
        <cfset url = replaceNoCase(url, chr(38), 'and', 'all')>
        
        <!--- ONLY allow whitelist characters --->
        <!--- 
        <cfloop from="1" to="#len(url)#" index="i" >
			<cfif listFind(whitelist, mid(url, i, 1)) NEQ 0>
				<cfset url = replaceNoCase(url, mid(url, i, 1), '')>
			</cfif> 
		</cfloop>
		--->  
		
		<cfset url = URLEncodedFormat(url, 'utf-8')>
        <cfset url = replaceNoCase(url, '%2D', '-', 'all')>
        
        <cfreturn url>
    </cffunction>
    --->


	<cffunction name="stringToSummary" access="public" output="false" returntype="string">
		<cfargument name="sourceStr" required="true" type="string">
        <cfargument name="minLength" type="numeric" required="false" default="#arguments.maxLength - 50#">
        <cfargument name="maxLength" type="numeric" required="false" default="100">
        <cfargument name="nearestSentence" type="boolean" required="false" default="true">
        
       <!--- 
        <cfdump var="#arguments#">
        <cfabort>
        --->
        
    	<cfset var mySummary = "">
        <cfset var myText = "">
    	<cfset var nextBlank = 0>
        <cfset var foundBlank = 0>
        <cfset var firstPeriod = 0>
    	<cfset var foundPeriod = 0>
		<cfset var i = arguments.minLength>
        <cfset var tempstr = "">
        
        <!--- return the whole string if desired max is longer than the sourceStr --->
        <cfif maxLength eq -1 OR arguments.maxLength gte len(trim(sourceStr))>
        	<cfreturn trim(sourceStr)>
        </cfif>
        
        <!--- is nearestSentence true, look to see if the first period is before the minimum --->
        <cfset myText = trim(sourceStr)>
       
        <cfif arguments.nearestSentence eq true>
			<cfset firstPeriod = findNoCase(". ", myText, i)>
            <cfloop condition="firstPeriod neq 0">
                <cfset firstPeriod = findNoCase(". ", myText, i)>
                <!--- check for exceptions --->
                <cfif firstPeriod neq 0>
                    <cfset tempstr = mid(mytext, firstPeriod - 5, 5)>
                    <cfif refindNoCase("( m.| ed.| ph.| st.| dr.| prof.| jan.| feb.| mar.| apr.| jun.| jul.| aug.| sept. | oct.| nov.| dec.| mr.| mrs.)", tempstr & ".") eq 0>
                        <cfif firstPeriod lte arguments.maxLength>
                            <cfset foundPeriod = firstPeriod>
                        </cfif>
                    </cfif>
                </cfif>
                <cfset i = firstPeriod + 1>
                <cfif i gt maxLength>
                    <cfbreak>
                </cfif>
            </cfloop>
		</cfif>
        				
     	<cfif foundPeriod gt 0>
        	<cfreturn mid(myText, 1, foundPeriod)>
       	<cfelse>
			   <!--- trim the string --->
                <cfset nextBlank = findnocase(' ', myText, arguments.minLength)>
                <cfloop condition="nextBlank neq 0"> 
					<cfif nextBlank lt arguments.maxLength>
                        <cfset foundBlank = nextBlank>
                    <cfelse>
                    	<cfif foundBlank eq 0>
                        	<cfset foundBlank = arguments.maxLength - 3>
                        </cfif>
                    </cfif>
                    <cfset nextBlank = findnocase(' ', myText, nextBlank + 1)>
                </cfloop>

              	<cfif foundBlank eq 0>
                   	<cfset foundBlank = arguments.maxLength - 3>
                </cfif>
                
                <cfset mySummary = mid(myText, 1, foundBlank - 1)>
                <!--- Take out punctuation before elipses --->                
				<cfif refindNoCase("[,|;|:]", mid(mySummary, len(mySummary), 1)) neq 0>
					<cfset mySummary = mid(mySummary, 1, len(mySummary) - 1)>
                </cfif>
				<cfset mySummary = trim(mySummary) & "...">
        </cfif> 
        <cfreturn mySummary>
   </cffunction>

    
    <cffunction name="getDataByCaller" access="public" returntype="any">
		<!--- Stub --->
    </cffunction>
    
    <!--- HTML to XML --->
    <cffunction name="HTMLtoXML" access="public" output="no" returntype="any">
    	<cfargument required="yes" name="html" type="string">
        <cfreturn xmlparse(HTMLtoXHTML(html: arguments.html))>        
    </cffunction>

    <cffunction name="getJsoup" access="public" output="false" returntype="any">
        <cfset local.currentDirectory = getDirectoryFromPath(
            getCurrentTemplatePath()) />
        <cfset local.JsoupJarFile = (local.currentDirectory & "jsoup-1.7.2.jar") />
        <cfset local.loadPaths = ArrayNew(1)>

        <cfset arrayAppend(local.loadPaths, local.JsoupJarFile)>

        <cfset local.javaloader = createObject("component", "cfgroovy.javaloader").init(local.loadPaths)>

        <!--- Create our TagSoup parser. --->
        <cfreturn local.javaloader.create("org.jsoup.Jsoup")>

    </cffunction>

	<!--- Ben Nadel --->
    <cffunction name="HTMLtoXHTML" access="public" output="no" returntype="any"> 
        <cfargument required="yes" name="html" type="string">  
        <cfset var myHTML = arguments.html>

		<!--- Import the CFGroovy tag library. --->
        <cfimport prefix="g" taglib="cfgroovy/" />
         
        <!---
            Get the current directory path. This will be used so we
            don't have to use expandPath() on the JAR or HTML file paths.
        --->
        <cfset currentDirectory = getDirectoryFromPath(
            getCurrentTemplatePath()
            ) />
         
        <!---
            Get the file path to the TagSoup jar file (which will be
            loaded by the Groovy script engine.
        --->
        
        <cfset tagSoupJarFile = (currentDirectory & "tagsoup-1.2.1.jar") />

    <g:script>
     
        <!---
            Get the class loader being used by the Groovy script
            engine. We will need this to load classes in the TagSoup
            JAR file.
        --->
        def classLoader = this.getClass().getClassLoader();
     
        <!---
            Add the TagSoup JAR file to the class loader's list of
            classes that it can instantiate.
        --->
        classLoader.addURL(
            new URL( "file:///" + variables.tagSoupJarFile )
            );
     
        <!---
            Get an instance of the the tag soup parser HTML parser
            from the class loader. This is a SAX-compliant parser.
        --->
        def tagSoupParser = Class.forName(
            "org.ccil.cowan.tagsoup.Parser",
            true,
            classLoader
            )
            .newInstance()
        ;
     
        <!---
            Create an instance of the Groovy XML Slurper using the
            TagSoup parsing engine.
        --->
        def htmlParser = new XmlSlurper( tagSoupParser );
     
        <!---
            Parse the raw HTML text into a valid XHTML document using
            the TagSoup parsing engine. This will give us GPathResult
            XML Document.
        --->
        def xhtml = htmlParser.parseText( variables.html );
     
        <!---
            Now that we have an XHTML (XML) document, we need to
            serialize that back into HTML mark up.
        --->
        def cleanHtmlWriter = new StringWriter()
     
        <!---
            This builds the markup in the string writer using the
            Streaming markup builder.
     
            NOTE: This step loses me a bit. I have not been able to
            find any great documentation on how this is uses or what
            exactly it does. But, it looks like somehow the XHTML
            document is being bound to the markup builder, which is
            then searialized to the string writer.
        --->
        cleanHtmlWriter << new groovy.xml.StreamingMarkupBuilder().bind(
            {
            mkp.declareNamespace( '': 'http://www.w3.org/1999/xhtml' );
            mkp.yield( xhtml );
            }
        );
     
        <!---
            Now that we have our X(HTML) document serialized in our
            string writer, let's convert it to a string and store it
            back into the ColdFusion varaibles scope.
        --->
        variables.xhtml = cleanHtmlWriter.toString().trim();
     
    </g:script>
    <!--- ----------------------------------------------------- --->
    <!--- ----------------------------------------------------- --->
     
     
    <!---
        Now that we have cleaned the HTML into XHTML, we can parse it
        using XmlParse().
    --->
    <cfreturn xhtml/>
    </cffunction>
    
    <!--- Based on - http://www.cflib.org/udf/stripHTML 12/1/2010
	/**
	* Removes HTML from the string.
	* v2 - Mod by Steve Bryant to find trailing, half done HTML.
	* v4 mod by James Moberg - empties out script/style blocks
	*
	* @param string      String to be modified. (Required)
	* @return Returns a string.
	* @author Raymond Camden (ray@camdenfamily.com)
	* @version 4, October 4, 2010  
	**/
	--->
    <cffunction name="stripHTMLTags" access="public" hint="strips an explicit list of tag names">
    	<cfargument name="html" type="string" required="true" hint="HTML to 'clean'">
        <cfargument name="tagList" type="string" required="true" hint="comma delimited list of tags to remove (a, br, img, etc...)">
    	<cfargument name="stripComments" type="boolean" required="false" default="false">
		<cfset var retHTML = arguments.html>
        <cfset var iTag = "">
        
        <!--- strip comments --->
        <cfif arguments.stripComments EQ true>		
			<cfset retHTML = reReplaceNoCase(retHTML, "<!--.*?-->", "", "all")> 
        </cfif>
        
        <cfloop list="#arguments.tagList#" delimiters="," index="iTag">
        	<cfset iTag = trim(iTag)>
        	<cfset retHTML = reReplaceNoCase(retHTML, "<#iTag#.*?>","","all")>
        	<cfset retHTML = reReplaceNoCase(retHTML, "</#iTag#.*?>","","all")>
        </cfloop> 
          
        <cfreturn retHTML>  	
    </cffunction>
    
    <!--- http://www.cflib.org/udf/stripHTML 12/1/2010 --->
	<cffunction name="XHTMLToHTMLFrag" access="public" returntype="string" hint="Makes XHTML into easy to inline HTML">
    	<cfargument name="html" required="true">
		<cfset var str = arguments.html>
        <cfscript>
			str = reReplaceNoCase(str, "</html.*?>","","all");
			str = reReplaceNoCase(str, "<html.*?>","","all");
			str = reReplaceNoCase(str, "</body.*?>","","all");
			str = reReplaceNoCase(str, "<body.*?>","","all");
			str = reReplaceNoCase(str, "<br clear='none'></br>", "<br />", "all");
        </cfscript>
		<cfreturn str>
    </cffunction>
	
	<!--- http://www.cflib.org/udf/stripHTML 12/1/2010 --->
    <cfscript>
	/**
	* Removes HTML from the string.
	* v2 - Mod by Steve Bryant to find trailing, half done HTML.
	* v4 mod by James Moberg - empties out script/style blocks
	*
	* @param string      String to be modified. (Required)
	* @return Returns a string.
	* @author Raymond Camden (ray@camdenfamily.com)
	* @version 4, October 4, 2010  
	**/
	function stripHTML(str) {		 	
		str = reReplaceNoCase(str, "<*style.*?>(.*?)</style>","","all");
		str = reReplaceNoCase(str, "<*script.*?>(.*?)</script>","","all");
		// WE - convert <br> tags to line returns
		
		// fix lists so they look right!
		str = reReplaceNoCase(str, "<ul.*?>", "#Chr(13)##Chr(13)#", "all");
		str = reReplaceNoCase(str, "<li.*?>", "#Chr(9)#", "all");

		str = reReplaceNoCase(str, "<br.*?>", "#Chr(13)#", "all");
		str = reReplaceNoCase(str, "</p.*?>", "#Chr(13)##Chr(13)#", "all");
		str = reReplaceNoCase(str, "</h.*?>", "#Chr(13)##Chr(13)#", "all");
		str = reReplaceNoCase(str, "</a.*?>", " ", "all");
		str = reReplaceNoCase(str, "</li.*?>", "#Chr(13)#", "all");
			
		str = reReplaceNoCase(str, "<img.*?>", "#Chr(13)##Chr(13)#", "all");
	
		// strip comments
		str = reReplaceNoCase(str, "<!--.*?-->", "", "all");
	
		str = reReplaceNoCase(str, "<.*?>","","all");

		//get partial html in front
		str = reReplaceNoCase(str, "^.*?>","");

		//get partial html at end
		str = reReplaceNoCase(str, "<.*$","");

		// WE - take out extra blank space!
		str = reReplaceNoCase(str, "(&nbsp;|&##xa0;)", " ", "all");
//		str = reReplaceNoCase(str, "(&nbsp;| )(&nbsp;| )+", " ", "all");
		str = reReplaceNoCase(str, "  +", " ", "all");
		
		while (reFindNoCase("( |#Chr(13)#)+", str) == 1){ 
			str = reReplaceNoCase(str, "( |#Chr(13)#)+", "", "one");			
		}
				
		// WE - strip chr(10)
		str = reReplaceNoCase(str, "#Chr(10)#+", "", "all");		
		
		// WE - strip spaces between carriage returns
		str = reReplaceNoCase(str, "#Chr(13)#(&nbsp;| )+#Chr(13)#", "", "all");
		
		// WE - strip multiple carriage returns
		str = reReplaceNoCase(str, "#Chr(13)##Chr(13)##Chr(13)#+", "#Chr(13)##Chr(13)#", "all");
		
		str = reReplaceNoCase(str, "#Chr(13)# +", "#Chr(13)#", "all");

		return trim(str);
		
	}
	</cfscript>
	
	<cffunction name="serialize8" access="public" output="false" returntype="String">
	   <cfargument name="cfc" type="component" required="true">
	   
	   <cfset var byteOut = CreateObject("java", "java.io.ByteArrayOutputStream") />
	   <cfset var objOut = CreateObject("java", "java.io.ObjectOutputStream") />
	   
	   <cfset byteOut.init() />
	   <cfset objOut.init(byteOut) />
	   <cfset objOut.writeObject(arguments.cfc) />
	   <cfset objOut.close() />
	   
	   <cfreturn ToBase64(byteOut.toByteArray()) />
	</cffunction>

	<cffunction name="deserialize8" access="public" output="false" returntype="any">
	   <cfargument name="base64cfc" type="string" required="true" />
	   
	   <cfset var inputStream = CreateObject("java", "java.io.ByteArrayInputStream") />
	   <cfset var objIn = CreateObject("java", "java.io.ObjectInputStream") />
	   <cfset var com = "" />
	   
	   <cfset inputStream.init(toBinary(arguments.base64cfc)) />
	   <cfset objIn.init(inputStream) />
	   <cfset com = objIn.readObject() />
	   <cfset objIn.close()>
	   
	   <cfreturn com />
	</cffunction>
    
    
    <!--- JG 5/2/12   Note:replaces the "exception" char with it's HTML Format Equivalent --->
    <cffunction name="HTMLEditFormatExceptions" access="public" output="false" returntype="string" description="Add exceptions to the HTMLEditFormat method">
    	<cfargument name="exceptions" required="true" type="string" hint="Comma delimited list of display characters to add exceptions for">
        <cfargument name="uneditedString" required="true" type="string" hint="The string to be edited">

		<cfset LOCAL = structNew()>
        
		<cfset arguments.exceptions = replaceNoCase(arguments.exceptions, ' ', '', 'all')>

        <cfloop index="LOCAL.exception" list="#arguments.exceptions#" delimiters=",">
			<cfset arguments.uneditedString = replacenocase(arguments.uneditedString, HTMLEditFormat(LOCAL.exception),LOCAL.exception, 'all')>
        </cfloop>  
        <cfreturn arguments.uneditedString />          
    </cffunction>
	

</cfcomponent>