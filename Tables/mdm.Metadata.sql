CREATE TABLE [mdm].[Metadata]
(
[OBJ_ID] [int] NOT NULL IDENTITY(1, 1),
[INESRT_DATE] [datetime] NULL CONSTRAINT [DF_MetaData_InsertDate] DEFAULT (getdate()),
[UPDATE_DATE] [datetime] NULL,
[OBJ_TYPE] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBJ_SCHEMA] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBJ_NAME] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COLUMN_NAME] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IS_IDENTITY] [bit] NULL,
[IS_NULLABLE] [bit] NULL,
[HAS_DEFAULT] [bit] NULL,
[DATA_TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESCRIPTION] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_REMARKS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
