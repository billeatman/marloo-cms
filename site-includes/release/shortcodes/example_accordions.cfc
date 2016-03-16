<cfcomponent extends="marloo.shortcode">

<!---
DERIVED FROM TABS SHORTCODE 
which was reproduced into Limber Responsive Tabs:
https://github.com/caitlinmarkert/limber-responsive-tabs

Copied the same code from the Tabs / Tab files for consistency
--->

<cffunction name="renderHeadOnce" output="true">
<style type="text/css">
.limber-tabs {
	display: block;
	max-width: 100%;
	position: relative;
}
.limber-tabs * {
	max-width: 100% !important;
}
.limber-nav, .limber-title {
	overflow: visible;
	display: none;
}
.limber-tabs hr {
	position: absolute;
	margin: 0;
	transition: all .25s 0s;
	-o-transition: all .25s 0s;
	-ms-transition: all .25s 0s;
	-moz-transition: all .25s 0s;
	-webkit-transition: all .25s 0s;
	z-index: 5;
}
.limber-tab {
	display: block;
	padding: 0;
	overflow: hidden;
	position: relative;
}
.limber-tab .limber-content {
	height: 0;
	overflow: hidden;
	padding: 0 .5em;
}
.limber-tab.open .limber-content {
	height: auto;
	padding: 1em .5em;
}
/* mini [mobile] */
.limber-tabs.mini {
	margin-left: .5em;
}
.limber-tabs.mini hr {
	border-left: .25em solid;
	border-right: .15em solid;
	border-top: 0;
	border-bottom: 0;
	margin-left: -.5em;
	width: 0 !important;
}
.limber-tabs.mini .limber-tab {
	border-right: .09em solid;
}
.limber-tabs.mini .limber-title {
	position: relative;
	display: block;
	padding: .5em;
	padding-right: 1.5em;
	border-top: .09em solid;
	font-size: 1.25em;
}
.limber-tabs.mini {
	border-bottom: .09em solid;
}
.limber-tabs.mini .limber-tab.open .limber-title {
	font-weight: 700;
}
.limber-tabs.mini .limber-title:before, .limber-tabs.mini .limber-title:after {
	position: absolute;
	display: block;
	content: ' ';
	width: .1em;
	height: .75em;
}
.limber-tabs.mini .limber-title:before {
	right: 1em;
	top: .75em;
	-ms-transform: rotate(45deg);
	-moz-transform: rotate(45deg);
	-webkit-transform: rotate(45deg);
	transform: rotate(45deg);
}
.limber-tabs.mini .limber-title:after {
	top: .75em;
	right: 1.5em;
	-ms-transform: rotate(135deg);
	-moz-transform: rotate(135deg);
	-webkit-transform: rotate(135deg);
	transform: rotate(135deg);
}
.limber-tabs.mini .limber-tab.open .limber-title:before {
	right: 1.5em;
}
.limber-tabs.mini .limber-tab.open .limber-title:after {
	right: 1em;
}
/* max [desktop] */
.limber-tabs.max {
	border-radius: 4px;
	border: .1em solid;
}
.limber-tabs.max .limber-nav {
	display: block;
}
.limber-tabs.max .limber-nav a {
	display: inline-block;
	padding: .5em 1em;
	border-left: 1px solid rgb(180,180,180);
}
.limber-tabs.max .limber-nav a:first-of-type {
	padding-left: .5em;
	border-left: 0;
}
.limber-tabs.max .limber-nav a.open {
	font-weight: 700;
}
.limber-tabs.max hr {
	border-top: .25em solid;
	border-bottom: .25em solid;
	border-left: 0;
	border-right: 0;
	height: auto !important;
	top: auto !important;
}
/* color preferences */
/* DEFAULT */
.limber-tabs.mini .limber-tab:nth-of-type(odd) .limber-title, 
.limber-tabs.max .limber-nav {
	background-color: rgb(205,205,205);
}
.limber-tabs.mini .limber-tab:nth-of-type(even) .limber-title {
	background-color: rgb(245,245,245);
}
.limber-tabs,
.limber-tabs.mini .limber-tab, 
.limber-tabs.mini .limber-title {
	border-color: rgba(0,0,0,.2) !important;
}
.limber-tab.open .limber-content {
	background-color: rgb(255,255,255);
}
.limber-tabs.mini .limber-title:before, .limber-tabs.mini .limber-title:after {
	background-color: rgb(100,100,100) !important;
}
.limber-tabs.mini .limber-title:after {
	color: rgb(100,100,100) !important;
}
.limber-tabs.mini .limber-title, .limber-tabs.max .limber-nav a {
	color: rgb(0,0,0);
	text-decoration: none;
}
.limber-tabs hr {
	border-color: rgb(79,38,131) !important;
}
@media print {
	.limber-tabs .limber-tab, .limber-tabs.open .limber-tab, .limber-tab .limber-title, .limber-tab .limber-content {
		display: block !important;
		height: auto !important;
		overflow: auto !important;
	}
	.limber-tabs :before, .limber-tabs :after {
		display: none !important;
	}
	.limber-tabs .limber-title {
		font-weight: 900 !important;
		font-size: 1.05em !important;
	}
	.limber-tabs .limber-nav {
		display: none !important;
	}
}
</style>

