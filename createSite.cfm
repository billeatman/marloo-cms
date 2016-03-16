<cfsetting requesttimeout="10000">

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

<cfinvoke method="pageImport">
	<cfinvokeargument name="parent_id" value="0">
	<cfinvokeargument name="title" value="Home Page Stub">
	<cfinvokeargument name="info" value="Hello World">
	<cfinvokeargument name="comment" value="create site">
</cfinvoke>

<!--- import page --->
<cffunction name="pageImport" returntype="numeric">
	<cfargument name="parent_id" type="numeric" required="false" default="#application.tree.rootid#">
	<cfargument name="title" type="string" required="true">
	<cfargument name="info"	type="string" required="true">
	<cfargument name="page_id" type="numeric" required="false">
	<cfargument name="comment" type="string" required="false" default="">

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
 
	<cfreturn page_struct_create.data.id>
</cffunction>

<!--- convert old links --->
<cffunction name="convertLinks" returntype="string">
	<cfargument name="info">
	<cfset var myinfo = arguments.info>

	<!--- replace strings here --->

	<cfreturn myinfo>
</cffunction>



