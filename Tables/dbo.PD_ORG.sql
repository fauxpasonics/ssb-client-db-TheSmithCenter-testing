CREATE TABLE [dbo].[PD_ORG]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ORG] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[INDUSTRY] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ORG_TYPE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FD_MATCHER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MM_MATCHER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MATCH_RATIO] [numeric] (18, 2) NULL,
[MATCH_COMMENTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMMENTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_USER] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LAST_DATETIME] [datetime] NULL,
[ZID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[PD_ORG] ADD CONSTRAINT [PK_PD_ORG] PRIMARY KEY CLUSTERED  ([ETLSID], [ORG])
GO
