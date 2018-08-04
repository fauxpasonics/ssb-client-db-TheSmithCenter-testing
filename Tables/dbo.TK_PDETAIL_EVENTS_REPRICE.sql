CREATE TABLE [dbo].[TK_PDETAIL_EVENTS_REPRICE]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SEASON] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ITEM] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[I_PT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[I_PL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[VMC] [bigint] NOT NULL,
[SVMC] [bigint] NOT NULL,
[EVENT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RP_EVPRICE] [numeric] (18, 2) NULL,
[RP_EPRICE] [numeric] (18, 2) NULL,
[RP_TAX] [numeric] (18, 2) NULL,
[RP_FEE] [numeric] (18, 2) NULL,
[RP_APRICE] [numeric] (18, 2) NULL,
[RP_OQTY] [bigint] NULL,
[CHANGE_USER] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CHANGE_DATE] [datetime] NULL,
[CHANGE_TIME] [datetime] NULL,
[ZID] [varchar] (76) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[TK_PDETAIL_EVENTS_REPRICE] ADD CONSTRAINT [PK_TK_PDETAIL_EVENTS_REPRICE] PRIMARY KEY CLUSTERED  ([ETLSID], [SEASON], [ITEM], [I_PT], [I_PL], [VMC], [SVMC])
GO
