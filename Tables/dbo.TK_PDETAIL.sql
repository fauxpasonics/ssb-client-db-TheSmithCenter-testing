CREATE TABLE [dbo].[TK_PDETAIL]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SEASON] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ITEM] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[I_PT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[I_PL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[UNIT_PRICE] [numeric] (18, 2) NULL,
[LAST_USER] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LAST_DATETIME] [datetime] NULL,
[ZID] [varchar] (76) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[TK_PDETAIL] ADD CONSTRAINT [PK_TK_PDETAIL] PRIMARY KEY CLUSTERED  ([ETLSID], [SEASON], [ITEM], [I_PT], [I_PL])
GO
