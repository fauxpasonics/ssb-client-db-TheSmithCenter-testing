CREATE TABLE [dbo].[CD_OUTPUT_ERRORS]
(
[SourceContactId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Input_Custom2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Input_SourceSystem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
