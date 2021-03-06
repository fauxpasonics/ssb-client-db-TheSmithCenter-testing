SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[rptCust_EventBySeason_SSB]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

		SELECT DISTINCT
                event.SEASON
              , event.EVENT
              , event.NAME COLLATE SQL_Latin1_General_CP1_CS_AS + ' ('
                + event.EVENT + ')' + ' (' + CAST(CAST(event.DATE AS DATE) AS VARCHAR(25)) + ' ' + CAST(event.TIME AS VARCHAR(25)) + ')' AS EventName
			  , event.DATE
			  , event.TIME
        FROM    dbo.TK_EVENT event
                JOIN dbo.TK_SEASON season ON season.SEASON = event.SEASON
        WHERE   event.SEASON IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
                AND event.ETYPE IN (SELECT Item FROM [dbo].[SplitSSB] (@EventType,','))
                AND event.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
		ORDER BY event.DATE, event.TIME
    END




GO
