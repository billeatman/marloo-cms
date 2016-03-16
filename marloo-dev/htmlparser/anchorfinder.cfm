
<cfquery datasource="#application.datasource#" name="qChildren">
	select id, title, info, owner from mrl_sitePublic
</cfquery>
 
<cfloop query="qChildren">
  			<cfinvoke component="utilityCore" method="getPageSummary" returnvariable="myText">
       			 <cfinvokeargument name="pageId" value="#qChildren.id#">
                 <cfinvokeargument name="maxLength" value="80">
                 <cfinvokeargument name="datasource" value="#application.datasource#">
    		</cfinvoke>
            <cfinvoke component="utilityCore" method="getPageImages" returnvariable="myImages">
        		<cfinvokeargument name="pageId" value="#qChildren.id#">
                <cfinvokeargument name="datasource" value="#application.datasource#">
    		</cfinvoke>
            <cfinvoke component="utilityCore" method="getPageAnchors" returnvariable="myAnchors">
        		<cfinvokeargument name="pageId" value="#qChildren.id#">
                <cfinvokeargument name="datasource" value="#application.datasource#">
    		</cfinvoke>
            
           <!---
            <cfdump var="#myImages#">
		   --->
        	
            <div class="level1top5page">
            <cfoutput><a href="page.cfm?page_ID=#qChildren.id#" title="#qChildren.title#">#qChildren.title# Page ID: #qChildren.id#  Owner: #qChildren.owner#</a></cfoutput><br />
                <p><cfoutput>#myText#</cfoutput></p>
          	    <cfloop array="#myImages#" index="image">
					<cfif structKeyExists(image, 'filepath')>
                        <cfinvoke component="imageCore" method="imageCacher" returnvariable="webPath">
                            <cfinvokeargument name="imagePath" value="#image.filepath#">
                            <cfinvokeargument name="imageChain" value='[{"FUNC":"imageCropCenter"},{"FUNC":"imageResize","WIDTH":65.0,"HEIGHT":65.0}]'>
                        </cfinvoke> 
                        <img src="<cfoutput>#webPath#</cfoutput>">
                    <cfelse>	
                    <img src="<cfoutput>#image.src#</cfoutput>" style="width: 65px; height: 65px;" />
                    </cfif> 
                </cfloop><br />
				
           <!---      <cfdump var="#myAnchors#"> --->
                <table>
                <cfloop array="#myAnchors#" index="anchor">
                	<cfif structKeyExists(anchor, 'href')>
                    	<cfset anchor.href = trim(anchor.href)>
						<cfset check = true>
						
						<cfif lcase(mid(anchor.href, 1, 7)) eq "mailto:">
                        	<cfset check = false>
                        </cfif>
                        	                 
						<cfif mid(anchor.href, 1, 1) eq "##">
                        	<cfset check = false>
                        </cfif>
                    <cfelse>
                    	<cfset check = false>
                    </cfif>
                    
                    <cfif check eq true>
                    	<cfif lcase(mid(anchor.href, 1, 4)) eq "http">
                   		<cfelse>
                        	<cfset oldAnchor = anchor.href>
                    		<cfset anchor.href = "http://www.example.com/" & anchor.href>
                    	</cfif>
                    	<cfhttp url="#anchor.href#" method="HEAD">
						<cfif mid(cfhttp.statusCode, 1, 3) eq '404'>
                            <tr>
                            <cfoutput>
                            <td><span style="color: red">#cfhttp.statusCode#</span></td>
                            <td><cfif structKeyExists(anchor, 'title')>#anchor.title#</cfif></td>
                            <td>#anchor.href#</td>
                            
							</cfoutput>    
                            
                            </tr>
                        </cfif>
                    </cfif>                    		                  
                </cfloop>
                </table>
              </div>
              <hr>
                         
        </cfloop>