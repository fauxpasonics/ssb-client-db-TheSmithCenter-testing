CREATE TABLE [mdm].[CompositeHouseholds]
(
[ch_id] [int] NOT NULL IDENTITY(1, 1),
[SSB_CRMSYSTEM_HOUSEHOLD_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastNameAddress_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [mdm].[CompositeHouseholds] ADD CONSTRAINT [PK_CompositeHouseholds_ch_id] PRIMARY KEY CLUSTERED  ([ch_id]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_CompositeHouseholds_LastNameAddress_ID] ON [mdm].[CompositeHouseholds] ([LastNameAddress_ID]) INCLUDE ([SSB_CRMSYSTEM_HOUSEHOLD_ID]) WITH (DATA_COMPRESSION = PAGE)
GO
