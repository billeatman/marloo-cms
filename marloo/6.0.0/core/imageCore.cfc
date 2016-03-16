<cfcomponent>

    <cfif isdefined('application.datasource')>
        <cfset variables.datasource = application.datasource>
    <cfelse>
        <cfset variables.datasource = ''>    
    </cfif>

    <!--- Zooms in or out and center to fit image to dimensions --->
    <cffunction name="imageZoomToFit" output="false">
        <cfargument name="image" required="true" type="any">
        <cfargument name="width" required="true" type="numeric">
        <cfargument name="height" required="true" type="numeric">
        <cfargument name="cropType" required="false" default="center" hint="center,head">       

        <cfif NOT ListFind('center,head', arguments.cropType)>
            <cfthrow message="cropType must be either 'center' or 'head'">
        </cfif>

        <cfset local.imageAttribs = ImageInfo(arguments.image)>

        <cfset local.imageRatioWidth = local.imageAttribs.width / local.imageAttribs.height>
        <cfset local.argRatioWith = arguments.width / arguments.height>

        <cfif local.argRatioWith GT local.imageRatioWidth>
            <cfset imageResize(arguments.image, arguments.width, "")>
        <cfelse>
            <cfset imageResize(arguments.image, "", arguments.height)> 
        </cfif>

        <cfset local.imageAttribs = ImageInfo(arguments.image)>
        <cfif local.imageAttribs.width EQ arguments.width AND local.imageAttribs.height EQ arguments.height>
            <!--- Do Nothing, no crop required --->            
        <cfelse>
           <cfif arguments.cropType EQ 'head'>
                <cfset imageCropHead(arguments.image, arguments.width, arguments.height)>                       
           <cfelse>
                <cfset imageCropCenter(arguments.image, arguments.width, arguments.height)>        
           </cfif>                
        </cfif>
    </cffunction>

    <cffunction name="imageCropCenter" output="false">
        <cfargument name="image" required="true" type="any">
        <cfargument name="width" required="false" type="numeric">
        <cfargument name="height" required="false" type="numeric">

        <cfset imageAttribs = ImageInfo(image)>
    
        <cfif IsDefined("arguments.width") and IsDefined("arguments.height")>
            <cfset imageCrop(image, (imageAttribs.width - arguments.width) / 2, (imageAttribs.height - arguments.height) / 2, arguments.width, arguments.height)>                           
            <cfreturn>
        </cfif>

        <cfif imageAttribs.height gt imageAttribs.width>
            <cfset imageCrop(image, 0, ((imageAttribs.height - imageAttribs.width) / 2), imageAttribs.width, imageAttribs.width)>       
        <cfelse>
            <cfset imageCrop(image, ((imageAttribs.width - imageAttribs.height) / 2), 0, imageAttribs.height, imageAttribs.height)>     
        </cfif>
    </cffunction>
    
    <cffunction name="imageCropHead" output="false">
        <cfargument name="image" required="true" type="any">
        <cfargument name="width" required="false" type="numeric">
        <cfargument name="height" required="false" type="numeric">

        <cfset imageAttribs = ImageInfo(image)>

        <cfif IsDefined("arguments.width") and IsDefined("arguments.height")>
            <cfset imageCrop(image, (imageAttribs.width - arguments.width) / 2, 0, arguments.width, arguments.height)>           
            <cfreturn>
        </cfif>
    
        <cfif imageAttribs.height gt imageAttribs.width>
            <cfset imageCrop(image, 0, 0, imageAttribs.width, imageAttribs.width)>      
        <cfelse>
            <cfset imageCrop(image, ((imageAttribs.width - imageAttribs.height) / 2), 0, imageAttribs.height, imageAttribs.height)>     
        </cfif>
    </cffunction>
    
    <cffunction name="runImageChain" output="false" returntype="void">
        <cfargument name="image" required="true" type="any" hint="CF image object">
        <cfargument name="imageChain" required="true" type="any" hint="imageChain either JSON or ARRAY">

        <!--- Sample imageChain in JSON format 

        This JSON string runs
            imageResize(1600, "")
            imageCropHead(1600, 800)

        '[{"FUNC":"imageResize","WIDTH":1600.0,"HEIGHT":""},{"FUNC":"imageCropHead","WIDTH":1600,"HEIGHT":800}]'
        --->

        <cfset var i = 0>

        <!--- What is the chain type? --->
        <cfif NOT isArray(imageChain)>
            <cfset imageChain = deserializeJSON(imageChain)>
        </cfif> 

        <cfloop array="#imageChain#" index="i">         
            <cfswitch expression="#i.func#">
                <cfcase value="imageCrop">
                    <cfset imageCrop(image, i.x, i.y, i.width, i.height)>
                </cfcase>
                <cfcase value="imageCropCenter">
                    <cfif isDefined("i.width") AND isDefined("i.height")>
                        <cfset imageCropCenter(image, i.width, i.height)>                            
                    <cfelse>
                        <cfset imageCropCenter(image)>
                    </cfif>
                </cfcase>
                <cfcase value="imageCropHead">
                    <cfif isDefined("i.width") AND isDefined("i.height")>
                        <cfset imageCropHead(image, i.width, i.height)>                            
                    <cfelse>
                        <cfset imageCropHead(image)>
                    </cfif>
                </cfcase>
                <cfcase value="imageZoomToFitHead">
                    <cfset imageZoomToFit(image, i.width, i.height, 'head')>                            
                </cfcase>
                <cfcase value="imageZoomToFitCenter">
                    <cfset imageZoomToFit(image, i.width, i.height, 'center')>                            
                </cfcase>
                <cfcase value="imageZoomToFit">
                    <cfset imageZoomToFit(image, i.width, i.height, 'center')>                            
                </cfcase>
                <cfcase value="imageResize">
                    <cfset imageResize(image, i.width, i.height)>
                </cfcase>
                <cfcase value="imageScaleToFit">
                    <cfset imageScaleToFit(image, i.width, i.height)>
                </cfcase>
            </cfswitch>
        </cfloop>        
    </cffunction>

    <cffunction name="imageCacher" output="false" returntype="string">
        <cfargument name="imagePath" required="true" type="string">
        <cfargument name="imageChain" required="true" type="any">
        <cfargument name="imageDefaultPath" required="false" type="string" default="">
        <cfargument name="site_config" required="false" type="struct">
        <cfargument name="quality" required="false" type="numeric" default=".95">
        <cfargument name="revKey" required="false" default="" hint="a cache key, sometimes needed if the source file changes and the filename stays the same">
 
        <cfset var webGroup = "">
        <cfset var webPath = "">
        <cfset var pathGroup = "">
        <cfset var myHash = "">
        <cfset var myImage = arrayNew(1)>

        <cfif NOT isNull(arguments.site_config)>
            <cfset variables.datasource = arguments.site_config.datasource>
        </cfif>
        
        <cfif isdefined("application.web.groups")>
            <cfset local.sc = application.site_config>
        <cfelse>
            <cfset local.sc = arguments.site_config>
        </cfif>

        <cfset webGroup = local.sc.CMS.web.groups>
        <cfset pathGroup = local.sc.CMS.path.groups>

        <!--- If SSL --->
        <cfif cgi.server_port_secure>
            <cfset webGroup = ReplaceNoCase(webGroup, 'http://', 'https://')>
        </cfif>
        
        <!--- Check the hash --->
        <cfset myHash = Hash(imageChain & imagePath & quality & revKey, 'md5')>       

        <cfquery datasource="#variables.datasource#" name="qiCache">
            select count(hash) as [hit] from mrl_imageCache where [hash] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#myHash#"> 
        </cfquery>

        <cfset webPath = '#webGroup#iCache/#myHash#.jpg'>

        <cfif qiCache.hit gt 0>
