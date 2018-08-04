CREATE TABLE [audit].[ChangeLog]
(
[dimcustomerid] [int] NULL,
[ChangeType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChangeSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldRecord] [xml] NULL,
[ChangeDate] [datetime] NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
