<cfinvoke component="assets.formUtility" method="cleanFormScope">
	<cfinvokeargument name="maxItems" value="#50#">
    <cfinvokeargument name="formScope" value="#form#">
</cfinvoke>
<!--- sqlchecked we --->
<cfparam name="email" default="">
<cfparam name="name" default="">
<cfparam name="os" default="">
<cfparam name="otherOs" default="">
<cfparam name="browser" default="">
<cfparam name="otherBrowser" default="">
<cfparam name="Bversion" default="">
<cfparam name="message" default="">
<cfset recaptcha = createObject("component", "recaptcha").init()>

<cfif email neq "" AND recaptcha.verify() EQ true>
    <CFPROCESSINGDIRECTIVE SUPPRESSWHITESPACE="No">
    <CFMAIL 
        SUBJECT="Website Feedback"
        FROM="#email#"
        To="webmaster@example.com; #email#"
        type="html">
      <br>
      <br>
      <table>
        <tr>
          <td colspan="2">The following email and name has been submitted.  If this email has been submitted in error, please email <a href="mailto:webmaster@example.com" title="webmaster email address">webmaster@example.com</a>. &nbsp;</td>
        </tr>
      <tr>
        <td width="25%"><div align="right"><strong>Name:</strong></div></td>
        <td width="60%">#FORM.name#</td>
      </tr>
      <tr>
        <td><div align="right"><strong>Email:</strong></div></td>
        <td>#FORM.email#</td>
      </tr>
      <tr>
        <td valign="top"><div align="right"><strong>Operating System</strong></div></td>
        <td>            
          #FORM.os#
            </td>
      </tr>
      <tr>
        <td valign="top"><div align="right"><strong>Browser</strong></div></td>
        <td>
            #FORM.browser#
        </td>
      </tr>
      <tr>
        <td valign="top"><div align="right">
          <strong>Browser Version</strong></div></td>
        <td>#FORM.Bversion#</td>
      </tr>
        <tr>
          <td width="15%"><div align="right"><strong>Comments:</strong></div></td>
          <td>#FORM.message#</td>
        </tr>
    </table>
    </CFMAIL>
    </CFPROCESSINGDIRECTIVE>
  <CFOUTPUT>
      <h3>The following email has been submitted.</h3>
      <br />
      <p>If this information is incorrect, please contact the <a title="webmaster email address" href="mailto:webmaster@example.com">Webmaster</a> and reference the name "#name#".</p>
      <br>
      <h3><strong>Thank you, #name#, for sending your feedback.</strong></h3>
          <p>The following information was submitted:</p>
    <table>
      <tr>
        <td colspan="2"><h3><strong>Web Feedback</strong></h3></td>
      </tr>
      <tr>
        <td width="25%"><div align="right"><strong>Name:</strong></div></td>
        <td width="60%">#FORM.name#</td>
      </tr>
      <tr>
        <td><div align="right"><strong>Email:</strong></div></td>
        <td>#FORM.email#</td>
      </tr>
      <tr>
        <td valign="top"><div align="right"><strong>Operating System</strong></div></td>
        <td>            
          #FORM.os#
            </td>
      </tr>
      <tr>
        <td valign="top"><div align="right"><strong>Browser</strong></div></td>
        <td>
            #FORM.browser#
        </td>
      </tr>
      <tr>
        <td valign="top"><div align="right">
          <strong>Browser Version</strong></div></td>
        <td>#FORM.Bversion#</td>
      </tr>
        <tr>
          <td width="15%"><div align="right"><strong>Comments:</strong></div></td>
          <td>#FORM.message#</td>
        </tr>
    </table>
      <p>For questions, please contact the <a title="webmaster email address" href="mailto:webmaster@example.com">Webmaster</a>.</p>
  </CFOUTPUT>
  <cfelse>
  
  <cfhtmlhead text='<style type="text/css">@import "app-assets/dojo/1.5.0/dijit/themes/nihilo/nihilo.css";</style>'>
  <script type="text/javascript" src="app-assets/dojo/1.5.0/dojo/dojo.js" djConfig="parseOnLoad:true, isDebug: false"></script> 
  
  <!--- Adds the 'nihilo' class to the body tag ---> 
  <script type="text/javascript">document.getElementsByTagName('body')[0].className+='nihilo'</script> 
  <script>
  dojo.require("dijit.form.Form");
  dojo.require("dijit.form.Button");  
  dojo.require("dijit.form.TextBox");
  dojo.require("dijit.form.ComboBox");
  dojo.require("dijit.form.DateTextBox");
  dojo.require("dijit.form.TimeTextBox");
  dojo.require("dijit.form.SimpleTextarea");
  dojo.require("dijit.form.ValidationTextBox");
  dojo.require("dijit.form.Textarea");
  dojo.require("dojox.validate.regexp");   
  dojo.require("dijit.form.FilteringSelect");
  dojo.require("dijit.form.CheckBox");
  dojo.require("dijit.Tooltip");
  dojo.require("dijit.Editor");
  dojo.require("dojo.parser");
  dojo.require("dijit._editor.plugins.EnterKeyHandling");
  dojo.require("dijit._editor.plugins.LinkDialog");
  dojo.require("dojox.validate.web");
  dojo.require("dojox.validate._base");
  dojo.require("dojox.validate.creditCard");
  dojo.require("dojox.validate.isbn");

  function setAllDay(){
  	 if(dijit.byId('mycheck').attr('value')=='true'){
	     dijit.byId('time1').attr('disabled', true);
	     dijit.byId('time2').attr('disabled', true);
	 } else {
	     dijit.byId('time1').attr('disabled', false);
	     dijit.byId('time2').attr('disabled', false);
     }
	 
  return;
  }
  
  function init() {
  }
  dojo.addOnLoad(init);