<!---        </cfif> AND site_config.useCache> --->
            HIT!<br>
            <cfreturn webPath>
        <cfelse>
            MISS!<br>

            <cflock name="#site_config.datasource##myhash#" type="exclusive" timeout="30">

            <!--- check again after lock to see if the data is now there --->
            <cfquery datasource="#variables.datasource#" name="qiCache">
                select count(hash) as [hit] from mrl_imageCache where [hash] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#myHash#"> 
            </cfquery>
                
            <cfif qiCache.hit gt 0>
                <cfreturn webpath>
            </cfif>
            
            <cftry>
            <cfloop list="#arguments.imagePath#" index="iPath">
                <cfset ArrayAppend(myImage, ImageRead(iPath))>
                <cfset runimageChain(image: myImage[ArrayLen(myImage)], imageChain: arguments.imageChain)>
            </cfloop>

            <cfset outPath = '#pathGroup#iCache\#myHash#.jpg'>

            <cfif ArrayLen(myImage) eq 1>            
                <cfset ImageWrite(myImage[ArrayLen(myImage)], outPath, arguments.quality)>
            <cfelse>
                <!--- sprite the images, images must all be the same size! --->
                <cfset height = ImageGetHeight(myImage[ArrayLen(myImage)])>
                <cfset width = ImageGetWidth(myImage[ArrayLen(myImage)])>
                <cfset iSprite = ImageNew("", width * ArrayLen(myImage), height)>
                <cfset iCount = 0>
                <cfloop array="#myImage#" index="i" >
                    <cfset ImagePaste(iSprite, i, iCount * width, 0)> 
                    <cfset iCount = iCount + 1>
                </cfloop>   

                <cfset ImageWrite(iSprite, outPath, arguments.quality)>                
            </cfif>             

            <cfif ArrayLen(myImage) gt 1>
                <cfset imagePath = "sprite">
            </cfif>
            
            <cfquery datasource="#variables.datasource#" name="qiCache">
                insert into iCache(hash, sourcePath, dateTime) 
                values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#myHash#">
                    , <cfqueryparam cfsqltype="cf_sql_varchar" value="#imagePath#">
                    , <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#"> 
                )
            </cfquery>

            <cfreturn webPath>        
            <cfcatch>
                <!--- <cfreturn cfcatch.Message> --->
                <cfoutput>#cfcatch.Message#</cfoutput><br>
                <cfreturn imageDefaultPath>
            </cfcatch>
            </cftry>

            </cflock>                
        </cfif>     
    
    </cffunction>
    
</cfcomponent>