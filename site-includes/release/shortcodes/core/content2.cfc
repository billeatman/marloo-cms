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
	<cfset local.forBucket = structNew()>

	<script type="text/javascript">
	var toggleMobileDisplay = function(contentForSnaps) {
		var wWidth = $(window).width();
		$.each(contentForSnaps, function(loc,snap) {
			var desktopLoc = $('.' + loc + '.dynamicFor');
			var mobileLoc = $('.' + loc + '.staticFor');
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
			// check bucket of 'for' keys to see if it's a first contentFor - CM / WE'
			console.log('contentForSnaps', contentForSnaps);
			var setDataSnap = $('##for-#local.index.for#').attr('data-snappoint');
			console.log(setDataSnap);
			if (typeof setDataSnap != 'undefined') {
				if ('for-#local.index.for#' in contentForSnaps) {}
				else {
					var snapPoint = $('##for-#local.index.for#').data('snappoint');
					contentForSnaps['for-#local.index.for#'] = snapPoint;
				}
				console.log('AFTER', contentForSnaps);
			<cfif NOT structKeyExists(local.forBucket, local.index.for)>
				// names IDfor's parent .for-area
				$('##for-#local.index.for#').parent().addClass('for-#local.index.for# dynamicFor');
				// clones each UUID (unique content items):
				// 1. one for inside content to see on mobile / static - original
				// 2. one to see when on desktop - clone
				// remove 'static' class on cloned (desktop/dynamic) one 
				// add 'dynamic' class on cloned one
				// then append it (add it) to IDfor and remove/unwrap the IDfor div
				$('###local.index.UUID#').addClass('for-#local.index.for# staticFor').clone().removeClass('for-#local.index.for# staticFor').appendTo('##for-#local.index.for#').unwrap();
			
			<cfelse>
			// for multiple contentFors - duplicates parent container - CM / WE
				//clone the last (i.e., a single) content container, empty it, remove its classes so that it's not confused about where to append it, then add those classes back
				console.log( $('.for-#local.index.for#.dynamicFor').last() );
				var duplicateContainer = $('.for-#local.index.for#.dynamicFor').last().clone().empty().removeClass('for-#local.index.for# dynamicFor').appendTo( ($('.for-#local.index.for#')).parent() ).addClass('for-#local.index.for# dynamicFor');
				// then clone the UUID like with first content UUID, remove the static class, add to newly created container
				// fast forward: a few lines down in the code, unwrap UUID div
				$('###local.index.UUID#').addClass('for-#local.index.for# staticFor').clone().removeClass('for-#local.index.for# staticFor').appendTo(duplicateContainer);
			</cfif>
			// removes the UUID on each original static 'placeholder' div
			$('###local.index.UUID#.staticFor').removeAttr('id');
			// unwrap UUID div from dynamicFor content
			$('.dynamicFor ###local.index.UUID# > *').unwrap();
			<!--- WE - Moved this to template.cfc because the container can be
			used independent from the shortcode   
			// removes empty 'for' containers - CM / WE
			$('.forContainer:empty').parent().remove();
			--->
			} else {
			// check bucket of 'for' kys teo see if it's a first contentFor - CM / WE
			console.log( $('.for-#local.index.for#.dynamicFor').last() );
			<cfif NOT structKeyExists(local.forBucket, local.index.for)>
				$('##for-#local.index.for#').parent().addClass('for-#local.index.for#');
				$('###local.index.UUID#').appendTo('##for-#local.index.for#').unwrap();
				// creates structKey
				<cfset local.forBucket["#local.index.for#"] = true>
			<cfelse>
			// for multiple contentFors - duplicates parent container - CM / WE
				var duplicateContainer = $('.for-#local.index.for#:last').clone().empty().removeClass('for-#local.index.for#').appendTo( ($('.for-#local.index.for#')).parent() );
				$('###local.index.UUID#').appendTo(duplicateContainer);
			</cfif>
			$('###local.index.UUID# > *').unwrap();
			<!--- WE - Moved this to template.cfc because the container can be
			used independent from the shortcode   
			// removes empty 'for' containers - CM / WE
			$('.forContainer:empty').parent().remove();
			--->
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
		<!---added class for to make this div a placeholder on mobile--->
		<div id='#local.UUID#'>#arguments.s_content#</div>
	</cfsavecontent>
	</cfoutput>

    <cfreturn arguments.s_content>
</cffunction>

</cfcomponent>