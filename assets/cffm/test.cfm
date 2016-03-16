
<cfdirectory action="list" directory="#ExpandPath(".")#/custom" recurse="false" name="test">

<cfdump var="#test#">



	<cfset path="">
	<cfset temp="">

		<cfdirectory name="temp" directory="#ExpandPath(".")#/custom" action="list" recurse="false">

		<!--- We loop through until done recursing drive --->
		<cfif not isDefined("dirInfo")>
			<cfset dirInfo = queryNew("attributes,datelastmodified,mode,name,size,type,directory,fullPath")>
		</cfif>
		<cfset thisDir = temp> <!--- directoryList(directory,false)> --->
		<cfif server.os.name contains "Windows">
			<cfset path = "\">
		<cfelse>
			<cfset path = "/">
		</cfif>
		<cfloop query="thisDir">
			<cfset queryAddRow(dirInfo)>
			<cfset querySetCell(dirInfo,"attributes",attributes)>
			<cfset querySetCell(dirInfo,"datelastmodified",datelastmodified)>
			<cfset querySetCell(dirInfo,"mode",mode)>
			<cfset querySetCell(dirInfo,"name",name)>
			<cfset querySetCell(dirInfo,"size",size)>
			<cfset querySetCell(dirInfo,"type",type)>
			<cfset querySetCell(dirInfo,"directory",directory)>
			<Cfset querySetCell(dirInfo,"fullPath", directory & path & name)>	
		</cfloop>
		
		<cfdump var="#dirInfo#">
		<cfform>
<cfgrid name = "FirstGrid" format="html"
        height="320" width="580"
        font="Tahoma" fontsize="12"
        query = "thisDir">
    </cfgrid>
</cfform>
	


