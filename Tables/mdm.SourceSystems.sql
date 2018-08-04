CREATE TABLE [mdm].[SourceSystems]
(
[SourceSystemID] [int] NOT NULL IDENTITY(1, 1),
[SourceSystem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDeleted] [bit] NULL,
[DateCreated] [date] NULL CONSTRAINT [DF_SourceSystems_DateCreated] DEFAULT (getdate()),
[DateUpdated] [date] NULL CONSTRAINT [DF_SourceSystems_DateUpdated] DEFAULT (getdate()),
[NameForReporting] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
