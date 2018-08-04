CREATE TABLE [etl].[ClientSetting]
(
[ClientSettingId] [int] NOT NULL IDENTITY(1, 1),
[Setting] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[UpdatedDate] [datetime] NOT NULL
)
GO
ALTER TABLE [etl].[ClientSetting] ADD CONSTRAINT [PK__ClientSe__6A05CC8803A36447] PRIMARY KEY CLUSTERED  ([ClientSettingId])
GO
