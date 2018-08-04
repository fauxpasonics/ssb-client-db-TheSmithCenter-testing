CREATE TABLE [etl].[EventLog]
(
[LogId] [bigint] NOT NULL IDENTITY(1, 1),
[BatchId] [uniqueidentifier] NOT NULL,
[Client] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventLevel] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventSource] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventCategory] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogEvent] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogMessage] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDate] [datetime] NOT NULL,
[ExecutionId] [uniqueidentifier] NOT NULL,
[UserName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceSystem] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
ALTER TABLE [etl].[EventLog] ADD CONSTRAINT [PK__EventLog__5E548648A42381E0] PRIMARY KEY CLUSTERED  ([LogId])
GO
