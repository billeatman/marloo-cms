<!--- WE - 08/13/2014 --->

<!--- Content For ALPHA --->

<cfcomponent extends="marloo.shortcode">

<cfset variables.contentIdentifiers = "">

<cffunction name="init" output="false" returntype="ANY">
	<cfset variables.contentIdentifiers = arrayNew(1)>
	<cfset super.init(argumentCollection: arguments)>
	<cfreturn this>
</cffunction>

<cffunction name="renderHeadOnce" output="true">

<!---
THE CONTENT SHORTCODE - WE / CM
allows editors to put content onto other areas on the page other than div.content
dynamically in the Marloo CMS

GETTING STARTED
Add this code in the template HTML, inside the element tags you want to keep the content in:
<cfset renderFor('side',750)>
You can name the area (ex. 'side') whatever you want. 750 is the snap point (optional);
on our responsive site, when window <= 750px, it's better that the content moves back
to where it was entered by the editor in Marloo CMS.

OTHER CODE WRITTEN FOR THIS SHORTCODE
• template.cfc
- renderFor function - makes the original container that the content will eventually be nested in, 
looks like when first generated:
<div id="for-side" [data-snappoint="750"] class="forContainer" />
- renderHead JS script - removes the empty .forContainers
• w3_base.css
- styles .hideFor to be display:none;
- also has the snap point styling via media queries

BEFORE SCRIPT:
- The side Container
<article>
<div id="for-side" [data-snappoint="750"] class="forContainer"></div>
</article>
- The original content div
<div id="UUIDhash"></div>

AFTER SCRIPT (w/ snap points):
- The side Container
<article class="for-side-container dynamicFor"> // hidden when window is small
	cloned content here
</article>
- The original content div, now a placeholder
<div class="for-side-placeholder staticFor"> // hidden when window is large
	original content that was cloned
</div>

AFTER SCRIPT (w/o snap points) - legacy:
- The side Container
<article class="for-side">
	content moved completely
</article>
- The original content div was moved over

--->

<cfset local.forBucket = structNew()>

<script type="text/javascript">
<!--- checks snap points and changes toggles display of content accordingly --->
var toggleMobileDisplay = function(contentForSnaps) {
	var wWidth = $(window).width();
	$.each(contentForSnaps, function(loc,snap) {
		<!--- where it is within --->
		var desktopLoc = $('.' + loc + '-container.dynamicFor');
		var mobileLoc = $('.' + loc + '-placeholder.staticFor');
		if (wWidth <= snap) {  // mobile/tablet
			desktopLoc.addClass('hideFor');
			mobileLoc.removeClass('hideFor');
		}
		else {
			mobileLoc.addClass('hideFor');
			desktopLoc.removeClass('hideFor');
		}
	});
}
$(document).ready(function() {
	var contentForSnaps = {};
	<cfloop array="#variables.contentIdentifiers#" index="local.index">
	
	var dataAttr = $('##for-#local.index.for#').attr('data-snappoint');
	<!--- checks to see if snap point specified --->
	if (typeof dataAttr != 'undefined') {
		<!--- if it is, it's stored --->
		var snapPoint = $('##for-#local.index.for#').data('snappoint');
		contentForSnaps['for-#local.index.for#'] = snapPoint;
	}
<!--- USING SNAP POINTS? --->
<!--- YES --->
	if (contentForSnaps['for-#local.index.for#'] != null) {
	<!--- check bucket of 'for' keys to see if it's a first contentFor - CM / WE --->
	<cfif NOT structKeyExists(local.forBucket, local.index.for)>
<!--- for first contentFor - CM / WE --->
		<!--- parent renames itself and eats ##for-area to become first .for-area --->
		$('##for-#local.index.for#').parent().addClass('for-#local.index.for#-container dynamicFor').empty();
		var $firstContainer = $('.for-#local.index.for#-container');
		var $container = $firstContainer;
	<cfelse>
<!--- for multiple contentFors - CM / WE --->
		<!--- a .for-area is cloned and added with other .for-areas --->
		var $duplicateContainer = $firstContainer.last().clone().empty().removeClass('for-#local.index.for#-container dynamicFor').appendTo( ($('.for-#local.index.for#-container')).parent() ).addClass('for-#local.index.for#-container dynamicFor');
		var $container = $duplicateContainer;
	</cfif>
	<!--- original content div is cloned and appended to .for-area but distinguished by classes --->
	$('###local.index.UUID#').addClass('for-#local.index.for#-placeholder staticFor').clone().removeAttr('class').appendTo($container).addClass('for-#local.index.for#');
	<!--- removes the UUID  on dynamic and static --->
	$('.dynamicFor ###local.index.UUID# > *').unwrap();
	$('###local.index.UUID#.staticFor').removeAttr('id');
	} 
<!--- NO --->
	else {
<!--- check bucket of 'for' keys to see if it's a first contentFor - CM / WE --->
	<cfif NOT structKeyExists(local.forBucket, local.index.for)>
		<!--- parent element renamed .for-area --->
		$('##for-#local.index.for#').parent().addClass('for-#local.index.for#');
		<!--- original content area nests within ##for-area, then eats its way out --->
		$('###local.index.UUID#').appendTo('##for-#local.index.for#').unwrap();
		<!--- creates structKey --->
		<cfset local.forBucket["#local.index.for#"] = true>
	<cfelse>
<!--- for multiple contentFors - duplicates parent container - CM / WE --->
		var duplicateContainer = $('.for-#local.index.for#:last').clone().empty().removeClass('for-#local.index.for#').appendTo( ($('.for-#local.index.for#')).parent() ).addClass('for-#local.index.for#');
	<!--- original content div moved to new container --->
		$('###local.index.UUID#').appendTo(duplicateContainer);
	</cfif>
	<!--- UUID hash removed --->
	$('###local.index.UUID# > *').unwrap();
	}
	</cfloop>
	toggleMobileDisplay(contentForSnaps);

	$(window).resize(function() {
		toggleMobileDisplay(contentForSnaps);
	});
});
	</script>
</cffunction>	

<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="s_content" required="false" default="">
	<cfargument name="for" required="true" type="string" hint="content identifier (bottom, side, sideB)">

	<cfset arguments.for = trim(lcase(arguments.for))>
	<cfset local.UUID = CreateUUID()>

	<cfset local.identifier = structNew()>
	<cfset local.identifier.uuid = local.UUID>
	<cfset local.identifier.for = arguments.for>
	<cfset arrayAppend(variables.contentIdentifiers, local.identifier)>

	<cfoutput>
	<cfsavecontent variable="arguments.s_content">
		<div id='#local.UUID#'>#arguments.s_content#</div>
	</cfsavecontent>
	</cfoutput>

    <cfreturn arguments.s_content>
</cffunction>

</cfcomponent>