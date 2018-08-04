SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE PROCEDURE [dbo].[rptCust_EventClassBySeason_PostEvent_SSB]
    @Season VARCHAR(500)
  --, @EventType VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON


        SELECT DISTINCT
                event.SEASON
              , event.CLASS
              , class.NAME COLLATE SQL_Latin1_General_CP1_CS_AS + ' ('
                + event.CLASS + ')' AS EventName
        FROM    dbo.TK_EVENT event
                JOIN dbo.TK_SEASON season ON season.SEASON = event.SEASON
                JOIN dbo.TK_CLASS class ON class.CLASS = event.CLASS
        WHERE   event.SEASON IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
                --AND event.ETYPE IN (SELECT Item FROM  [dbo].[SplitSSB] (@EventType,','))
                AND event.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
    END





GO
