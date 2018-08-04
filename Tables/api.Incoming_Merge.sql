CREATE TABLE [api].[Incoming_Merge]
(
[PK_MergeID] [int] NOT NULL IDENTITY(1, 1),
[Winning_GUID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loser_GUID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GUIDType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Winning_DimCustomerID] [int] NULL,
[Loser_DimCustomerID] [int] NULL,
[CreatedDate] [datetime] NULL,
[LastAttemptedDate] [datetime] NULL,
[SFUserID] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [api].[Incoming_Merge] ADD CONSTRAINT [PK_Incoming_Merge_PK_MergeID] PRIMARY KEY CLUSTERED  ([PK_MergeID]) WITH (DATA_COMPRESSION = PAGE)
GO
