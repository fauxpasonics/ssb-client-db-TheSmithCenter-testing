CREATE TABLE [mdm].[version]
(
[mdm_version] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[releasedate] [datetime] NULL,
[notes] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
