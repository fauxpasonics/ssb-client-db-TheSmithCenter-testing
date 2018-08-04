CREATE TABLE [dbo].[DimCustomerMatchkey]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[DimCustomerID] [int] NOT NULL,
[MatchkeyID] [int] NOT NULL,
[MatchkeyValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertDate] [datetime] NULL CONSTRAINT [DF_DimCustomerMatchkey_InsertDate] DEFAULT (getdate()),
[UpdateDate] [datetime] NULL CONSTRAINT [DF_DimCustomerMatchkey_UpdateDate] DEFAULT (getdate())
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[DimCustomerMatchkey] ADD CONSTRAINT [PK_DimCustomerMatchkey_ID] PRIMARY KEY CLUSTERED  ([ID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomerMatchkey_DimCustomerID] ON [dbo].[DimCustomerMatchkey] ([DimCustomerID]) INCLUDE ([MatchkeyID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomerMatchkey_DimCustomerID_MatchkeyID] ON [dbo].[DimCustomerMatchkey] ([DimCustomerID], [MatchkeyID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomerMatchkey_ID] ON [dbo].[DimCustomerMatchkey] ([ID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomerMatchkey_MatchkeyValue] ON [dbo].[DimCustomerMatchkey] ([MatchkeyValue]) WITH (DATA_COMPRESSION = PAGE)
GO
