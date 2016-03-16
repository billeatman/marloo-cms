<cfcomponent displayname="spotlight" output="false" hint="Spotlight Widget" extends="marloo.widget">

<cfset variables.slides = arrayNew(1)>
<cfset variables.numberOfPhotos = 1>
<cfset variables.numberOfSlides = 1>
<cfset variables.relPhotoPath = "">
<cfset variables.photoPrefix = "">
    
<cffunction name="init" access="public" returntype="ANY" output="false" hint="Pseudo Constructor">
  	<cfargument name="numberOfPhotos" required="true" type="numeric" hint="Number of images in the file pool.">
	  <cfargument name="relPhotoPath" required="true" type="string" hint="Relative photo path. ex: assets10/images/jqueryslides/index/">
    <cfargument name="photoPrefix" required="true" type="string" hint="prefix for each photo. ex: 10slide-">
    <cfargument name="numberOfSlides" required="false" default="5" type="numeric" hint="Number of slides.">	
        
   	<!--- numberofPhotos number be greater than max photos --->
    <cfif arguments.numberOfSlides GT numberOfPhotos>
       	<cfthrow message="numberOfSlides is greater than the numberOfPhotos" detail="numberOfSlides is greater than the numberOfPhotos">
    </cfif>
        
    <cfset variables.numberOfPhotos = arguments.numberOfPhotos>
    <cfset variables.numberOfSlides = arguments.numberOfSlides>
	  <cfset variables.relPhotoPath = arguments.relPhotoPath>
    <cfset variables.photoPrefix = arguments.photoPrefix>
    
    <cfset super.init(argumentCollection=arguments)>

    <cfreturn this>
</cffunction>    	    

<cffunction name="add" access="public" output="false">
   	<cfargument name="title" required="true" type="string">
    <cfargument name="filename" required="true" type="string">
    <cfargument name="header" required="false" type="string" default="Spotlight">
    <cfargument name="link" required="false" type="string" default="">
    	
    <cfset var LOCAL = structNew()>
        
    <cfset arrayAppend(variables.slides, structNew())>
    <cfset LOCAL.index = arrayLen(variables.slides)> 
  	<cfset variables.slides[LOCAL.index].title = arguments.title>
   	<cfset variables.slides[LOCAL.index].filename = arguments.filename>
    <cfset variables.slides[LOCAL.index].header = arguments.header>
   	<cfset variables.slides[LOCAL.index].link = arguments.link>
    <cfset variables.slides[LOCAL.index].useHeader = arguments.header NEQ "">
</cffunction>
    
<cffunction name="getRandomPhotoNumbers" access="private" output="false" returntype="array" hint="Gets unique array of random photo numbers.">
    <cfargument name="numberOfSlides" type="numeric" hint="Number of slides to generate.">
        
    <cfset var LOCAL = structNew()>
        
  	<cfset LOCAL.headerImageList = "">
    <cfloop index="LOCAL.i" from="1" to="#arguments.numberOfSlides#">
	   	<cfset LOCAL.slideNum = -1>
        <!--- Make sure the photos are unique --->
        <cfloop condition="ListFindNoCase(LOCAL.headerImageList, LOCAL.slideNum) neq 0 XOR LOCAL.slideNum eq -1">
    	    <cfset LOCAL.slideNum = RandRange(1, variables.numberOfPhotos)>
        </cfloop>
        <cfset LOCAL.headerImageList = listAppend(LOCAL.headerImageList, LOCAL.slideNum)>
    </cfloop>
    <cfreturn listToArray(LOCAL.headerImageList)>
</cffunction>
    
<cffunction name="render" access="public" output="true" hint="Renders the spotlight.">
<cfsilent>
<cfset var LOCAL = structNew()>

<!--- Put script and CSS in the head --->
<cfsavecontent variable="LOCAL.head">
<!-- Inserted by spotlight widget -->
<link href="ctx-base/styles/imagerotator.css" rel="stylesheet" type="text/css" media="screen" />
<script type="text/javascript" src="ctx-base/javascripts/imagerotator.js"></script>
</cfsavecontent>

