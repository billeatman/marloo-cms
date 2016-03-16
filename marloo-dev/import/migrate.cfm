<!--- Add Missing Groups --->

<cfquery datasource="#application.datasource#">
INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('Developer', 'Developer Mode', 'T', 'system', '0', 'function') 

INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('PageApprove', 'Page Approve', 'T', 'system', '0', 'function') 

INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('UserMan', 'User Manager', 'T', 'system', '0', 'role') 

</cfquery>