<script language="javascript">
(function(limberTabs, $, undefined) {

	var initTabs = function() {
		var newID = 1;

		$('.limber-tabs').each(function() {
			// initialize tabs ID -> tabs1, tabs2++ unless already has ID
			var tID = $(this).attr('id');
			if (tID == undefined) {
				$(this).attr('id','tabs' + newID);
				++newID;
			}
			
			// mobile (starts setting up elements)
			$(this).find('.limber-tab').each( function() {
				$(this).wrapInner('<div class="limber-content"></div>');
				$(this).find('.limber-title').prependTo($(this));
			});
			
			// initialize tabs NAMEs (creates anchors, links for each tab using tab's title)
			var tID = $(this).attr('id');
			$('##'+ tID +' .limber-title').each(function() {
				var tabN = tID + '-' + $(this).text().replace(/ /g,'');
				$(this).attr('href','##' + tabN);
				$(this).attr('name',tabN);
				$(this).wrapInner('<a class="limber-title" href="#getCurrentURL()###' + tabN + '" name="' + tabN + '"></a>').children().unwrap();
			});
			
			// desktop
			$(this).prepend($('<hr />'));
			/*$(this).prepend($('<div class="limber-nav"></div>'));
			$('##' + tID + ' .limber-title').each(function() {
				// duplicates the .limber-title that's a sub of .limber-tab, puts it in .limber-nav
				$(this).clone().appendTo( $(this).parent().parent().find('.limber-nav') );
			});*/
		});
	}

	var orientTabs = function(){
		// resets hr's position
		$('.limber-tabs hr').removeAttr('style');
		$('.limber-tabs').each(function() {
			// desktop
			/*$(this).removeClass('mini').addClass('max');*/
			
			// mobile
			// checks to see if the titles in .limber-nav overlap to the second line
			// if they do, tabs are minified
			/*var navH = $(this).find('.limber-nav').height();
			var aH = $(this).find('.limber-nav .limber-title').height();
			if (navH >= (2*aH)) {
				$(this).removeClass('max').addClass('mini');
			}*/

			// ACCORDIONS ONLY!!
			// for 1st line: on resize, all tabs closed... might want to fix later
			$(this).find('.limber-tab.open').removeClass('open');
			var hrH = $(this).outerHeight();
			var hrY = 0;
			$(this).find('hr').css('height',hrH + 'px');
			$(this).find('hr').css('top',hrY + 'px');
			});
	}

	var switchMiniTab = function(link, tID) {
		var oldTabI = $('##'+ tID + ' .limber-tab.open').index();
		/*var isOldTabMax = $('##' + tID + ' .limber-nav .limber-title.open').index();*/
		/*var isOldTabResized = $('##' + tID + ' .limber-tab.open').data('beforeResize');*/
		var newTabI = link.parent().index();
		$('##' + tID + ' .limber-title').removeClass('open');
		$('##' + tID + ' .limber-tab').removeClass('open');
		
		// if open tab is clicked on, it collapses
		if ((oldTabI != newTabI) /*|| (isOldTabMax > -1)*/)
			link.parent().addClass('open');
		/*else if (isOldTabResized == true)
			link.parent().addClass('open');*/
		
		// tab scrolls to top if mini tabs are all set up
		if ($('##' + tID).data('miniSet') == true) {
			var toTop = link.offset().top;
			window.scrollTo(0,toTop);
		}
	}

	/*var switchMaxTab = function(link, tID) {
		$('##' + tID + ' .limber-title').removeClass('open');
		$('##' + tID + ' .limber-tab').removeClass('open');
		
		// finds this tab's index
		var linkI = link.index();
		var $tabI = $('##' + tID + ' .limber-tab:eq(' + linkI + ')');
		$tabI.addClass('open');
		link.addClass('open');
	}*/

	/*var changeMaxHrPosition = function(link, tID) {
		var hrW = link.outerWidth(true);
		var hrX = (link.position().left - link.parent().position().left);
		
		// if all tabs closed, hr becomes as tall as entire tabs object
		if (!($('##' + tID + ' .limber-tab').hasClass("open"))) {
			hrW = $('##' + tID).outerWidth();
			hrX = 0;
		}
		$('##' + tID + ' hr').css('width',hrW + 'px');
		$('##' + tID + ' hr').css('left',hrX + 'px');
	}*/

	var changeMiniHrPosition = function(link, tID) {
		var hrH = link.parent().outerHeight();
		var hrY = link.parent().position().top;
		
		// if all tabs closed, hr becomes as tall as entire tabs object
		if (!($('##' + tID + ' .limber-tab').hasClass("open"))) {
			hrH = $('##' + tID).outerHeight();
			hrY = 0;
		}
		$('##' + tID + ' hr').css('height',hrH + 'px');
		$('##' + tID + ' hr').css('top',hrY + 'px');
	}

	/*var setMaxDefault = function(h, tID) {
		$('##' + tID).data('miniSet',false);
		var link = $('##' + tID + ' .limber-nav a.limber-title:eq(0)');
		$('##' + tID + ' .limber-nav .limber-title').each(function() {
			var tabID = $(this).attr('name');
			var wasResized = $('##' + tID + ' .limber-tab .limber-title[name="' + tabID + '"]').parent().data('beforeResize');
			if ((tabID == h) || (wasResized == true))
				link = $('##' + tID + ' .limber-nav .limber-title[name="' + tabID + '"]');
		});
		link.trigger('click-tab');
	}*/

	/*var setMiniDefault = function(h, tID){
		var link = $('##' + tID + ' .limber-tab:eq(0) .limber-title');
		$('##' + tID + ' .limber-tab .limber-title').each(function() {
			var tabID = $(this).attr('name');
			var wasResized = $(this).parent().data('beforeResize');
			if ((tabID == h) || (wasResized == true))
				link = $('##' + tID + ' .limber-tab .limber-title[name="' + tabID + '"');
		});
		link.trigger('click-tab');
		// for anchor scrolling on mobile
		$('##' + tID).data('miniSet',true);
	}*/

	/*var setDefault = function(){
		// checks URL to tab anchor name
		var h = window.location.hash.substring(1);
		var tID;
		/*$('.limber-tabs.max').each(function(){
			tID = $(this).attr('id');
			setMaxDefault(h, tID);
		});*/
		/*$('.limber-tabs.mini').each(function(){
			tID = $(this).attr('id');
			setMiniDefault(h, tID);
		});
	}*/
	var setClicks = function(){
		// note: unbind() to prevent functions from triggering twice
		/*$('.limber-tabs.max .limber-nav .limber-title').unbind().on('click click-tab', function(event) {
			event.preventDefault();
			var link = $(this);
			var tID = $(this).parent().parent().attr('id');
			switchMaxTab(link, tID);
			changeMaxHrPosition(link, tID);
		});*/
		$('.limber-tabs.mini .limber-tab .limber-title').unbind().on('click click-tab', function(event) {
			event.preventDefault();
			var link = $(this);
			var tID = $(this).parent().parent().attr('id');
			switchMiniTab(link, tID);
			changeMiniHrPosition(link, tID);
		});
	}

	var rememberCurrentTab = function() {
		$('.limber-tabs').each(function() {
			// sets data var to retrieve at mode set default
			$(this).find('.limber-tab.open').data('beforeResize',true);
		});
	}

	var forgetPastTab = function() {
		$('.limber-tabs').each(function() {
			// sets data var to retrieve at mode set default
			$(this).find('.limber-tab').data('beforeResize',undefined);
		});
	}

	$(document).ready(function() {
		if ($('.limber-tabs').length) {
			initTabs();
			orientTabs();
			setClicks();
			//setDefault();
		}
	});

	var wWidth = window.innerWidth;
	$(window).on("resize", decide);
	function decide(){
		if ($('.limber-tabs').length) {
			// mobile fix - so that tabs don't keep trying to resize when scrolling on phones
			// if window resizes more than 25px, then tabs resize and possibly change modes
			if(Math.abs(wWidth - window.innerWidth) > 20) {
				var w = window.innerWidth;
				orientTabs();
				window.scrollTo(0,0);
				wWidth = w;
			}
		}
	}
} (window.limberTabs = window.limberTabs || {}, jQuery));
</script>
</cffunction>

<cffunction name="runCode" returntype="string" output="false">		
	<cfargument name="s_content" required="false" default="">
	<cfargument name="selected" required="false" default="0" type="numeric">

	<cfsavecontent variable="content">
	<section class="limber-tabs mini">
		<cfoutput>#arguments.s_content#</cfoutput>
	</section>
	</cfsavecontent>

	<cfreturn content>
</cffunction>

</cfcomponent>
