CREATE TABLE [dbo].[rptCust_EventTagParsing_SSB]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[SEASON] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG_CODE] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [dbo].[rptCust_EventTagParsing_SSB] ADD CONSTRAINT [PK__rptCust___3214EC07F378CCF7] PRIMARY KEY CLUSTERED  ([Id])
GO