</script>
  <form dojoType="dijit.form.Form" id="myFormThree" jsId="myFormThree" method="post" name="myForm">
  <form dojoType="dijit.form.Form" id="myFormThree" jsId="myFormThree" action="calendar.cfc?method=updateCalendarEvent" method="post" name="myForm">
    <script type="dojo/method" event="onSubmit">			
	    if(this.validate()){		
			
			if((dijit.byId('category').attr('value').length==0) || dijit.byId('category').attr('value')=='null' || dijit.byId('category').attr('value')==null){
				alert("A category must be selected");
				dijit.byId('category').focus();
				return false;
			}	

			return true; //confirm('Form is valid, press OK to submit');
        } else {
            alert('Form contains invalid data.  Please correct first');
            return false;
        }
		alert('Hello World');
        return true;
    </script>
    
    <table cellpadding="2" width="100%">
      <tr>
        <td colspan="2" ><p> Your feedback about the website is helpful. </p></td>
      </tr>
      <tr >
        <td width="15%"><div align="right">Date</div></td>
        <td width="60%"><cfoutput>#dateformat(now(), "medium")#</cfoutput></td>
      </tr>
      <tr>
        <td><div align="right">
          <label for="name">Your Name</label>
        </div></td>
        <td><input style="width: 30%;" dojotype="dijit.form.ValidationTextBox" type="text" id="name" name="name" size="35" maxlength="60" required promptMessage="Enter your name." value="<cfoutput>#name#</cfoutput>"/></td>
      </tr>
      <tr>
        <td><div align="right">
          <label for="email">Your Email</label>
        </div></td>
        <td>
            <input style="width: 45%;" dojotype="dijit.form.ValidationTextBox" type="text" id="email" name="email" required
		regexp="\b[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b"
        invalidmessage="Invalid email Address."
        promptmessage="Enter the best email address to contact you."
        size="20"
        trim="true"
		maxlength="100"
        value="<cfoutput>#email#</cfoutput>" />
        </td>
      </tr>
      <tr>
        <td valign="top"><div align="right">Operating System</div></td>
        <td>            
          <input type="radio" dojoType="dijit.form.RadioButton" name="os" id="radioOne" value="windows" <cfif #os# EQ "windows">checked="checked" </cfif> />
          <label for="radioOne">
                Windows
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="os" id="radioTwo" value="mac" <cfif #os# EQ "mac">checked="checked" </cfif> />
            <label for="radioTwo">
                Mac
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="os" id="radioFive" value="ios" <cfif #os# EQ "ios">checked="checked" </cfif>/>
          <label for="radioFive">
                iOS (iPhone, iPad)
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="os" id="radioSix" value="android" <cfif #os# EQ "android">checked="checked" </cfif>/>
          <label for="radioSix">
                Android
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="os" id="radioThree" value="linux" <cfif #os# EQ "linux">checked="checked" </cfif>/>
          <label for="radioThree">
                Linux
            </label><br />

          <input type="radio" dojoType="dijit.form.RadioButton" name="os" id="radioFour" value="other" <cfif #os# EQ "other">checked="checked" </cfif>/>
            <label for="radioFour">
                Other
            </label> <label for="otherOs"><input style="width: 25%;" dojotype="dijit.form.ValidationTextBox" type="text" id="otherOs" name="otherOs" size="35" maxlength="60" promptMessage="Enter your operating system." value="<cfoutput>#otherOs#</cfoutput>" /></label>
            </td>
      </tr>
      <tr>
        <td valign="top"><div align="right">Browser</div></td>
        <td>
