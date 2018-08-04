SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[rptCust_EventTagBySeason_PostEvent_SSB]
    @Season VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        SET NOCOUNT ON

		--DECLARE 
		--	 @Season VARCHAR(500) = 'TSC1718'
		--	,@Venue VARCHAR(500) = 'BWAY,LHM,RH'

		IF OBJECT_ID('tempdb..#Tag') IS NOT NULL
			DROP TABLE #Tag

		SELECT DISTINCT 
			Tag
		INTO #Tag
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

        SELECT  *
        FROM ( 
				SELECT DISTINCT
					 CASE WHEN event.TAG LIKE '%BWAY%' THEN 'BWAY'
						WHEN event.TAG LIKE '%HOUSE%' THEN 'HOUSE'
						WHEN event.TAG LIKE '%RESCO%' THEN 'RESCO'
						WHEN event.TAG LIKE '%4WALL%' THEN '4WALL'
						END AS TAG
					,CASE WHEN event.TAG LIKE '%BWAY%'
						THEN 'Broadway Performances'
						WHEN event.TAG LIKE '%HOUSE%'
						THEN 'House Presentations'
						WHEN event.TAG LIKE '%RESCO%'
						THEN 'Resident Companies'
						WHEN event.TAG LIKE '%4WALL%' THEN 'Rentals'
						END AS EventTagName
				FROM #Tag event
            ) x
        WHERE x.TAG IS NOT NULL
    END
GO
