<cfcomponent extends="marloo.shortcode">

<cfset variables.ph = "">
<cfset variables.currentUrl = "">

<!--- #variables.ph.getCurrentUrl()# --->

<cffunction name="init" output="false" returntype="ANY">
<!---
--->
<!---
	<cfset local.baseCFCPath = "#arguments.site_config.cfMappedPath#.#arguments.site_config.sitepath#">
	<!--- create the page helper --->
	<cfset variables.ph = createObject("component", "#local.baseCFCPath#.core.pageHelper").init(site_config: arguments.site_config)>
	<cfset variables.currentUrl = variables.ph.getCurrentUrl()>

// generic tab reset code 
    $('.tabs > ul li').click(function(){
      	$(this).parents('.tabs').find('.current').removeClass('current');
      	$(this).addClass('current');
      	$($(this).find('a').attr('href')).addClass('current');
      	return false;
    });

--->

	<cfset super.init(argumentCollection=arguments)>
	<cfreturn this>

</cffunction>

<cffunction name="renderHeadOnce" output="true">

<script language="javascript">
$(document).ready(function() {
	$('.truncate').each(function(){
		$(this).append('<span class="truncated">'+ $(this).text().substring(0, 200) + '</span><a href="##" class="showlink">Show <span class="more">more</span><span class="less">less</span></a>');
	});

	$('.showlink').bind("click", function(event) {
 		if ($(this).parent().hasClass('show')){
			$(this).parent().removeClass('show'); 
		} else { 
			$(this).parent().addClass('show'); 
		}
	  	event.preventDefault();
	});

});

</script>
</cffunction>


<cffunction name="runCode" returntype="string" output="false">
	<cfargument name="s_content" required="false" default="">

	<cfset var content = "">

	<cfsavecontent variable="content">
	<div class="truncate"><cfoutput>#s_content#</cfoutput></div>
	</cfsavecontent>

	<cfreturn content>
</cffunction>

</cfcomponent>