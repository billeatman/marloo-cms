/****** Object:  Table [dbo].[mrl_dataCache]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_dataCache](
	[hash] [nvarchar](32) NULL,
	[id] [int] NULL,
	[dateTime] [datetime] NULL,
	[cacheData] [image] NULL,
	[caller] [nvarchar](50) NULL,
	[isString] [nvarchar](4) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_errorLog]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_errorLog](
	[datetime] [datetime] NOT NULL,
	[message] [varchar](max) NOT NULL,
	[detail] [varchar](max) NOT NULL,
	[error] [image] NOT NULL,
	[cgi] [image] NOT NULL,
	[hash] [char](32) NOT NULL,
 CONSTRAINT [PK_mrl_errorLog] PRIMARY KEY CLUSTERED 
(
	[datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_imageCache]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_imageCache](
	[hash] [nvarchar](255) NOT NULL,
	[sourcePath] [nvarchar](255) NULL,
	[dateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_mrl_imageCache_1] PRIMARY KEY CLUSTERED 
(
	[hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_loginHistory]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_loginHistory](
	[mail] [nvarchar](255) NULL,
	[dateTime] [datetime] NULL,
	[action] [nvarchar](255) NULL,
	[errorCode] [int] NULL,
	[remote_addr] [varchar](255) NULL,
	[remote_host] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_page]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_page](
	[idShortcut] [int] NULL,
	[shortcutType] [int] NULL,
	[shortcutExternal] [varchar](1000) NULL,
	[state] [varchar](50) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[visible] [varchar](5) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[createdBy] [varchar](100) NOT NULL,
	[deleted] [varchar](5) NOT NULL,
	[locked] [varchar](5) NULL,
	[lockedBy] [varchar](100) NULL,
	[lockedDate] [datetime] NULL,
	[idHistory] [int] NULL,
	[idParent] [int] NULL,
	[securityGroup] [nvarchar](50) NOT NULL,
	[quicklink] [varchar](5) NULL,
	[app] [varchar](150) NULL,
	[gModifiedBy] [varchar](100) NULL,
	[gModifiedDate] [datetime] NULL,
	[sortIndex] [int] NULL,
	[template] [varchar](255) NULL,
	[owner] [varchar](100) NULL,
	[reviewedBy] [varchar](100) NULL,
	[reviewedDate] [datetime] NULL,
	[SSL] [varchar](5) NULL,
	[customURL] [varchar](5) NULL,
 CONSTRAINT [PK_mrl_page] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_pageComment]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_pageComment](
	[comment] [varchar](max) NULL,
	[commentBy] [varchar](255) NULL,
	[commentDate] [datetime] NULL,
	[idHistory] [int] NOT NULL,
	[state] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_pageGroup]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_pageGroup](
	[GroupName] [nvarchar](50) NOT NULL,
	[GroupDesc] [nvarchar](200) NULL,
	[active] [nvarchar](50) NULL,
	[OwnerMail] [nvarchar](255) NULL,
	[securityLevel] [int] NULL,
	[type] [nvarchar](255) NULL,
 CONSTRAINT [PK_mrl_pageGroup] PRIMARY KEY CLUSTERED 
(
	[GroupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_pageGroupMember]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_pageGroupMember](
	[GroupName] [nvarchar](50) NOT NULL,
	[PersonID] [int] NULL,
	[login] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_mrl_pageGroupMember] PRIMARY KEY CLUSTERED 
(
	[login] ASC,
	[GroupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_pageMoveLog]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_pageMoveLog](
	[datetime] [datetime] NOT NULL,
	[movedBy] [varchar](100) NULL,
	[id] [int] NOT NULL,
	[oldParent] [int] NOT NULL,
	[newParent] [int] NOT NULL,
	[sortIndex] [int] NULL,
 CONSTRAINT [PK_mrl_pageMoveLog] PRIMARY KEY CLUSTERED 
(
	[datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_pageRevision]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_pageRevision](
	[idHistory] [int] IDENTITY(1,1) NOT NULL,
	[id] [int] NOT NULL,
	[state] [varchar](50) NULL,
	[modifiedBy] [varchar](100) NOT NULL,
	[modifiedDate] [datetime] NOT NULL,
	[title] [varchar](75) NOT NULL,
	[info] [text] NOT NULL,
	[editSession] [varchar](50) NULL,
	[usedDate] [datetime] NULL,
	[menu] [varchar](75) NULL,
	[url] [varchar](75) NULL,
	[urlHash] [varchar](max) NULL,
	[apps] [varchar](max) NULL,
	[appsDisplay] [varchar](6) NULL,
 CONSTRAINT [PK_mrl_pageRevision_1] PRIMARY KEY CLUSTERED 
(
	[idHistory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_pageState]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_pageState](
	[action] [varchar](255) NULL,
	[actionBy] [varchar](255) NULL,
	[actionDate] [datetime] NULL,
	[idHistory] [int] NOT NULL,
	[actionInfo] [varchar](255) NULL,
	[actionId] [int] IDENTITY(1,1) NOT NULL,
	[id] [int] NULL,
 CONSTRAINT [PK_mrl_pageState] PRIMARY KEY CLUSTERED 
(
	[actionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_redirect]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_redirect](
	[r_id] [int] IDENTITY(1,1) NOT NULL,
	[id] [int] NULL,
	[url] [nvarchar](max) NULL,
	[redirectToUrl] [nvarchar](max) NULL,
	[MD5] [char](32) NOT NULL,
	[redirect] [nvarchar](max) NULL,
	[redirectType] [nvarchar](20) NULL,
	[usedDate] [datetime] NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [nvarchar](255) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [nvarchar](255) NULL,
	[deleted] [nvarchar](50) NULL,
	[idHistory] [int] NOT NULL,
	[redirectId] [int] NULL,
 CONSTRAINT [PK_mrl_redirect] PRIMARY KEY CLUSTERED 
(
	[r_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_redirectType]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_redirectType](
	[redirectType] [nvarchar](20) NOT NULL,
	[redirectDesc] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_mrl_redirectType] PRIMARY KEY CLUSTERED 
(
	[redirectType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_redirectUTM]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_redirectUTM](
	[r_id] [int] NOT NULL,
	[utm_campaign] [varchar](255) NULL,
	[utm_source] [varchar](255) NULL,
	[utm_medium] [varchar](255) NULL,
	[utm_term] [nvarchar](255) NULL,
	[expires] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_securityGroupMember]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_securityGroupMember](
	[GroupName] [nvarchar](50) NOT NULL,
	[PersonID] [int] NULL,
	[login] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblGroupMember] PRIMARY KEY CLUSTERED 
(
	[login] ASC,
	[GroupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_securityGroups]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_securityGroups](
	[GroupName] [nvarchar](50) NOT NULL,
	[GroupDesc] [nvarchar](200) NULL,
	[active] [nvarchar](50) NULL,
	[OwnerMail] [nvarchar](255) NULL,
	[securityLevel] [int] NULL,
	[type] [nvarchar](255) NULL,
 CONSTRAINT [PK_tblGroup] PRIMARY KEY CLUSTERED 
(
	[GroupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_securityLoginHistory]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_securityLoginHistory](
	[mail] [nvarchar](255) NULL,
	[dateTime] [datetime] NULL,
	[action] [nvarchar](255) NULL,
	[errorCode] [int] NULL,
	[remote_addr] [varchar](255) NULL,
	[remote_host] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_securityUsers]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_securityUsers](
	[login] [nvarchar](50) NOT NULL,
	[pwHash] [nvarchar](max) NULL,
	[createdDate] [datetime] NOT NULL,
	[pwhashDate] [datetime] NULL,
	[active] [char](1) NOT NULL,
	[invalidAttempts] [int] NULL,
	[firstName] [nvarchar](50) NULL,
	[lastName] [nvarchar](50) NULL,
	[pwTemp] [nvarchar](255) NULL,
	[pwTempDate] [datetime] NULL,
 CONSTRAINT [PK_tblSecurityLogins] PRIMARY KEY CLUSTERED 
(
	[login] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_siteConfig]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_siteConfig](
	[mrl_siteConfig] [text] NULL,
	[datetime] [datetime] NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_mrl_siteConfig] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_template]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_template](
	[templateName] [varchar](255) NULL,
	[templateDesc] [varchar](max) NULL,
	[cfcName] [varchar](255) NOT NULL,
	[author] [varchar](255) NULL,
	[disabled] [varchar](5) NULL,
	[tinyMCEWidth] [int] NULL,
	[tinyMCEStyleSheet] [varchar](max) NULL,
 CONSTRAINT [PK_mrl_template_1] PRIMARY KEY CLUSTERED 
(
	[cfcName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mrl_userActivityLog]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_userActivityLog](
	[mail] [nvarchar](255) NULL,
	[lastAction] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_userLockout]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mrl_userLockout](
	[login] [nvarchar](50) NOT NULL,
	[loginAttempts] [int] NOT NULL,
	[unlockHash] [nchar](32) NULL,
 CONSTRAINT [PK_mrl_userLockout] PRIMARY KEY CLUSTERED 
(
	[login] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mrl_userSession]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mrl_userSession](
	[login] [varchar](255) NOT NULL,
	[data] [varchar](max) NOT NULL,
	[lastModified] [datetime] NOT NULL,
 CONSTRAINT [PK_mrl_userSession] PRIMARY KEY CLUSTERED 
(
	[login] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[mrl_siteHistory]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mrl_siteHistory]
AS
SELECT     TOP (100) PERCENT dbo.mrl_pageRevision.id, dbo.mrl_page.idParent, dbo.mrl_pageRevision.idHistory, dbo.mrl_page.securityGroup, 
                      dbo.mrl_pageRevision.title, dbo.mrl_pageRevision.info, dbo.mrl_page.visible, dbo.mrl_pageRevision.modifiedDate, dbo.mrl_pageRevision.modifiedBy, 
                      dbo.mrl_page.createdDate, dbo.mrl_page.createdBy, dbo.mrl_page.deleted, dbo.mrl_page.locked, dbo.mrl_page.lockedBy, 
                      dbo.mrl_page.lockedDate, dbo.mrl_page.idShortcut, dbo.mrl_page.shortcutType, dbo.mrl_page.shortcutExternal, dbo.mrl_page.quicklink, 
                      dbo.mrl_page.app, dbo.mrl_page.gModifiedBy, dbo.mrl_page.gModifiedDate, dbo.mrl_pageRevision.editSession, dbo.mrl_pageRevision.state, 
                      dbo.mrl_pageRevision.usedDate, dbo.mrl_page.sortIndex, dbo.mrl_pageRevision.menu, dbo.mrl_pageRevision.url, dbo.mrl_page.template,
                          (SELECT     TOP (1) actionDate
                            FROM          dbo.mrl_pageState
                            WHERE      (id = dbo.mrl_page.id) AND (action = 'pending') AND (idHistory <= dbo.mrl_page.idHistory)
                            ORDER BY actionId DESC) AS submittedDate,
                          (SELECT     TOP (1) actionBy
                            FROM          dbo.mrl_pageState AS mrl_pageState_1
                            WHERE      (id = dbo.mrl_page.id) AND (action = 'pending') AND (idHistory <= dbo.mrl_page.idHistory)
                            ORDER BY actionId DESC) AS submittedBy,
                          (SELECT     TOP (1) actionDate
                            FROM          dbo.mrl_pageState AS mrl_pageState_2
                            WHERE      (id = dbo.mrl_page.id) AND (action = 'approved') AND (idHistory <= dbo.mrl_page.idHistory)
                            ORDER BY actionId DESC) AS approvedDate,
                          (SELECT     TOP (1) actionBy
                            FROM          dbo.mrl_pageState AS mrl_pageState_1
                            WHERE      (id = dbo.mrl_page.id) AND (action = 'approved') AND (idHistory <= dbo.mrl_page.idHistory)
                            ORDER BY actionId DESC) AS approvedBy, dbo.mrl_page.owner, dbo.mrl_page.SSL, dbo.mrl_pageRevision.apps, 
                      dbo.mrl_pageRevision.appsDisplay
FROM         dbo.mrl_pageRevision INNER JOIN
                      dbo.mrl_page ON dbo.mrl_pageRevision.id = dbo.mrl_page.id
ORDER BY dbo.mrl_pageRevision.modifiedDate DESC


GO
/****** Object:  View [dbo].[mrl_siteAdmin]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mrl_siteAdmin]
AS
SELECT        dbo.mrl_page.id, dbo.mrl_page.idParent, dbo.mrl_page.idHistory, dbo.mrl_page.securityGroup, dbo.mrl_pageRevision.title, dbo.mrl_pageRevision.info, dbo.mrl_page.visible, 
                         dbo.mrl_pageRevision.modifiedDate, dbo.mrl_pageRevision.modifiedBy, dbo.mrl_page.createdDate, dbo.mrl_page.createdBy, dbo.mrl_page.deleted, dbo.mrl_page.quicklink, 
                         dbo.mrl_page.app, dbo.mrl_page.gModifiedBy, dbo.mrl_page.gModifiedDate, dbo.mrl_pageRevision.editSession, dbo.mrl_page.locked, dbo.mrl_page.lockedBy, dbo.mrl_page.lockedDate, 
                         dbo.mrl_page.state,
                             (SELECT        TOP (1) idHistory
                               FROM            dbo.mrl_siteHistory
                               WHERE        (id = dbo.mrl_page.id) AND (state <> 'preview')
                               ORDER BY usedDate DESC) AS idHistoryDraft,
                             (SELECT        TOP (1) title
                               FROM            dbo.mrl_siteHistory AS mrl_siteHistory_1
                               WHERE        (id = dbo.mrl_page.id) AND (state <> 'preview')
                               ORDER BY usedDate DESC) AS titleDraft,
                             (SELECT        TOP (1) menu
                               FROM            dbo.mrl_siteHistory AS mrl_siteHistory_2
                               WHERE        (id = dbo.mrl_page.id) AND (state <> 'preview')
                               ORDER BY usedDate DESC) AS menuDraft,
                             (SELECT        TOP (1) actionDate
                               FROM            dbo.mrl_pageState
                               WHERE        (id = dbo.mrl_page.id) AND (action = 'pending') AND (idHistory <= dbo.mrl_page.idHistory)
                               ORDER BY actionId DESC) AS submittedDate,
                             (SELECT        TOP (1) actionBy
                               FROM            dbo.mrl_pageState AS mrl_pageState_1
                               WHERE        (id = dbo.mrl_page.id) AND (action = 'pending') AND (idHistory <= dbo.mrl_page.idHistory)
                               ORDER BY actionId DESC) AS submittedBy, dbo.mrl_page.sortIndex, dbo.mrl_pageRevision.menu, dbo.mrl_pageRevision.url,
                             (SELECT        TOP (1) actionDate
                               FROM            dbo.mrl_pageState AS mrl_pageState_2
                               WHERE        (id = dbo.mrl_page.id) AND (action = 'approved') AND (idHistory <= dbo.mrl_page.idHistory)
                               ORDER BY actionId DESC) AS approvedDate,
                             (SELECT        TOP (1) actionBy
                               FROM            dbo.mrl_pageState AS mrl_pageState_1
                               WHERE        (id = dbo.mrl_page.id) AND (action = 'approved') AND (idHistory <= dbo.mrl_page.idHistory)
                               ORDER BY actionId DESC) AS approvedBy, dbo.mrl_pageRevision.urlHash, dbo.mrl_page.template, dbo.mrl_page.owner, dbo.mrl_page.reviewedBy, dbo.mrl_page.reviewedDate, 
                         dbo.mrl_page.SSL
FROM            dbo.mrl_page INNER JOIN
                         dbo.mrl_pageRevision ON dbo.mrl_page.idHistory = dbo.mrl_pageRevision.idHistory

GO
/****** Object:  View [dbo].[mrl_sitePublic]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mrl_sitePublic]
AS
SELECT        id, idParent, securityGroup, title, info, visible, modifiedDate, modifiedBy, createdDate, createdBy, deleted, quicklink, app, gModifiedBy, gModifiedDate, submittedBy, submittedDate, sortIndex, menu, url, urlHash, 
                         template, owner, approvedBy, approvedDate, reviewedBy, reviewedDate, SSL, idHistory
FROM            dbo.mrl_siteAdmin
WHERE        (visible = 'T') AND (deleted = 'F') AND (approvedBy IS NOT NULL) AND (LOWER(title) <> '_slides')

GO
/****** Object:  View [dbo].[mrl_marketing_redirects]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mrl_marketing_redirects]
AS
SELECT        dbo.mrl_redirect.r_id, dbo.mrl_redirect.url, dbo.mrl_redirect.redirectToUrl, dbo.mrl_redirect.MD5, dbo.mrl_redirect.redirect, dbo.mrl_redirect.redirectType, dbo.mrl_redirect.usedDate, 
                         dbo.mrl_redirect.createdDate, dbo.mrl_redirect.createdBy, dbo.mrl_redirect.modifiedDate, dbo.mrl_redirect.modifiedBy, dbo.mrl_redirect.deleted, dbo.mrl_redirectUTM.utm_campaign, 
                         dbo.mrl_redirectUTM.utm_medium, dbo.mrl_redirectUTM.utm_source, dbo.mrl_redirectUTM.utm_term, dbo.mrl_redirectUTM.expires
FROM            dbo.mrl_redirect INNER JOIN
                         dbo.mrl_redirectUTM ON dbo.mrl_redirect.r_id = dbo.mrl_redirectUTM.r_id INNER JOIN
                         dbo.mrl_redirectType ON dbo.mrl_redirect.redirectType = dbo.mrl_redirectType.redirectType
WHERE        (dbo.mrl_redirect.redirectType = 'marketing')

GO
ALTER TABLE [dbo].[mrl_page]  WITH NOCHECK ADD  CONSTRAINT [FK_mrl_page_mrl_pageGroup] FOREIGN KEY([securityGroup])
REFERENCES [dbo].[mrl_pageGroup] ([GroupName])
GO
ALTER TABLE [dbo].[mrl_page] CHECK CONSTRAINT [FK_mrl_page_mrl_pageGroup]
GO
ALTER TABLE [dbo].[mrl_page]  WITH NOCHECK ADD  CONSTRAINT [FK_mrl_page_mrl_template] FOREIGN KEY([template])
REFERENCES [dbo].[mrl_template] ([cfcName])
GO
ALTER TABLE [dbo].[mrl_page] CHECK CONSTRAINT [FK_mrl_page_mrl_template]
GO
ALTER TABLE [dbo].[mrl_pageComment]  WITH CHECK ADD  CONSTRAINT [FK_mrl_pageComment_mrl_pageRevision] FOREIGN KEY([idHistory])
REFERENCES [dbo].[mrl_pageRevision] ([idHistory])
GO
ALTER TABLE [dbo].[mrl_pageComment] CHECK CONSTRAINT [FK_mrl_pageComment_mrl_pageRevision]
GO
ALTER TABLE [dbo].[mrl_pageGroupMember]  WITH CHECK ADD  CONSTRAINT [FK_mrl_pageGroupMember_mrl_pageGroup] FOREIGN KEY([GroupName])
REFERENCES [dbo].[mrl_pageGroup] ([GroupName])
GO
ALTER TABLE [dbo].[mrl_pageGroupMember] CHECK CONSTRAINT [FK_mrl_pageGroupMember_mrl_pageGroup]
GO
ALTER TABLE [dbo].[mrl_pageMoveLog]  WITH CHECK ADD  CONSTRAINT [FK_mrl_pageMoveLog_mrl_page] FOREIGN KEY([id])
REFERENCES [dbo].[mrl_page] ([id])
GO
ALTER TABLE [dbo].[mrl_pageMoveLog] CHECK CONSTRAINT [FK_mrl_pageMoveLog_mrl_page]
GO
ALTER TABLE [dbo].[mrl_pageRevision]  WITH CHECK ADD  CONSTRAINT [FK_mrl_pageRevision_mrl_page] FOREIGN KEY([id])
REFERENCES [dbo].[mrl_page] ([id])
GO
ALTER TABLE [dbo].[mrl_pageRevision] CHECK CONSTRAINT [FK_mrl_pageRevision_mrl_page]
GO
ALTER TABLE [dbo].[mrl_pageState]  WITH CHECK ADD  CONSTRAINT [FK_approval_mrl_pageRevision] FOREIGN KEY([idHistory])
REFERENCES [dbo].[mrl_pageRevision] ([idHistory])
GO
ALTER TABLE [dbo].[mrl_pageState] CHECK CONSTRAINT [FK_approval_mrl_pageRevision]
GO
ALTER TABLE [dbo].[mrl_redirect]  WITH CHECK ADD  CONSTRAINT [FK_redirects_mrl_redirectType] FOREIGN KEY([redirectType])
REFERENCES [dbo].[mrl_redirectType] ([redirectType])
GO
ALTER TABLE [dbo].[mrl_redirect] CHECK CONSTRAINT [FK_redirects_mrl_redirectType]
GO
ALTER TABLE [dbo].[mrl_redirectUTM]  WITH CHECK ADD  CONSTRAINT [FK_redirectGoogleAttributes_mrl_redirect] FOREIGN KEY([r_id])
REFERENCES [dbo].[mrl_redirect] ([r_id])
GO
ALTER TABLE [dbo].[mrl_redirectUTM] CHECK CONSTRAINT [FK_redirectGoogleAttributes_mrl_redirect]
GO
ALTER TABLE [dbo].[mrl_securityGroupMember]  WITH CHECK ADD  CONSTRAINT [FK_mrl_securityGroupMember_mrl_securityUsers] FOREIGN KEY([login])
REFERENCES [dbo].[mrl_securityUsers] ([login])
GO
ALTER TABLE [dbo].[mrl_securityGroupMember] CHECK CONSTRAINT [FK_mrl_securityGroupMember_mrl_securityUsers]
GO
ALTER TABLE [dbo].[mrl_securityGroupMember]  WITH CHECK ADD  CONSTRAINT [FK_tblGroupMember_tblGroup] FOREIGN KEY([GroupName])
REFERENCES [dbo].[mrl_securityGroups] ([GroupName])
GO
ALTER TABLE [dbo].[mrl_securityGroupMember] CHECK CONSTRAINT [FK_tblGroupMember_tblGroup]
GO
/****** Object:  StoredProcedure [dbo].[mrl_getBreadCrumbs]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<William Eatman>
-- Create date: <10-15-2008>
-- Description:	<get the breadcrumbs for a page id>
-- =============================================
CREATE PROCEDURE [dbo].[mrl_getBreadCrumbs]
	-- Add the parameters for the stored procedure here
	@ID int = -1,
	@public bit = 'true'
AS
BEGIN

DECLARE @view varchar(30)

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

IF @public = 'true'
	BEGIN
		WITH PagesList (id, idparent, menu, mylevel)
		AS
		(
			-- Anchor member definition
			SELECT id, idparent, menu, (0) as mylevel FROM mrl_sitePublic WHERE id=@ID
			UNION ALL

			-- Recursive member definition
			SELECT c.id, c.idparent, c.menu, p.mylevel + 1 From mrl_sitePublic as c
			INNER JOIN PagesList as p
			ON c.id = p.idparent
		)
		-- Statement that executes the CTE
		SELECT id, idParent, menu FROM PagesList ORDER BY mylevel DESC
	END
ELSE
	BEGIN
		WITH PagesList (id, idparent, menu, mylevel)
		AS
		(
			-- Anchor member definition
			SELECT id, idparent, menu, (0) as mylevel FROM mrl_siteAdmin WHERE id=@ID
			UNION ALL

			-- Recursive member definition
			SELECT c.id, c.idparent, c.menu, p.mylevel + 1 From mrl_siteAdmin as c
			INNER JOIN PagesList as p
			ON c.id = p.idparent
		)
		-- Statement that executes the CTE
		SELECT id, idParent, menu FROM PagesList ORDER BY mylevel DESC
	END
END


GO
/****** Object:  StoredProcedure [dbo].[mrl_getChildren]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<William Eatman>
-- Create date: <10-15-2008>
-- Description:	<get children pages by parent page id>
-- =============================================
CREATE PROCEDURE [dbo].[mrl_getChildren]
	-- Add the parameters for the stored procedure here
	@id int,				-- Parent ID
	@summary bit = 'true',	-- true for (id, idParent, menu, count, visible). False for * (good for getting custom info)
	@public bit = 'true',	-- true for all public pages, false for ALL pages (hidden, deleted, etc)
	@menuOrder bit = 'true'-- true for children ordered by menu
AS
BEGIN
	

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @menuOrder = 'true'
		begin	
		if @public = 'false'
			begin
			if @summary = 'false'
				begin
				SELECT *, (select count(*) from mrl_siteAdmin as SP2 where SP2.idParent = SP.id) as childCount FROM mrl_siteAdmin as SP WHERE idParent=@id Order By menu
				end
			else
				begin
				SELECT id, idParent, menu, (select count(*) from mrl_siteAdmin as SP2 where SP2.idParent = SP.id) as childCount, visible FROM mrl_siteAdmin as SP WHERE idParent=@id Order By menu
				end
			end
		else
			begin
			if @summary = 'false'		
				begin
				SELECT *, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount FROM mrl_sitePublic as SP WHERE idParent=@id Order By menu
				end
			else
				begin
				SELECT id, idParent, menu, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount, visible FROM mrl_sitePublic as SP WHERE idParent=@id Order By menu
				end
			end
		end
	else
		begin	
		if @public = 'false'
			begin
			if @summary = 'false'
				begin
				SELECT *, (select count(*) from mrl_siteAdmin as SP2 where SP2.idParent = SP.id) as childCount FROM mrl_siteAdmin as SP WHERE idParent=@id Order By sortIndex
				end
			else
				begin
				SELECT id, idParent, menu, (select count(*) from mrl_siteAdmin as SP2 where SP2.idParent = SP.id) as childCount, visible FROM mrl_siteAdmin as SP WHERE idParent=@id Order By sortIndex
				end
			end
		else
			begin
			if @summary = 'false'		
				begin
				SELECT *, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount FROM mrl_sitePublic as SP WHERE idParent=@id Order By sortIndex
				end
			else
				begin
				SELECT id, idParent, menu, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount, visible FROM mrl_sitePublic as SP WHERE idParent=@id Order By sortIndex
				end
			end
		end
	end


GO
/****** Object:  StoredProcedure [dbo].[mrl_getFileDirectory]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[mrl_getFileDirectory] 
	-- Add the parameters for the stored procedure here
	@dirId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/* select * from fileDir */

	WITH dirList2(dirId, dirIdParent, directoryName, mylevel)
	AS
	(
		-- Anchor member definition
		SELECT dirId, dirIdParent, directoryName, (0) as mylevel FROM fileDir WHERE dirId = @dirId
		UNION ALL
		-- Recursive member definition
		SELECT c.dirId, c.dirIdParent, c.directoryName, p.mylevel + 1 From fileDir as c
		INNER JOIN DirList2 as p
		ON c.dirId = p.dirIdParent
	) 
	SELECT dirId, dirIdParent, directoryName, mylevel from dirList2

    -- Insert statements for procedure here
