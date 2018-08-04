CREATE TABLE [mdm].[SSB_ID_History]
(
[SSID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sourcesystem] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssb_crmsystem_acct_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssb_crmsystem_contact_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssb_crmsystem_primary_flag] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createddate] [datetime] NOT NULL,
[SSB_HISTORY_ID] [int] NOT NULL IDENTITY(1, 1),
[SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG] [int] NULL,
[SSB_CRMSYSTEM_HOUSEHOLD_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG] [int] NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [mdm].[SSB_ID_History] ADD CONSTRAINT [PK_SSB_HISTORY_NEW] PRIMARY KEY NONCLUSTERED  ([SSB_HISTORY_ID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_SSBIDHistory_Sourcesystem] ON [mdm].[SSB_ID_History] ([sourcesystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_SSBIDHistory_AcctID] ON [mdm].[SSB_ID_History] ([ssb_crmsystem_acct_id]) INCLUDE ([createddate], [sourcesystem], [ssb_crmsystem_contact_id], [SSID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_SSBIDHISTORY_ContactID_SSID_PriFlag] ON [mdm].[SSB_ID_History] ([ssb_crmsystem_contact_id]) INCLUDE ([ssb_crmsystem_primary_flag], [SSID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_SSBIDHistory_HouseholdID] ON [mdm].[SSB_ID_History] ([SSB_CRMSYSTEM_HOUSEHOLD_ID]) INCLUDE ([createddate], [sourcesystem], [ssb_crmsystem_contact_id], [SSID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE CLUSTERED INDEX [CIX_ssb_id_history] ON [mdm].[SSB_ID_History] ([SSID], [sourcesystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_SSBIDHISTORY_SSID_SourceSystem_CreatedDate] ON [mdm].[SSB_ID_History] ([SSID], [sourcesystem], [createddate]) INCLUDE ([ssb_crmsystem_acct_id], [SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG], [ssb_crmsystem_contact_id], [SSB_CRMSYSTEM_HOUSEHOLD_ID], [SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG], [ssb_crmsystem_primary_flag]) WITH (DATA_COMPRESSION = PAGE)
GO
