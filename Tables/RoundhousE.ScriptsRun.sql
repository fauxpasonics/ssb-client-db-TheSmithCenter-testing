CREATE TABLE [RoundhousE].[ScriptsRun]
(
[id] [bigint] NOT NULL IDENTITY(1, 1),
[version_id] [bigint] NULL,
[script_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[text_of_script] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[text_hash] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[one_time_script] [bit] NULL,
[entry_date] [datetime] NULL,
[modified_date] [datetime] NULL,
[entered_by] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [RoundhousE].[ScriptsRun] ADD CONSTRAINT [PK__ScriptsR__3213E83FAE8C45B7] PRIMARY KEY CLUSTERED  ([id])
GO
