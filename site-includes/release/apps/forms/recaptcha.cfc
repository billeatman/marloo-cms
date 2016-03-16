<!--- 	  
Authors: Jakob Greinert, William Eatman 
Date: 04/23/2012
Version History: 1.00
--->

<cfcomponent displayname="Google reCAPTCHA" output="false">
	<cfset variables.privatekey = "PRIVATEKEY">
	<cfset variables.publickey = "PUBLICKEY">

	<cffunction name="init" access="public" returntype="recaptcha" hint="pseudo constructor">
        <cfargument name="publickey" type="string" required="false" default="#variables.publickey#" hint="Public Google API">
        <cfargument name="privatekey" type="string" required="false" default="#variables.privatekey#" hint="Private Google API Key">
        <cfreturn this>
    </cffunction>

	<cffunction name="verify" access="public" returntype="boolean" output="false" hint="Verify recaptcha." >
		<cfargument name="recaptcha_challenge_field" type="string" required="false" default="#form.recaptcha_challenge_field#" hint="the 'challenge' parameter required by the reCAPTCHA verification API">
		<cfargument name="recaptcha_response_field" type="string" required="false" default="#form.recaptcha_response_field#"hint="the 'response' parameter required by the reCAPTCHA verification API">
        <cfargument name="remoteip" type="string" required="false" default="#cgi.REMOTE_ADDR#" hint="Remote IP of the client">
        <cfargument name="privatekey" type="string" required="false" default="#variables.privatekey#" hint="Private Google API Key">
        
        <cfset var LOCAL = structNew()>
        
		<cfhttp url="http://www.google.com/recaptcha/api/verify" method="post" result="LOCAL.response">
        	<cfhttpparam type="formfield" name="privatekey" value="#arguments.privatekey#">
            <cfhttpparam type="formfield" name="challenge" value="#arguments.recaptcha_challenge_field#">
            <cfhttpparam type="formfield" name="response" value="#arguments.recaptcha_response_field#">
            <cfhttpparam type="formfield" name="remoteip" value="#arguments.remoteip#">
        </cfhttp>

        <cfif LOCAL.response.filecontent CONTAINS "true">
        	<cfreturn true>
        <cfelse>
        	<cfreturn false>
        </cfif>    
            
	</cffunction>
    
    <cffunction name="render" access="public" returntype="void" output="true" hint="Renders HTML for reCAPTCHA.">
        <cfargument name="publickey" type="string" required="false" default="#variables.publickey#" hint="Public Google API Key">
      <cfoutput>
	  <script type="text/javascript"
         src="https://www.google.com/recaptcha/api/challenge?k=#arguments.publickey#">
      </script>
      <noscript>
         <iframe src="https://www.google.com/recaptcha/api/noscript?k=#arguments.publickey#"
             height="300" width="500" frameborder="0"></iframe><br>
         <textarea name="recaptcha_challenge_field" rows="3" cols="40">
         </textarea>
         <input type="hidden" name="recaptcha_response_field"
             value="manual_challenge">
      </noscript>
      </cfoutput>	
    </cffunction>    
</cfcomponent>