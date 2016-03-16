-- Populate Leo CMS

-- Default User
declare @user varchar(100) 
SET @user = 'test@example.com'

-- Create Functions / Roles
delete from mrl_pageState
delete from mrl_pageComment
DBCC CHECKIDENT ('mrl_pageState', RESEED, 0) 
delete from mrl_pageRevision
DBCC CHECKIDENT ('mrl_pageRevision', RESEED, 0) 
delete from mrl_page
DBCC CHECKIDENT ('mrl_page', RESEED, 0) 
delete from mrl_template
delete from mrl_pageGroupMember
delete from mrl_pageGroup
delete from mrl_pageMoveLog
delete from mrl_loginHistory
delete from mrl_userActivityLog
delete from mrl_userSession
delete from mrl_redirectType
delete from mrl_redirect
delete from mrl_userLockout
delete from mrl_imageCache
delete from mrl_errorLog
delete from mrl_dataCache
delete from mrl_siteConfig
DBCC CHECKIDENT ('mrl_siteConfig', RESEED, 0) 

INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('PageAdd', 'Page Add', 'T', 'system', '0', 'function') 

INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('PageMove', 'Page Move', 'T', 'system', '0', 'function') 

INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('PageApprove', 'Page Move', 'T', 'system', '0', 'function') 

INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('UserMan', 'User Manager', 'T', 'system', '0', 'function') 

INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('Developer', 'Developer Mode', 'T', 'system', '0', 'function') 

INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('TopLevel', 'Administrator', 'T', 'system', '0', 'role') 

-- Create Default Page Group
INSERT INTO [mrl_pageGroup]
           ([GroupName],[GroupDesc],[active],[OwnerMail],[securityLevel],[type])
     VALUES
           ('default', 'default', 'T', @user, '0', 'pagegroup') 

-- Add Default User to Default Page Group and ALL FUNCTIONS and ROLES
INSERT INTO [mrl_pageGroupMember] 
			([GroupName],[login])
     SELECT [GroupName], @user as [login]
	 FROM [mrl_pageGroup]

-- Add a default template --
INSERT INTO [mrl_template]
           ([templateName],[templateDesc],[cfcName],[author],[disabled],[tinyMCEWidth],[tinyMCEStyleSheet])
     VALUES
           ('leotest','default test template','leotest','william eatman','F','500','500')
