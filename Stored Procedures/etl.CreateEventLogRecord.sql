SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[CreateEventLogRecord] 
(
	@BatchId NVARCHAR(50) = NULL, 
	@Client nvarchar(255) = NULL,
	@EventLevel NVARCHAR(255) = 'Info', 	
	@EventSource NVARCHAR(255) = NULL, 
	@EventCategory NVARCHAR(255) = NULL,
	@LogEvent NVARCHAR(255), 
	@LogMessage NVARCHAR(2000) = NULL,
	@ExecutionId UNIQUEIDENTIFIER = NULL
)
AS

BEGIN

SET NOCOUNT ON;

SET @Client = ISNULL(@Client, DB_NAME())

SET @BatchId = ISNULL(@BatchId, CONVERT(NVARCHAR(50), NEWID()))

BEGIN TRY

	INSERT INTO etl.EventLog (BatchId, Client, EventLevel, EventSource, EventCategory, LogEvent, LogMessage, EventDate, ExecutionId, UserName, SourceSystem)
	VALUES (@BatchId, @Client, @EventLevel, @EventSource, @EventCategory, @LogEvent, @LogMessage, GETUTCDATE(), ISNULL(@ExecutionId, NEWID()), SUSER_NAME(), HOST_NAME())

END TRY
BEGIN CATCH

END CATCH

END

GO
