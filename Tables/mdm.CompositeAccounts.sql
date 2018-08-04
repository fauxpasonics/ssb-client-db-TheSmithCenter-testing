CREATE TABLE [mdm].[CompositeAccounts]
(
[ssb_crmsystem_acct_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressCompany_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ca_id] [int] NOT NULL IDENTITY(1, 1),
[Address_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [mdm].[CompositeAccounts] ADD CONSTRAINT [PK_CompositeAccounts_ca_id] PRIMARY KEY CLUSTERED  ([ca_id]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_CompositeAccounts_Address_ID] ON [mdm].[CompositeAccounts] ([Address_ID]) INCLUDE ([ssb_crmsystem_acct_id]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_CompositeAccounts_AddressCompany] ON [mdm].[CompositeAccounts] ([AddressCompany_ID]) INCLUDE ([ssb_crmsystem_acct_id]) WITH (DATA_COMPRESSION = PAGE)
GO
