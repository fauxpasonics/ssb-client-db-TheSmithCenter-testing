CREATE TABLE [dbo].[TK_SEAT]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SEASON] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[EVENT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[LEVEL] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SECTION] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ROW] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[NREMAIN] [bigint] NULL,
[NALLOC] [bigint] NULL,
[NPRINT] [bigint] NULL,
[NHELD] [bigint] NULL,
[NKILL] [bigint] NULL,
[SEQ] [bigint] NULL,
[CAPACITY] [bigint] NULL,
[ZID] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[TK_SEAT] ADD CONSTRAINT [PK_TK_SEAT] PRIMARY KEY CLUSTERED  ([ETLSID], [SEASON], [EVENT], [LEVEL], [SECTION], [ROW])
GO
