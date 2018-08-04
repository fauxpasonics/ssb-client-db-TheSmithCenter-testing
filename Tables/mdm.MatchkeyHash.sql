CREATE TABLE [mdm].[MatchkeyHash]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[MatchkeyHashID] [uniqueidentifier] NOT NULL,
[MatchkeyHashIDName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MatchkeyHashPlainText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchkeyHash] [varbinary] (32) NULL,
[InsertDate] [datetime] NULL CONSTRAINT [DF_MatchkeyHash_InsertDate] DEFAULT (getdate())
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [mdm].[MatchkeyHash] ADD CONSTRAINT [PK_MatchkeyHash_ID] PRIMARY KEY CLUSTERED  ([ID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_MatchkeyHash_MatchkeyHashIdentifier] ON [mdm].[MatchkeyHash] ([MatchkeyHashIDName], [MatchkeyHash]) INCLUDE ([ID], [MatchkeyHashID], [MatchkeyHashPlainText]) WITH (DATA_COMPRESSION = PAGE)
GO