<cfset AddHTMLHead(LOCAL.head)>

<!---
<div id="slidecontent">
  <div class="bgcontainer">
    <h1>Spotlights</h1>
  </div>
</div>
--->
	
<!--- get images --->
<cfset LOCAL.headerImageList = getRandomPhotoNumbers(numberOfSlides: variables.numberOfSlides)>
</cfsilent>
<div class="main_view">
  <div class="window"> 
    <!--stores images for the image reel. The image lsited first shows up first in the reel-->
    <div class="image_reel">
      <cfloop array="#variables.slides#" index="LOCAL.i">
      	<cfif LOCAL.i.link NEQ "">
        	<cfoutput><a title="#LOCAL.i.title#" href="#LOCAL.i.link#"> <img src="#LOCAL.i.filename#" alt="#LOCAL.i.title#" /></a></cfoutput>
        <cfelse>
        	<cfoutput><img src="#LOCAL.i.filename#" alt="#LOCAL.i.title#" /></cfoutput>        
        </cfif>
      </cfloop>
      <cfloop index="LOCAL.i" from="#arrayLen(variables.slides) + 1#" to="#variables.numberOfSlides#">
        <cfoutput><img src="#variables.relPhotoPath##variables.photoPrefix##LOCAL.headerImageList[LOCAL.i]#.jpg" alt="campus photo #LOCAL.i#" /></cfoutput>
      </cfloop>
    </div>
    <!--close image_reel-->
    <div class="desc">
      <cfloop array="#variables.slides#" index="LOCAL.i">
        <cfif LOCAL.i.link NEQ "">
          <!--open block container for spotlighted text --> 
          <cfoutput>
            <div class="block"> <a title="#LOCAL.i.title#" href="#LOCAL.i.link#">
              <cfif LOCAL.i.useHeader EQ true>
                <h2>#LOCAL.i.header#</h2>
              </cfif>
              <p>#LOCAL.i.title#<small> More >></small></p>
              </a> </div>
            <!--close block--></cfoutput>
          <cfelse>
          <div class="block">
              <cfif LOCAL.i.useHeader EQ true>
                <h2>#LOCAL.i.header#</h2>
              </cfif>
              <p>#LOCAL.i.title#</p>
           </div>
        </cfif>
      </cfloop>
      <cfloop from="#arrayLen(variables.slides) + 1#" to="#variables.numberOfSlides#" index="LOCAL.i">
        <div class="block"></div>
      </cfloop>
    </div>
    <!--close desc-->
    <div class="paging">
      <cfloop from="1" to="#arrayLen(variables.slides)#" index="LOCAL.i">
		<cfif variables.slides[LOCAL.i].title NEQ "">
			<cfset LOCAL.title = "spotlight #LOCAL.i#: " & variables.slides[LOCAL.i].title>
        <cfelse>
			<cfset LOCAL.title = "spotlight #LOCAL.i#">
        </cfif>
		<cfif LOCAL.i EQ 1>
          <cfoutput><a title="#LOCAL.title#" class="active" href="##" rel="#LOCAL.i#">#LOCAL.i#</a></cfoutput>
          <cfelse>
          <cfoutput><a title="#LOCAL.title#" href="##" rel="#LOCAL.i#">#LOCAL.i#</a></cfoutput>
        </cfif>
      </cfloop>
      <cfloop from="#arrayLen(variables.slides) + 1#" to="#variables.numberOfSlides#" index="LOCAL.i">
        <cfset LOCAL.title = "spotlight #LOCAL.i#">
		<cfif LOCAL.i EQ 1>
          <cfoutput><a title="#LOCAL.title#" class="active" href="##" rel="#LOCAL.i#">#LOCAL.i#</a></cfoutput>
          <cfelse>
          <cfoutput><a title="#LOCAL.title#" href="##" rel="#LOCAL.i#">#LOCAL.i#</a></cfoutput>
        </cfif>
      </cfloop>
    </div>
    <!--close paging--> 
  </div>
  <!--close window--> 
</div>
<!--close main_view-->
</cffunction>
   
</cfcomponent>