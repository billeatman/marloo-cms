<cfcomponent extends="marloo.template">

<cffunction name="RenderHead" access="public" output="true">
<cfset super.RenderHead(argumentCollection=arguments)>
<link href='base/styles/slider.css' rel='stylesheet' type='text/css'>
<script src="base/js/slider.js"></script>
<style type="text/css">
	main div.content img {
	width: 200px !important;
	}
</style>
</cffunction>

<cffunction name="renderSlides" output="true">
	<cfset slides = page.getSlides(width: 1800, randomize: true, cache: false)>
<!---	<cfsavecontent variable="mycontent"> --->		
	<cfif arrayLen(local.slides) EQ 0>
	<cfelse>
	<article id="slider">
		<cfif arrayLen(local.slides) GT 1>
		<button id="toggleLeft" title="See previous slide">&lt;&nbsp;</button>
		<button id="toggleRight" title="See next slide">&nbsp;&gt;</button>
		<nav>
			<!--- bottom '.slideBtn's will go here --->
		</nav>
		</cfif>
		<div id="slideReel">
			<cfloop array="#local.slides#" index="local.slide">
			   	<figure class="slide">
				    <img src="#local.slide.resized#" alt="#local.slide.alt#" />
				    <cfif structKeyExists(local.slide, "a")>
				    <figcaption class="caption">
				    	<a href="#local.slide.a.href#" title="#local.slide.a.title#">
						   	<p><strong>#local.slide.a.title#</strong></p>
					    	<p>#local.slide.alt#</p>
				    	</a>
				    </figcaption>
				    </cfif>
			   	</figure>
			</cfloop>
		</div>
	</article>
	</cfif>
<!--- 	</cfsavecontent>

	<cfif variables.sc.useCache>
    	<cfset CachePut(cacheKey, myContent, createTimeSpan(0,0,5,0))>
  	</cfif>
  	
  	</cfsilent>
  	<cfoutput>#mycontent#</cfoutput> --->
</cffunction>


</cfcomponent>