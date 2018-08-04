CREATE TABLE [audit].[ChangeLogDetail]
(
[ChangedTable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChangeType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChangedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChangedOn] [datetime] NULL,
[OldValue] [xml] NULL,
[NewValue] [xml] NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
