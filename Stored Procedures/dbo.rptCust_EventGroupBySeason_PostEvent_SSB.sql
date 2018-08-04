SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[rptCust_EventGroupBySeason_PostEvent_SSB]
    @Season VARCHAR(500)
  --, @EventType VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET NOCOUNT ON

		--DECLARE 
		--	 @Season VARCHAR(500) = 'TSC1718'
		--	,@Venue VARCHAR(500) = 'BWAY,LHM,RH'

		IF OBJECT_ID('tempdb..#Class') IS NOT NULL
			DROP TABLE #Class

		SELECT DISTINCT 
			event.Season,
			event.EGroup,
			event.[Name]
		INTO #Class
		FROM dbo.TK_EVENT event
		INNER JOIN dbo.TK_SEASON season 
			ON  season.SEASON = event.SEASON
		WHERE event.SEASON IN ( 
				SELECT Item
				FROM dbo.SplitSSB(@Season, ',')
			)
			AND event.Facility IS NOT NULL
			AND event.FACILITY IN (
				SELECT ITEM
				FROM dbo.SplitSSB(@Venue, ',')
			)
			AND event.EGroup IS NOT NULL

        SELECT DISTINCT
			 event.SEASON
			,event.EGROUP
			,EGroup.NAME COLLATE SQL_Latin1_General_CP1_CS_AS + ' ('
				+ event.EGROUP + ')' AS EventName
        FROM #Class event
		INNER JOIN dbo.TK_EGROUP EGroup 
			ON  EGroup.SEASON = event.SEASON
			AND EGroup.EGROUP = event.EGROUP 

    END




GO
