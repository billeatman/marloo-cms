<cfparam name="calId" default="-1" type="numeric">

<cfif calId neq -1>
  <cfhttp url="/calservice/calservice.cfc?method=getEvent&calid=#calId#&eventAsText=false" method="get" result="local.calEvent">

  <!--- WE - This is a bit hacky.  I get the event twice... the second time requesting text for the desc --->
  <cfhttp url="/calservice/calservice.cfc?method=getEvent&calid=#calId#&eventAsText=true" method="get" result="local.calEventText">

  <cfif local.calevent.responseheader.status_code NEQ 200>
    <cfthrow errorcode="Error Cal Event" message="Unable to retrieve calendar event from calservice">     
  </cfif>

  <cfset local.calevent = deserializeJSON(local.calevent.filecontent)>
  <cfset local.caleventText = deserializeJSON(local.caleventText.filecontent)>

  <cfset variables.page.setOwnerEmail(local.calevent.CalEmail)>

  <!--- Overrides for static page head --->
  <cfset variables.page.setPageTitle(local.calevent.CalEvent)>

  <cfinvoke component="marloo.core.utilityCore" method="stringToSummary" returnvariable="local.calEventText.CalDesc">
      <cfinvokeargument name="maxLength" value="155">
      <cfinvokeargument name="nearestSentence" value="true">
      <cfinvokeargument name="sourceStr" value="#local.calEventText.CalDesc#">
  </cfinvoke>

  <cfset variables.page.setTextDescription(local.calEventText.CalDesc)>   

  <cfset local.og_meta = structNew()>
  <cfset local.og_meta["og:title"] = local.calevent.CalEvent>
  <cfset variables.metaCore.addMeta(argumentCollection: local.og_meta, key_attribute: 'property')>

  <cfoutput>
    <h2>#local.calevent.CalEvent#</h2>
  <cfif local.calevent.CalDesc neq "">
    <p>#ParagraphFormat(local.calevent.CalDesc)#</p>
    </cfif>
    <table>
    <tr>
      <td><strong>Date:</strong></td>
      <td>#local.calevent.displayDate#</td>
    </tr>
      <!---
    <cfif CalCategory is "">
      <cfelse>
        <tr>
          <td><strong>Category:</strong></td>
            <td>#CalCategory#</td>
        </tr>
      </cfif>
    --->
  <tr>
      <td><strong>Time:</strong></td>
      <td>#local.calevent.displaytime#</td>
    </tr>
      <cfif local.calevent.CalPlace is "">
        <cfelse>
        <tr>
        <td><strong>Place:</strong></td>
        <td>#local.calevent.CalPlace#</td>
        </tr>
      </cfif>
      <cfif local.calevent.CalContact is "">
        <cfelse>
        <tr>
        <td><strong>Contact:</strong></td>
        <td>#local.calevent.CalContact#</td>
        </tr>
      </cfif>
      <cfif local.calevent.CalEmail is "">
        <cfelse>
        <tr>
        <td><strong>E-mail:</strong></td>
        <td><a href="mailto:#local.calevent.CalEmail#?subject=Question%20About%20#local.calevent.CalEvent#" title="#local.calevent.CalEmail#">#local.calevent.CalEmail#</a></td>
        </tr>
      </cfif>
      <cfif local.calevent.CalPhone is "">
        <cfelse>
          <cfif len(trim(local.calevent.CalPhone)) eq 10 and isNumeric(local.calevent.CalPhone)>
            <cfset local.calevent.CalPhone = mid(local.calevent.CalPhone, 1, 3) & "-" & mid(local.calevent.CalPhone, 4, 3) & "-" & mid(local.calevent.CalPhone, 7, 4)>
          </cfif>
        <tr>
        <td><strong>Phone:</strong></td>
        <td>#local.calevent.CalPhone#</td>
        </tr>
      </cfif>
    </table>
    <p><br /><a href="#getTemplateRoot()#calendar">See the Calendar</a></p>
  </CFOUTPUT>
  <cfelse>
  <!--- Embeddable Calendar Helper
  https://www.google.com/calendar/embedhelper?src=eegciesfs3cfd50rhdjt41fiks%40group.calendar.google.com&ctz=America/New_York
  --->
  
  <iframe class="hideMobile" src="https://www.google.com/calendar/hosted" width="100%" height="600px" frameborder="0" scrolling="no"></iframe>

  <iframe class="hideDesktop" src="https://www.google.com/calendar/hosted" width="100%" height="600px" frameborder="0" scrolling="no"></iframe>

</cfif>