END



GO
/****** Object:  StoredProcedure [dbo].[mrl_getPage]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Andy Warner>
-- Create date: <5-6-2008>
-- Description:	<get a certain page by id>
-- =============================================
CREATE PROCEDURE [dbo].[mrl_getPage] 
	-- Add the parameters for the stored procedure here
	@id int,
	@public bit = 'true'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @public = 'true'
		BEGIN
		-- Insert statements for procedure here
		SELECT * FROM mrl_sitePublic WHERE id=@id
		END
	ELSE
		BEGIN
		-- Insert statements for procedure here
		SELECT * FROM mrl_siteAdmin WHERE id=@id
		END
END


GO
/****** Object:  StoredProcedure [dbo].[mrl_getPeers]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<William Eatman>
-- Create date: <10-15-2008>
-- Description:	<get peer pages by page id, NOTE: Also returns the passed page id>
-- =============================================
CREATE PROCEDURE [dbo].[mrl_getPeers]
	-- Add the parameters for the stored procedure here
	@id int,				-- Parent ID
	@summary bit = 'true',	-- true for (id, idParent, title, count, visible). False for * (good for getting custom info)
	@public bit = 'true',	-- true for all public pages, false for ALL pages (hidden, deleted, etc)
	@menuOrder bit = 'true'-- true for children ordered by menu
AS
BEGIN
	

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @menuOrder = 'true'
		begin
		if @public = 'false'
			begin
			if @summary = 'false'
				begin
				SELECT *, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount FROM mrl_siteAdmin as SP WHERE idParent = (SELECT idParent from mrl_siteAdmin where id = @id) Order By menu
				end
			else
				begin
				SELECT id, idParent, menu, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount, visible FROM mrl_siteAdmin as SP WHERE idParent = (SELECT idParent from mrl_siteAdmin where id = @id) Order By menu
				end
			end
		else
			begin
			if @summary = 'false'		
				begin
				SELECT *, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount FROM mrl_sitePublic as SP WHERE idParent=(SELECT idParent from mrl_sitePublic where id = @id) Order By menu
				end
			else
				begin
				SELECT id, idParent, menu, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount, visible FROM mrl_sitePublic as SP WHERE idParent=(SELECT idParent from mrl_sitePublic where id = @id) Order By menu
				end
			end
		end	
		else
		begin
			if @public = 'false'
			begin
			if @summary = 'false'
				begin
				SELECT *, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount FROM mrl_siteAdmin as SP WHERE idParent = (SELECT idParent from mrl_siteAdmin where id = @id) Order By sortIndex
				end
			else
				begin
				SELECT id, idParent, menu, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount, visible FROM mrl_siteAdmin as SP WHERE idParent = (SELECT idParent from mrl_siteAdmin where id = @id) Order By sortIndex
				end
			end
		else
			begin
			if @summary = 'false'		
				begin
				SELECT *, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount FROM mrl_sitePublic as SP WHERE idParent=(SELECT idParent from mrl_sitePublic where id = @id) Order By sortIndex
				end
			else
				begin
				SELECT id, idParent, menu, (select count(*) from mrl_sitePublic as SP2 where SP2.idParent = SP.id) as childCount, visible FROM mrl_sitePublic as SP WHERE idParent=(SELECT idParent from mrl_sitePublic where id = @id) Order By sortIndex
				end
			end
		end
END


GO
/****** Object:  StoredProcedure [dbo].[mrl_userFunctions]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andy Warner
-- Create date: 3/28/2008
-- Description:	get all the groups for the user
-- =============================================
CREATE PROCEDURE [dbo].[mrl_userFunctions] 
	-- Add the parameters for the stored procedure here
	@login nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT g.groupName, groupDesc from mrl_pageGroupMember  as gm 
	inner join mrl_pageGroup as g
	on g.groupName = gm.groupName
where @login = [login] and type = 'function'
ORDER BY groupDesc ASC
END


GO
/****** Object:  StoredProcedure [dbo].[mrl_userGroups]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andy Warner
-- Create date: 3/28/2008
-- Description:	get all the groups for the user
-- =============================================
CREATE PROCEDURE [dbo].[mrl_userGroups] 
	-- Add the parameters for the stored procedure here
	@login nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT g.groupName, groupDesc from mrl_pageGroupMember  as gm 
	inner join mrl_pageGroup as g
	on g.groupName = gm.groupName
where @login = [login] and type = 'pageGroup'
ORDER BY groupDesc ASC
END


GO
/****** Object:  StoredProcedure [dbo].[mrl_userRoles]    Script Date: 3/19/2016 11:37:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andy Warner
-- Create date: 3/28/2008
-- Description:	get all the groups for the user
-- =============================================
CREATE PROCEDURE [dbo].[mrl_userRoles] 
	-- Add the parameters for the stored procedure here
	@login nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT g.groupName, groupDesc from mrl_pageGroupMember  as gm 
	inner join mrl_pageGroup as g
	on g.groupName = gm.groupName
where @login = [login] and type = 'role'
ORDER BY groupDesc ASC
END


GO
