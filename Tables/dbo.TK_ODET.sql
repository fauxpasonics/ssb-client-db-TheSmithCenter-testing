CREATE TABLE [dbo].[TK_ODET]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SEASON] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[CUSTOMER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SEQ] [bigint] NOT NULL,
[ITEM] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_DATE] [datetime] NULL,
[I_OQTY] [bigint] NULL,
[I_PT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_PRICE] [numeric] (18, 2) NULL,
[I_DISC] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_DAMT] [numeric] (18, 2) NULL,
[I_PAY_MODE] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ITEM_DELIVERY_ID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_GCDOC] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_PRQTY] [bigint] NULL,
[I_PL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_BAL] [numeric] (18, 2) NULL,
[I_PAY] [numeric] (18, 2) NULL,
[I_PAYQ] [int] NULL,
[LOCATION_PREF] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_SPECIAL] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_MARK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_DISP] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_ACUST] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_PRI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_DMETH] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_FPRICE] [numeric] (18, 2) NULL,
[I_BPTYPE] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PROMO] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ITEM_PREF] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TAG] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_CHG] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_CPRICE] [numeric] (18, 2) NULL,
[I_CPAY] [numeric] (18, 2) NULL,
[I_FPAY] [numeric] (18, 2) NULL,
[INREFSOURCE] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INREFDATA] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_SCHG] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_SCAMT] [numeric] (18, 2) NULL,
[I_SCPAY] [numeric] (18, 2) NULL,
[ORIG_SALECODE] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ORIGTS_USER] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ORIGTS_DATETIME] [datetime] NULL,
[I_PKG] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[E_SBLS_1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_USER] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LAST_DATETIME] [datetime] NULL,
[ZID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[TK_ODET] ADD CONSTRAINT [PK_TK_ODET] PRIMARY KEY CLUSTERED  ([ETLSID], [SEASON], [CUSTOMER], [SEQ])
GO
CREATE NONCLUSTERED INDEX [IDX_CUSTOMER] ON [dbo].[TK_ODET] ([CUSTOMER])
GO
CREATE NONCLUSTERED INDEX [IDX_I_PL] ON [dbo].[TK_ODET] ([I_PL])
GO
CREATE NONCLUSTERED INDEX [IDX_I_PT] ON [dbo].[TK_ODET] ([I_PT])
GO
CREATE NONCLUSTERED INDEX [IDX_ITEM] ON [dbo].[TK_ODET] ([ITEM])
GO
CREATE NONCLUSTERED INDEX [IDX_ORIG_SALECODE] ON [dbo].[TK_ODET] ([ORIG_SALECODE])
GO
CREATE NONCLUSTERED INDEX [IDX_SEASON] ON [dbo].[TK_ODET] ([SEASON])
GO
CREATE NONCLUSTERED INDEX [IDX_SEQ] ON [dbo].[TK_ODET] ([SEQ])
GO