<input type="radio" dojoType="dijit.form.RadioButton" name="browser" id="radio2One" value="ie" <cfif #browser# EQ "ie">checked="checked" </cfif> />
          <label for="radio2One">
                Internet Explorer
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="browser" id="radio2Two" value="Safari" <cfif #browser# EQ "Safari">checked="checked" </cfif> />
            <label for="radio2Two">
                Safari
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="browser" id="radio2Three" value="firefox" <cfif #browser# EQ "Firefox">checked="checked" </cfif> />
          <label for="radio2Three">
                Firefox
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="browser" id="radio2Five" value="chrome" <cfif #browser# EQ "chrome">checked="checked" </cfif> />
          <label for="radio2Five">
                Chrome
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="browser" id="radio2Six" value="android" <cfif #browser# EQ "android">checked="checked" </cfif> />
          <label for="radio2Six">
                Android
            </label>
          <br />
          <input type="radio" dojoType="dijit.form.RadioButton" name="browser" id="radio2Four" value="other" <cfif #browser# EQ "other">checked="checked" </cfif> />
            <label for="radio2Four">
                Other
            </label> <label for="otherBrowser"><input style="width: 20%;" dojotype="dijit.form.ValidationTextBox" type="text" id="otherBrowser" name="otherBrowser" size="35" maxlength="60" promptMessage="Enter your browser." value="<cfoutput>#otherBrowser#</cfoutput>" /></label>
        </td>
      </tr>
      <tr>
        <td valign="top"><div align="right">
          <label for="Bversion">Browser Version</label></div></td>
        <td><input style="width: 8%;" dojotype="dijit.form.TextBox" type="text" id="Bversion" name="Bversion" size="30" maxlength="60" promptMessage="Enter your browser's version number." value="<cfoutput>#Bversion#</cfoutput>" /></td>
      </tr>
      <tr>
        <td valign="top"><div align="right">
          <label for="message">Comments/<br />
            Suggestions</label>
        </div></td>
        <td><textarea id="message" name="message" dojoType="dijit.form.Textarea"
        style="width:55%;" required="required"><cfoutput>#message#</cfoutput></textarea></td>
      </tr>
      <tr>
        <td></td>
        <cfset recaptcha.render()>
          <button dojoType="dijit.form.Button" type="submit" name="submitButtonThree" value="Submit">Submit</button></td>
      </tr>
    </table>
  </form>
</cfif>