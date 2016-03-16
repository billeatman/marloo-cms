<cfsetting requesttimeout="10000">

<!--- Change to admission ds and get all the example pages --->
<cfset application.datasource = "oldmarloo-ds">

<cfquery datasource="oldmarloo-ds" name="qOldMarloos">
	select *
	from mrl_siteAdmin
	where deleted != 'T'
</cfquery>

<!--- Change back to the original site ds --->
<cfset application.datasource = "marloo-ds">

<cfset pages = importSiteTree(
	qSourcePages: qOldMarloos,
	srcParentId: 0,
	dstParentId: 234)>

<cfdump var="#pages#">

<cfabort>

<cffunction name="importSiteTree" output="true" hint="recursively import pages by level" returntype="any">
	<cfargument name="qSourcePages" type="query" required="true" hint="the raw pages source query">
	<cfargument name="srcParentId" type="numeric" required="true" hint="the source parent id">
	<cfargument name="dstParentId" type="numeric" required="true" hint="the destination parent id">
	<cfargument name="imported" type="struct" required="false" hint="You can ignore this argument.  It is used by the function recursively">

	<cfset var page = structNew()>
	<cfset var qlevel = "">

	<cfif NOT isDefined("arguments.imported")>
		<cfset arguments.imported = structNew()>
		<cfset arguments.imported.pages = arrayNew(1)> 
	</cfif>

	<!--- get the first level of pages from the source tree --->
	<cfquery dbtype="query" name="qLevel">
		select * from arguments.qSourcePages
		where idParent = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.srcParentId#">	
	</cfquery>

	<!--- bail out if the level is empty --->
	<cfif qLevel.recordCount EQ 0>
		<cfreturn imported>
	</cfif>

	<cfloop query="qLevel">
		<cfset page.id = qLevel.id>

		<cfinvoke method="pageImport" returnvariable="page.NEW_ID">
			<cfinvokeargument name="parent_id" value="#arguments.dstParentId#">
			<cfinvokeargument name="title" value="#qLevel.title#">
			<cfinvokeargument name="info" value="#qLevel.info#">
			<cfinvokeargument name="comment" value="example site import">
			<!--- you can pass any global attribute as well --->
			<!---
			<cfinvokeargument name="idshortcut" value="#qLevel.idshortcut#">
			<cfinvokeargument name="shortcuttype" value="#qLevel.shortcuttype#">
			<cfinvokeargument name="shortcutexternal" value="#qLevel.shortcutexternal#">
			--->

			<cfinvokeargument name="state" value="#qLevel.state#">
			<cfinvokeargument name="visible" value="#qLevel.visible#"> 
			<cfinvokeargument name="createddate" value="#qLevel.createddate#">
			<cfinvokeargument name="createdby" value="#qLevel.createdby#">
<!---			<cfinvokeargument name="deleted" value="#qLevel.deleted#"> --->
			<cfinvokeargument name="locked" value="#qLevel.locked#">
			<cfinvokeargument name="lockedby" value="#qLevel.lockedby#">
			<cfinvokeargument name="lockeddate" value="#qLevel.lockeddate#">
<!---			<cfinvokeargument name="idhistory" value="#qLevel.idhistory#"> --->
<!---			<cfinvokeargument name="idparent" value="#qLevel.idparent#"> --->

<!---			<cfinvokeargument name="securitygroup" value="#qLevel.securitygroup#"> --->
			<cfinvokeargument name="quicklink" value="#qLevel.quicklink#">
			<cfinvokeargument name="app" value="#qLevel.app#">
			<cfinvokeargument name="gmodifiedby" value="#qLevel.gmodifiedby#">
			<cfinvokeargument name="gmodifieddate" value="#qLevel.gmodifieddate#">
			<cfinvokeargument name="owner" value="#qLevel.owner#">
			<!--- <cfinvokeargument name="template" value="#qLevel.template#"> --->
			<!--- new attributes with 6.0.0 beta 2 --->
			<cfinvokeargument name="reviewedBy" value="#qLevel.reviewedBy#">
			<cfinvokeargument name="reviewedDate" value="#qLevel.reviewedDate#">
			<cfinvokeargument name="SSL" value="#qLevel.SSL#">
		</cfinvoke>

		<!--- add the page to the list of imported pages --->
		<cfset arrayAppend(arguments.imported.pages, page)>

		<cfset importSiteTree(
			qSourcePages: arguments.qSourcePages, 
			srcParentId: page.id, 
			dstParentId: page.new_id, 
			imported: arguments.imported)>
	</cfloop>

	<cfreturn arguments.imported.pages>

</cffunction>

<!--- import page --->
<cffunction name="pageImport" returntype="numeric">
	<cfargument name="parent_id" type="numeric" required="false" default="#application.tree.rootid#">
	<cfargument name="title" type="string" required="true">
	<cfargument name="info"	type="string" required="true">
	<cfargument name="page_id" type="numeric" required="false">
	<cfargument name="comment" type="string" required="false" default="">

	<cfset var page_struct_create = "">
	<cfset var page_struct_save = "">
	<cfset var retval = "">
	<cfset var attribute = "">

	<cftransaction>
		<cfinvoke component="assets.ajax.process" method="createPage" returnvariable="pageCreate">
			<cfinvokeargument name="idparent" value="#arguments.parent_id#">
		  	<cfif isDefined("arguments.page_id")>
			  	<cfinvokeargument name="id" value="#arguments.page_id#">    		
		  	</cfif>
		</cfinvoke>	

		<cfinvoke component="assets.ajax.process" method="savePage" returnvariable="pageSave">
			<cfinvokeargument name="id" value="#pageCreate.data.id#">
			<cfinvokeargument name="title" value="#trim(arguments.title)#">
			<cfinvokeargument name="info" value="#trim(arguments.info)#">
		</cfinvoke>	

		<cfinvoke component="assets.ajax.process" method="setPageState">
			<cfinvokeargument name="idHistory" value="#pageSave.idHistory#">
			<cfinvokeargument name="state" value="approved">
			<cfinvokeargument name="comment" value="#arguments.comment#">
			<cfinvokeargument name="send_email" value="false">
		</cfinvoke>
	</cftransaction>
	

	<!--- set any global attributes that are passed --->
	<cfloop collection="#arguments#" item="attribute">
		<!--- ignore the arguments listed above --->
		<cfif ListFindNoCase("parent_id,title,info,page_id,comment", attribute) NEQ 0>
			<cfcontinue>
		</cfif>

		<cftry>
			
		<cfif NOT isNull(arguments[attribute])>
		
		<cfinvoke component="assets.ajax.pageManager" method="setAttributes" returnvariable="retval">
			<cfinvokeargument name="page_id" value="#pageCreate.data.id#">
			<cfinvokeargument name="attribute" value="#attribute#">
			<cfinvokeargument name="value" value="#arguments[attribute]#">
		</cfinvoke>

		</cfif>

		<cfcatch>
		<cfrethrow>			
		<cfdump var="#attribute#, #arguments[attribute]#, #cfcatch.message#">
		<cfabort>
		</cfcatch>
		</cftry>

		<cfif retval[1].success EQ false>
			<cfthrow message="invalid attribute - #attribute#">
		</cfif>
	</cfloop>


	<cfreturn pageCreate.data.id>
</cffunction>

<!--- convert old links --->
<cffunction name="convertLinks" returntype="string">
	<cfargument name="info">
	<cfset var myinfo = arguments.info>

	<cfset myinfo = replaceNoCase(myinfo, 'example.cfm', 'page.cfm', "all")>

	<cfreturn myinfo>
</cffunction>

