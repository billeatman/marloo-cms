<cfcomponent displayName="Page Functions" output="false">	
	<!--- creates a new stub page in mrl_page--->	
    
    <!--- DEPRECATED WRAPPER --->
    <cffunction name="titleToURL" access="public" returntype="string" output="false" hint="Creates a URL from a page title string.">
    	<cfargument name="title" required="true" hint="A page title">
        <cfset var url = "">
    	
        <cfinvoke component="marloo.core.utilityCore" method="stringToSEOURL" returnvariable="url">
        	<cfinvokeargument name="sourceStr" value="#arguments.title#">
     	</cfinvoke>   	
        
        <cfreturn url>
    </cffunction>

    <!--- import page --->
    <cffunction name="createPageWithData" returntype="numeric">
        <cfargument name="parent_id" type="numeric" required="false" default="#application.tree.rootid#">
        <cfargument name="title" type="string" required="true">
        <cfargument name="info" type="string" required="true">
        <cfargument name="page_id" type="numeric" required="false">
        <cfargument name="comment" type="string" required="false" default="">

        <cfset var page_struct_create = "">
        <cfset var page_struct_save = "">

        <cftransaction>
            <cfinvoke method="createPage" returnvariable="page_struct_create">
                <cfinvokeargument name="idparent" value="#arguments.parent_id#">
                <cfif isDefined("arguments.page_id")>
                    <cfinvokeargument name="id" value="#arguments.page_id#">            
                </cfif>
            </cfinvoke> 

            <cfinvoke method="savePage" returnvariable="page_struct_save">
                <cfinvokeargument name="id" value="#page_struct_create.data.id#">
                <cfinvokeargument name="title" value="#trim(arguments.title)#">
                <cfinvokeargument name="info" value="#trim(arguments.info)#">
            </cfinvoke> 

            <cfinvoke method="setPageState">
                <cfinvokeargument name="idHistory" value="#page_struct_save.idHistory#">
                <cfinvokeargument name="state" value="approved">
                <cfinvokeargument name="comment" value="#arguments.comment#">
                <cfinvokeargument name="send_email" value="false">
            </cfinvoke>
        </cftransaction>

        <cfreturn page_struct_create.data.id>
    </cffunction>


	<cffunction name="createPage" access="remote" returnType="struct" returnFormat="JSON" output="false" hint="Creates a new page.">
		<cfargument name="idParent" type="numeric" required="true" hint="Parent ID of page being created"> 
        <cfargument name="title" type="string" default="New Page" required="false" hint="Title for the new page">
        <cfargument name="securityGroup" default="#application.securitygroups.default#" required="false" hint="Used when a page is created where a parent does not exist. example: from the root that is a static page"> 
		<cfargument name="id" type="numeric" required="false" hint="nasty override for importing existing content">

	    <cfset LOCAL.timestamp = now()>

        
        <!--- Get data for new page from peer page --->
        <CFQUERY DATASOURCE="#application.DataSource#" NAME="LOCAL.qPage">
            SELECT top 1 *
            FROM mrl_sitePublic
            WHERE idParent=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idParent#">
        </CFQUERY>

        <!--- try the parent page next --->
        <cfif LOCAL.qPage.getRowCount() eq 0>
            <!--- Get data for new page from parent page --->
            <CFQUERY DATASOURCE="#application.DataSource#" NAME="LOCAL.qPage">
                SELECT *
                FROM mrl_siteAdmin
                WHERE id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idParent#">
            </CFQUERY>
        </cfif>

        <!--- if neither parent or peer, use default --->
        <cfif LOCAL.qPage.getRowCount() eq 0>
        	<cfset LOCAL.securityGroup = "#arguments.securityGroup#">
            <cfset LOCAL.owner = "#session.auth.user.login#">
            <cfset LOCAL.template = "#application.defaultTemplate#">
        <cfelse>
        	<cfset LOCAL.securityGroup = "#LOCAL.qPage.securityGroup#">
            <cfset LOCAL.owner = "#LOCAL.qPage.owner#">
            <cfset LOCAL.template = "#LOCAL.qPage.template#">
		</cfif>        	

        <cfset LOCAL.attributesList = 'securityGroup, owner, idParent, idHistory, createdBy, createdDate, visible, state, deleted, template'>
        
        <cfif isDefined("arguments.id")>
            <cfset LOCAL.attributesList = "id, #LOCAL.attributesList#">
        </cfif>

		<!--- create stub page --->		    
	    <cfquery datasource="#application.DataSource#" name="LOCAL.qNewPage">
            <cfif isdefined("arguments.id")>
                SET IDENTITY_INSERT mrl_page ON            
            </cfif>

            INSERT INTO mrl_page (#LOCAL.attributesList#)
	        VALUES (
            <cfif isDefined("arguments.id")>
    			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">,
            </cfif>
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#LOCAL.securityGroup#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#LOCAL.owner#">,            		
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idParent#" null="#arguments.idParent eq ''#">,
	 		<cfqueryparam cfsqltype="cf_sql_integer" value="-1">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">,
	        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#LOCAL.timestamp#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="T">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="stub">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="F">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#LOCAL.template#">            			        
			)
            <cfif isdefined("arguments.id")>
                SET IDENTITY_INSERT mrl_page OFF            
            </cfif>

            SELECT SCOPE_IDENTITY() as id
	    </cfquery>  		

		<!--- create a history page --->
		<cfset LOCAL.pageInfo = savePage(state:'stub', id: qNewPage.id, idParent: idParent, title: arguments.title, info: '')> 
		
		<cfquery datasource="#application.DataSource#">
			UPDATE mrl_page
				SET idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#LOCAL.pageInfo.idHistory#">
				, state = 'stub'
			WHERE id = (select id from mrl_pageRevision where idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#LOCAL.pageInfo.idHistory#">)
		</cfquery>
			
		<!--- return the created id --->
        <cfset LOCAL.response = structNew()>
		<cfset LOCAL.response['success'] = true>
        <cfset LOCAL.response['data'] = structNew()>
        <cfset LOCAL.response['data'].id = LOCAL.qNewPage.id>	
		
        <cfreturn LOCAL.response>
	</cffunction> 	
	   
	<cffunction name="setPageState" access="remote" output="false" returnType="boolean" returnFormat="json">
		<cfargument name="idHistory">
        <cfargument name="state" hint="valid states: approved, preview, stub, denied, draft, pending">
        <cfargument name="comment" default="">
        <cfargument name="send_email" default=true>

        <cfset var currentTime = now()>
        <cfset var auth = createObject('component', '#application.componentRoot#.auth.cfc.auth')>
        <cfset var qDraftDetails = "">       
        <cfset var emailTo = "">

        <!--- make sure we are top level to approve --->
        <cfif arguments.state eq "approved" and NOT (isDefined("SESSION.Auth.groups.toplevel"))>
        	<cfreturn false>
        </cfif>

		<!--- get the page details --->
        <cfquery datasource="#application.datasource#" name="qDraftDetails">
        	select *, (select groupDesc from mrl_pageGroup where GroupName = mrl_siteHistory.securityGroup) as groupDesc 
            from mrl_siteHistory
            where idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#idHistory#">
        </cfquery>

        <cfset emailTo = application.site_config.CMS.mail>

        <!--- Add page owner to email list --->
        <cfif isValid('email', qDraftDetails.owner) 
            AND auth.isGroup(login: qDraftDetails.owner, groupname: 'approver')
            AND ListContainsNoCase(emailTo, qDraftDetails.owner)>
            
            <cfset ListAppend(emailTo, qDraftDetails.owner)>
        </cfif>
		
        <cfswitch expression="#arguments.state#">
			<!--- cancelled email code --->
            <cfcase value="cancel">
                <!--- get the last pending action --->
                <cfquery datasource="#application.datasource#" name="qLastPending">
                    select top 1 * from mrl_pageState 
                    where idHistory in (select idHistory from mrl_siteHistory where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qDraftDetails.id#">) and action = 'pending' 
                    and actionId > (select top 1 actionId from mrl_pageState where idHistory in (select idHistory from mrl_siteHistory where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qDraftDetails.id#">) and action = 'approved' or action = 'denied' order by actionDate desc)
                    order by actionDate desc
                </cfquery>           
               
                <!--- notifer the submitter that the article was cancelled --->
                <cfif qLastPending.getRowCount() eq 1>
                    <cfset emailTo = emailTo & ', #qLastPending.actionBy#, #session.auth.user.login#'>
                </cfif>
            
                <!--- generate the page link --->
                <cfset gUrl = "#application.web.editorroot#launch.cfm?#application.idvar#=#qDraftDetails.id#">				
                <cfset gUrlLink = "<a href='#gUrl#' target='_blank'>#qDraftDetails.title#</a>">	
            
                <!--- send the email --->
                <cfif arguments.send_email EQ true>                    
                    <cfmail to="#emailTo#" from="webmaster@example.com" type="html" subject="Cancelled Submission - ID: #qDraftDetails.id#  Title: #qDraftDetails.title#">
                        <img alt="email header" src="#application.web.editorroot#email/images/emailheader1.png"><br>
                        The following page's submission has been cancelled: <br><br>
                        Page ID: #qDraftDetails.id#<br>
                        Page Title: #qDraftDetails.title#<br>
                        Page Security Group: #qDraftDetails.groupDesc#<br><br>
                        Cancelled By: #session.auth.user.login#<br>
                        Cancelled Date: #DateFormat(currentTime, 'medium')# - #TimeFormat(currentTime, 'short')#<br><br>
                        Comments: #comment#<br><br>
                        Edit page: #gUrlLink# 	
                    </cfmail>
                </cfif>

            </cfcase>
            <!--- approved email code --->
            <cfcase value="approved">
    
                <!--- get the last pending action --->
                <cfquery datasource="#application.datasource#" name="qLastPending">
                    select top 1 * from mrl_pageState 
                    where idHistory in (select idHistory from mrl_siteHistory where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qDraftDetails.id#">) and action = 'pending' 
                    and actionId > (select top 1 actionId from mrl_pageState where idHistory in (select idHistory from mrl_siteHistory where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qDraftDetails.id#">) and action = 'approved' or action = 'denied' order by actionDate desc)
                    order by actionDate desc
                </cfquery>           
               
                <!--- notifer the submitter that the article was approved --->
                <cfif qLastPending.getRowCount() eq 1>
                    <cfset emailTo = emailTo & ', #qLastPending.actionBy#'>
                </cfif>
            
                <!--- generate the page link --->
                <cfset gUrl = "#replace(application.web.siteroot, 'https', 'http')##application.pagename#?#application.idvar#=#qDraftDetails.id#">				
                <cfset gUrlLink = "<a href='#gUrl#' target='_blank'>#qDraftDetails.title#</a>">	
            
                <!--- send the email --->
                <cfif arguments.send_email EQ true>                    
                    <cfmail to="#emailTo#" from="webmaster@example.com" type="html" subject="Approved - ID: #qDraftDetails.id#  Title: #qDraftDetails.title#">
                        <img alt="email header" src="#application.web.editorroot#email/images/emailheader1.png"><br>
                        The following page has been approved: <br><br>
                        Page ID: #qDraftDetails.id#<br>
                        Page Title: #qDraftDetails.title#<br>
                        Page Security Group: #qDraftDetails.groupDesc#<br><br>
                        Approved By: #session.auth.user.login#<br>
                        Approved Date: #DateFormat(currentTime, 'medium')# - #TimeFormat(currentTime, 'short')#<br><br>
                        Comments: #comment#<br><br> 
                        
                        Page Link: #gUrlLink#       	
                    </cfmail>
                </cfif>
            </cfcase>       	
    
            <!--- revert email code --->
            <cfcase value="revert">
                <cfset emailTo = emailTo & ', #session.auth.user.login#'>
            
                <!--- generate the page link --->
                <cfset gUrl = "#replace(application.web.siteroot, 'https', 'http')##application.pagename#?#application.idvar#=#qDraftDetails.id#">				
                <cfset gUrlLink = "<a href='#gUrl#' target='_blank'>#qDraftDetails.title#</a>">	
            
                <!--- send the email --->
                <cfif arguments.send_email EQ true>                    
                    <cfmail to="#emailTo#" from="webmaster@example.com" type="html" subject="Reverted - ID: #qDraftDetails.id#  Title: #qDraftDetails.title#">
                        <img alt="email header" src="#application.web.editorroot#email/images/emailheader1.png"><br>
                        The following page has been reverted: <br><br>
                        Page ID: #qDraftDetails.id#<br>
                        Page Title: #qDraftDetails.title#<br>
                        Page Security Group: #qDraftDetails.groupDesc#<br><br>
                        Reverted By: #session.auth.user.login#<br>
                        Reverted Date: #DateFormat(currentTime, 'medium')# - #TimeFormat(currentTime, 'short')#<br><br>
                        Comments: #comment#<br><br> 
                        
                        Page Link: #gUrlLink#       	
                    </cfmail>
                </cfif>
            </cfcase>
    
            <!--- denied (edit needed) email code --->
            <cfcase value="denied">
                <!--- get the last pending action --->
                <cfquery datasource="#application.datasource#" name="qLastPending">
                    select top 1 * from mrl_pageState 
                    where idHistory in (select idHistory from mrl_siteHistory where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qDraftDetails.id#">) and action = 'pending' 
                    and actionId > (select top 1 actionId from mrl_pageState where idHistory in (select idHistory from mrl_siteHistory where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qDraftDetails.id#">) and action = 'approved' or action = 'denied' order by actionDate desc)
                    order by actionDate desc
                </cfquery>           
               
                <!--- notifer the submitter that the article was approved --->
                <cfif qLastPending.getRowCount() eq 1>
                    <cfset emailTo = emailTo & ', #qLastPending.actionBy#'>
                </cfif>
            
                <!--- generate the page link --->
                <cfset gUrl = "#application.web.editorroot#launch.cfm?#application.idvar#=#qDraftDetails.id#">				
                <cfset gUrlLink = "<a href='#gUrl#' target='_blank'>#qDraftDetails.title#</a>">	
            
                <!--- send the email --->
                <cfif arguments.send_email EQ true>                    
                    <cfmail to="#emailTo#" from="webmaster@example.com" type="html" subject="Edits Needed - ID: #qDraftDetails.id#  Title: #qDraftDetails.title#">
                        <img alt="email header" src="#application.web.editorroot#email/images/emailheader1.png"><br>
                        The following page needs editing: <br><br>
                        Page ID: #qDraftDetails.id#<br>
                        Page Title: #qDraftDetails.title#<br>
                        Page Security Group: #qDraftDetails.groupDesc#<br><br>
                        Reviewed By: #session.auth.user.login#<br>
                        Reviewed Date: #DateFormat(currentTime, 'medium')# - #TimeFormat(currentTime, 'short')#<br><br>
                        Comments: #comment#<br><br> 
                        
                        Edit Page: #gUrlLink#       	
                    </cfmail>
                </cfif>
            </cfcase>       	
    
            <!--- pending email code --->
            <cfcase value="pending">
                <cfset emailTo = emailTo & ', #session.auth.user.login#'>
            
                <!--- generate the page link --->
                <cfset gUrl = "#application.web.editorroot#launch.cfm?state=pending&#application.idvar#=#qDraftDetails.id#">				
                <cfset gUrlLink = "<a href='#gUrl#' target='_blank'>#qDraftDetails.title#</a>">	    	
            
                <!--- send the email --->
                <cfif arguments.send_email EQ true>                    
                    <cfmail to="#emailTo#" from="webmaster@example.com" type="html" subject="Submitted - ID: #qDraftDetails.id#  Title: #qDraftDetails.title#">
                        <img alt="email header" src="#application.web.editorroot#email/images/emailheader1.png"><br>
                        The following page has been submitted for approval: <br><br>
                        Page ID: #qDraftDetails.id#<br>
                        Page Title: #qDraftDetails.title#<br>
                        Page Security Group: #qDraftDetails.groupDesc#<br><br>
                        Submitted By: #session.auth.user.login#<br>
                        Submitted Date: #DateFormat(currentTime, 'medium')# - #TimeFormat(currentTime, 'short')#<br><br>
                        
                        Link to edit/approve page: #gUrlLink#       	
                    </cfmail>
                </cfif>       	
            </cfcase>
		</cfswitch>

        <cftransaction>
    		<!--- if we approve if ourselves without a submit, also generate a submit --->
            <cfif state eq 'approved'>
            	<cfif qLastPending.getRowCount() eq 0>
    				<!--- add to the mrl_pageState table --->
                    <cfquery datasource="#application.datasource#">
                        INSERT INTO mrl_pageState(action, actionBy, actionDate, idHistory, id) 
                        VALUES (
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="pending">
                            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
                            ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#currentTime#">
                            ,<cfqueryparam cfsqltype="cf_sql_integer" value="#idHistory#">
                            ,<cfqueryparam cfsqltype="cf_sql_integer" value="#qDraftDetails.id#">
                        )
                    </cfquery>   
                </cfif>			
    		</cfif>
 
            <!--- add to the mrl_pageState table --->
            <cfquery datasource="#application.datasource#">
            	INSERT INTO mrl_pageState(action, actionBy, actionDate, idHistory, id) 
                VALUES (
                	<cfqueryparam cfsqltype="cf_sql_varchar" value="#state#">
                	,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
                    ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#currentTime#">
                    ,<cfqueryparam cfsqltype="cf_sql_integer" value="#idHistory#">
                    ,<cfqueryparam cfsqltype="cf_sql_integer" value="#qDraftDetails.id#">
                )
            </cfquery>   

      		<!--- change the 'real' state to draft if cancel --->
    		<cfif state eq 'revert'>
            	<cfset state = 'approved'>
            </cfif>
    		
    		<cfif state eq 'cancel'>
            	<cfset state = 'draft'>            
    		</cfif>
            	    
            <!--- update the page state --->        
            <cfquery datasource="#application.DataSource#">
            	UPDATE mrl_pageRevision
                	SET state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#state#">
                WHERE idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#idHistory#">
            </cfquery>


            
            <!--- add comment to the draft --->
            <cfif comment neq "">
                <cfquery datasource="#application.datasource#">
                    INSERT INTO mrl_pageComment(comment, commentBy, commentDate, idHistory, state)
                    VALUES (
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#comment#">
                        ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">
                        ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#currentTime#">
                        ,<cfqueryparam cfsqltype="cf_sql_integer" value="#idHistory#">
                        ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#state#">
                    )
                </cfquery>
    		</cfif>  
            
            <!--- if approved, we make this the new display page --->
            <cfif state eq "approved">
                <cfquery datasource="#application.DataSource#">
                    UPDATE mrl_page
                        SET idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#idHistory#">
                        , state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#state#">
                    WHERE id = (select id from mrl_pageRevision where idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#idHistory#">)
                </cfquery>
            <cfelse>
            	<cfif state neq "preview">
    				<cfquery datasource="#application.DataSource#">
    					UPDATE mrl_page
    						SET state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#state#">
    					WHERE id = (select id from mrl_pageRevision where idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#idHistory#">)
    				</cfquery>
                </cfif>        
    		</cfif>            
        </cftransaction>

        <!--- SEO crap - update the redirects table --->
        <cfif state eq 'approved'>            
    		<cfinvoke component="core.redirects" method="optimizeID" >
    			<cfinvokeargument name="page_id" value="#qDraftDetails.id#" >
    		</cfinvoke> 
        </cfif>
        
		<cfreturn true>		
    </cffunction>
	
    <!--- get the current page state --->
	<cffunction name="getPageState" access="private" returntype="any">
    	<cfargument name="id" type="numeric" required="yes">
		
        <cfquery datasource="#application.DataSource#" name="qState">
        	select state from mrl_siteAdmin where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#id#">
        </cfquery>
        
        <cfreturn qState.state>
    </cffunction>

    <!--- get the current page state --->
	<cffunction name="revertPage" access="remote" returntype="any">
    	<cfargument name="id" type="numeric" required="yes">
		
        <cfset currentTime = now()>
        
        <cfquery datasource="#application.DataSource#" name="qPageHistory">
			select idHistory from mrl_page where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
        </cfquery>
        
        <cfquery datasource="#application.DataSource#">
        	update mrl_pageRevision
            set usedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#currentTime#">
            where idHistory = <cfqueryparam cfsqltype="cf_sql_integer" value="#qPageHistory.idHistory#">
        </cfquery>
              
		<!--- revert the page --->
		<cfset setPageState(idHistory: qPageHistory.idHistory, state: 'revert')>
       
        <!--- SEO crap - update the redirects table --->
		<cfinvoke component="core.redirects" method="optimizeID" >
			<cfinvokeargument name="page_id" value="#arguments.id#" >
		</cfinvoke> 

        <cfreturn true>
    </cffunction>
		
	<cffunction name="savePage" access="remote" returnType="any" returnformat="JSON" output="false">
		<cfargument name="id" type="Numeric" required="true">
		<cfargument name="title" default="" required="true">
        <cfargument name="menu">
        <cfargument name="url">
		<cfargument name="info" required="true">
        <cfargument name="editSession" default="#Hash(now(), 'MD5')#">
		<cfargument name="state" default="draft" hint="valid states: approved, preview, stub, denied, draft, pending">
        <cfargument name="type" default="">
        <cfargument name="apps" default="">
        <cfargument name="appsDisplay" default="">
        
        <cfset var previousState = getPageState(id)>    
        <cfset var timestamp = "">
        <cfset var retStruct = structnew()>
        <cfset var qDraft = "">

        <!--- set menu text --->
        <cfif NOT isDefined("arguments.menu") or trim(arguments.menu) EQ ''>
          	<cfset arguments.menu = arguments.title>        
        </cfif>
     
        <!--- set url text --->
        <cfif NOT isDefined("arguments.url") or trim(arguments.url) EQ ''>
          	<cfset arguments.url = titleToUrl(arguments.menu)>        
        <cfelse>
           	<cfset arguments.url = titleToUrl(arguments.url)>
        </cfif>
               		
        <!--- Clean the info / content up.  remap SEO urls back to ids --->
        <cfinvoke component="marloo.core.pageHelper" method="SEOUrlsToId" returnvariable="arguments.info">
            <cfinvokeargument name="pageHTML" value="#arguments.info#">
            <cfinvokeargument name="site_config" value="#application.site_config#">
            <cfinvokeargument name="datasource" value="#application.datasource#">
        </cfinvoke>

        <!--- make sure we log the new state as a cancel if the previous was 'pending' --->
        <!--- WE - 11/20/2012 - was ... 'and type neq "preview"' --->
  		<cfif arguments.type neq "deny" and arguments.type neq "approved" and arguments.state neq "preview">
            <cfif previousState eq 'pending'>
                <cfset arguments.state="cancel">
            </cfif>
  		</cfif>          

        <cflock name="#application.applicationname#savePage" timeout="5" type="exclusive">

            <!--- create new draft --->
            <cfloop from="0" to="3" index="local.i">            
                <cfset local.saveError = false>
                <cfset timestamp = now()>
        	    <cftry>                
                <cfquery datasource="#application.DataSource#" name="qDraft">
        	    	INSERT INTO mrl_pageRevision (id, title, info, modifiedBy, modifiedDate, editSession, usedDate, menu, url, apps, appsDisplay)
        	        VALUES (
        		        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">,		
        		        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">,
        		        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.info#">,
        		 		<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.auth.user.login#">,
        		        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#timestamp#">,
        		        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.editSession#">,
                       	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#timestamp#">,
        		        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.menu#">,
        		        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.url#">,
        		        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.apps#" null="#arguments.apps eq ''#">,
        		        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.appsDisplay#" null="#arguments.appsDisplay eq ''#">
        	        )

                    SELECT SCOPE_IDENTITY() as idHistory
        	    </cfquery>
                <cfcatch>
                    <cfset local.saveError = true>
                    <cfif local.i EQ 3>
                        <!--- fail after 150 ms --->
                        <cfrethrow>                        
                        <cfabort>                      
                    </cfif>
                    <cfset sleep(50)>
                </cfcatch>
                </cftry>
                <cfif local.saveError EQ false>
                    <cfbreak>
                </cfif>
            </cfloop>
  
        </cflock>

   		<!--- Approve the page --->

   		<cfset setPageState(idHistory: qDraft.idHistory, state: state)>
		<cfset retStruct.ID = arguments.id>
		<cfset retStruct.IDHISTORY = qDraft.idHistory>
        <cfset retStruct.STATE = arguments.state>
		<cfset retStruct["success"] = true>  <!--- lowercase JSON keys for array notation!!!! WTF --->
		
        <cfreturn retStruct> 
	</cffunction>

<!---
    <cffunction name="mrl_pageStateInsert" returntype="numeric">
        <cfargument name="action" type="string" required="true" hint="valid states: approved, preview, stub, denied, draft, pending">
        <cfargument name="actionBy" type="string" required="true">
        <cfargument name="idHistory" type="numeric" required="true">
        <cfargument name="id" type="numeric" required="true">

        <cfset var qmrl_pageState = "">

        <!--- add to the mrl_pageState table --->
        <cfquery datasource="#application.datasource#" name="qPageAction">
            INSERT INTO mrl_pageState(action, actionBy, actionDate, idHistory, id) 
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action#">
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.actionBy#">
                ,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idHistory#">
                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
            )

            SELECT SCOPE_IDENTITY() as actionId
        </cfquery>   

        <cfreturn qPageAction.actionId>
    </cffunction>
--->

    <cffunction name="isValidPageState" returntype="boolean">
        <cfargument name="state" type="string" required="true">

        <cfset var found = ListFindNoCase(getValidPageStates(), arguments.state)>

        <cfif found gt 0>
            <cfreturn true>
        </cfif>

        <cfreturn false>
    </cffunction>

    <cffunction name="getValidPageStates" returntype="list">
        <cfreturn 'approved,preview,stub,denied,draft,pending'>
    </cffunction>

</cfcomponent>