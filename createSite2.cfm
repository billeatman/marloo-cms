<cfsetting requesttimeout="10000">

<!--- old-site import script --->

<!--- Reset db --->
<cfquery datasource="#application.datasource#">
	delete from mrl_loginHistory
	delete from mrl_userActivityLog
	delete from mrl_pageMoveLog
	delete from mrl_pageComment
	delete from mrl_pageState
	delete from mrl_pageRevision
	delete from mrl_page

	/* Reseed the identity columns on the page tables */
	DBCC CHECKIDENT (mrl_page, RESEED, 0)
	DBCC CHECKIDENT (mrl_pageRevision, RESEED, 0)
</cfquery>

<!--- Create Homepage --->
<cfquery datasource="old-site" name="qMarloo">
	select * from marloo 
	where page_id = '1'
</cfquery>

<cfinvoke method="pageImport">
	<cfinvokeargument name="parent_id" value="0">
	<cfinvokeargument name="title" value="#qMarloo.page_name#">
	<cfinvokeargument name="info" value="#convertLinks(qMarloo.page_info)#">
	<cfinvokeargument name="page_id" value="#qMarloo.page_ID#">
	<cfinvokeargument name="comment" value="old-site import">
</cfinvoke>

<!--- Create Primary Pages --->
<cfquery datasource="marloo-ds2" name="qMarloo">
	select * from marloo 
	where page_function = 'Primary'
</cfquery>

<cfloop query="qMarloo">
	<cfinvoke method="pageImport">
		<cfinvokeargument name="parent_id" value="1">
		<cfinvokeargument name="title" value="#qMarloo.page_name#">
		<cfinvokeargument name="info" value="#convertLinks(qMarloo.page_info)#">
		<cfinvokeargument name="page_id" value="#qMarloo.page_ID#">
		<cfinvokeargument name="comment" value="old-site import">
	</cfinvoke>
</cfloop>

<!--- Create Secondary Page --->
<cfinvoke method="pageImport" returnvariable="secondary_page_id">
	<cfinvokeargument name="parent_id" value="1">
	<cfinvokeargument name="title" value="SECONDARY">
	<cfinvokeargument name="info" value="DO NOT MOVE OR DELETE :-)">
	<cfinvokeargument name="page_id" value="823">
	<cfinvokeargument name="comment" value="old-site import">
</cfinvoke>

<!--- Import Secondary Pages --->
<cfquery datasource="marloo-ds2" name="qMarloo">
	select * from marloo 
	where page_function = 'Secondary'
</cfquery>

<cfloop query="qMarloo">
  	<cftry>
	<cfinvoke method="pageImport">
		<cfinvokeargument name="parent_id" value="#secondary_page_id#">
		<cfinvokeargument name="title" value="#trim(qMarloo.page_name)#">
		<cfinvokeargument name="info" value="#convertLinks(qMarloo.page_info)#">
		<cfinvokeargument name="page_id" value="#qMarloo.page_ID#">
		<cfinvokeargument name="comment" value="old-site import">
	</cfinvoke>
	<cfcatch>
	  	<!--- add a one to the title for duplicate pages --->
		<cfinvoke method="pageImport">
			<cfinvokeargument name="parent_id" value="#secondary_page_id#">
			<cfinvokeargument name="title" value="#trim(qMarloo.page_name)#1">
			<cfinvokeargument name="info" value="#convertLinks(qMarloo.page_info)#">
			<cfinvokeargument name="page_id" value="#qMarloo.page_ID#">
			<cfinvokeargument name="comment" value="old-site import">
		</cfinvoke>
	</cfcatch>
	</cftry>
</cfloop>

<!--- set new page owner --->	
<cfinvoke component="assets.ajax.pagemanager" method="setAttributes" returnvariable="page_owner_change">
	<cfinvokeargument name="page_id" value="1">
	<cfinvokeargument name="attribute" value="owner">
	<cfinvokeargument name="value" value="owner@example.com">
	<cfinvokeargument name="recursive" value="true">
</cfinvoke>

<!--- import page --->
<cffunction name="pageImport" returntype="numeric">
	<cfargument name="parent_id" type="numeric" required="false" default="#application.tree.rootid#">
	<cfargument name="title" type="string" required="true">
	<cfargument name="info"	type="string" required="true">
	<cfargument name="page_id" type="numeric" required="false">
	<cfargument name="comment" type="string" required="false" default="">
	<cfargument name="visible" type="boolean" required="false" default="true">

	<cfset var page_struct_create = "">
	<cfset var page_struct_save = "">

	<cftransaction>
		<cfinvoke component="assets.ajax.process" method="createPage" returnvariable="page_struct_create">
			<cfinvokeargument name="idparent" value="#arguments.parent_id#">
		  	<cfif isDefined("arguments.page_id")>
			  	<cfinvokeargument name="id" value="#arguments.page_id#">    		
		  	</cfif>
		</cfinvoke>	

		<cfinvoke component="assets.ajax.process" method="savePage" returnvariable="page_struct_save">
			<cfinvokeargument name="id" value="#page_struct_create.data.id#">
			<cfinvokeargument name="title" value="#trim(arguments.title)#">
			<cfinvokeargument name="info" value="#trim(arguments.info)#">
		</cfinvoke>	

		<cfinvoke component="assets.ajax.process" method="setPageState">
			<cfinvokeargument name="idHistory" value="#page_struct_save.idHistory#">
			<cfinvokeargument name="state" value="approved">
			<cfinvokeargument name="comment" value="#arguments.comment#">
			<cfinvokeargument name="send_email" value="false">
		</cfinvoke>
	</cftransaction>

	<cfif arguments.visible EQ false>		
		<cfinvoke component="assets.ajax.pageManager" method="setAttributes">
			<cfinvokeargument name="page_id" value="#arguments.page_id#">
			<cfinvokeargument name="attribute" value="#visible#">
			<cfinvokeargument name="value" value="F">
		</cfinvoke>
	</cfif> 


	<cfreturn page_struct_create.data.id>
</cffunction>

<!--- convert old links --->
<cffunction name="convertLinks" returntype="string">
	<cfargument name="info">
	<cfset var myinfo = arguments.info>

	<cfset myinfo = replaceNoCase(myinfo, 'marloo.cfm', 'page.cfm', "all")>

	<cfreturn myinfo>
</cffunction>



