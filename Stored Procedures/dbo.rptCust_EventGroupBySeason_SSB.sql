SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--exec [dbo].[rptCust_EventGroupBySeason_SSB] 'TSC1516','BLV' , 'BWAY'

CREATE PROCEDURE [dbo].[rptCust_EventGroupBySeason_SSB]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

/*
DECLARE @Season VARCHAR(500) = 'TSC1516'
DECLARE @EventType VARCHAR(500) = 'BLV'
DECLARE @Venue VARCHAR(500) = 'BWAY'
*/

        SELECT  DISTINCT
                event.SEASON
              , event.EGROUP
              , EGroup.NAME COLLATE SQL_Latin1_General_CP1_CS_AS + ' ('
                + event.EGROUP + ')' AS EventName
        FROM    dbo.TK_EVENT event
                JOIN dbo.TK_SEASON season 
					ON season.SEASON = event.SEASON
                JOIN dbo.TK_EGROUP EGroup 
					ON EGroup.EGROUP = event.EGROUP
					AND egroup.SEASON = event.SEASON
        WHERE   event.SEASON IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
                AND event.ETYPE IN (SELECT Item FROM  [dbo].[SplitSSB] (@EventType,','))
                AND event.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
    END



GO
