CREATE TABLE [mdm].[Exclusions]
(
[ExclusionID] [int] NOT NULL IDENTITY(1, 1),
[ExclusionDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExclusionSQL] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDeleted] [bit] NULL,
[DateCreated] [date] NULL CONSTRAINT [DF_Exclusions_DateCreated] DEFAULT (getdate()),
[DateUpdated] [date] NULL CONSTRAINT [DF_Exclusions_DateUpdated] DEFAULT (getdate())
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
