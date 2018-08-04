CREATE TABLE [RoundhousE].[Version]
(
[id] [bigint] NOT NULL IDENTITY(1, 1),
[repository_path] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entry_date] [datetime] NULL,
[modified_date] [datetime] NULL,
[entered_by] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [RoundhousE].[Version] ADD CONSTRAINT [PK__Version__3213E83F8E8B9C13] PRIMARY KEY CLUSTERED  ([id])
GO
