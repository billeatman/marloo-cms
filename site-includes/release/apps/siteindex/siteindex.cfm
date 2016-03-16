<cfsilent>
<cfparam name="letter" type="string" default=""> 

<cfsavecontent variable="headCode">
<!-- Site Index App -->
<script src="app-assets/siteindex/dimensions.js" type="text/javascript"></script>
<script src="app-assets/siteindex/autocomplete.js" type="text/javascript"></script>

<script type="text/javascript">
	$(function(){
	    setAutoComplete("searchField", "results", "app-assets/siteindex/livesearch.cfc?method=search&returnFormat=json");
		<cfoutput>
			acSearchField.val('#letter#');
			autoComplete('#letter#');
		</cfoutput>
	});
</script>
<!-- END OF - Site Index App -->
</cfsavecontent>

<cfset AddHTMLHead(headCode)>

<!---	<h1>CTX A-Z Index</h1> --->
</cfsilent>
<div class="alpha">
	<!--- create the a - z ahref listing --->
	<cfloop index="i" from="65" to="90">
	<cfoutput>
	<a href="#ph.getCurrentUrl()###" onClick="acSearchField.val('#chr(i)#'); autoComplete('#chr(i)#');" class="bold">#chr(i)#</a> 
	</cfoutput>
	</cfloop>

	<p>
		<label for="searchField">Search for a page: </label>
		<input id="searchField" name="searchField" type="text"/>
	</p>
</div>    
<div id="results">
</div>
