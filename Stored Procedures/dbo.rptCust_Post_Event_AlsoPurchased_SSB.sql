SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC dbo.rptCust_Post_Event_AlsoPurchased_SSB  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_AlsoPurchased_SSB]
    @TYPE AS VARCHAR(2)
  , @GROUPING AS VARCHAR(500)
  , @Season AS VARCHAR(15)
AS
    BEGIN
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        SET NOCOUNT ON

		--DECLARE @StartTime DATETIME = GETDATE()
		--DECLARE @StepStartTime DATETIME = GETDATE()

		--DECLARE @TYPE AS VARCHAR(2) = 'EG'
		--DECLARE @GROUPING AS VARCHAR(500) = 'TKI'
		--DECLARE @Season AS VARCHAR(15) = 'TSC1718'

        INSERT  [dbo].[TempVariableTrap]
        SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                + '|'
                , GETDATE()
                , 'PostEvent - AlsoPurchasedEnter' 

        DECLARE @FIRSTDATE AS DATETIME

		IF OBJECT_ID('tempdb..#GroupingTemp') IS NOT NULL
			DROP TABLE #GroupingTemp
        SELECT  Item
        INTO    #GroupingTemp
        FROM    [dbo].[SplitSSB](@GROUPING, ',')

		--SELECT 'GroupingTemp' AS Step, @StartTime AS StartTime, DATEDIFF(ss, @StartTime, GETDATE()) AS StepDuration
		--SELECT @StepStartTime = GETDATE()
		
		IF OBJECT_ID('tempdb..#SeasonTemp') IS NOT NULL
			DROP TABLE #SeasonTemp
        SELECT  s.Item, tks.SORT_ORDER
        INTO    #SeasonTemp
        FROM    [dbo].[SplitSSB](@Season, ',') s
		INNER JOIN dbo.TK_SEASON tks WITH ( NOLOCK ) 
			ON  s.Item = tks.SEASON

		--SELECT 'SeasonTemp' AS Step, @StepStartTime AS StartTime, DATEDIFF(ss, @StepStartTime, GETDATE()) AS StepDuration
		--SELECT @StepStartTime = GETDATE()

        --SELECT DISTINCT
        --        TAG
        --INTO    #tagtemp
        --FROM    dbo.SplitSSB(@GROUPING, ',') s
        --        JOIN TK_EVENT ON PATINDEX('% ' + s.Item + ' %',
        --                                  ' ' + TAG COLLATE SQL_Latin1_General_CP1_CI_AS
        --                                  + ' ') > 0 

		IF OBJECT_ID('tempdb..#tagtemp') IS NOT NULL
			DROP TABLE #tagtemp
		SELECT DISTINCT TAG
		INTO #tagtemp
		FROM dbo.rptCust_EventTagParsing_SSB a
		JOIN #SeasonTemp b ON b.Item COLLATE SQL_Latin1_General_CP1_CI_AS = a.SEASON
		JOIN #GroupingTemp c ON c.Item COLLATE SQL_Latin1_General_CP1_CI_AS = a.TAG_CODE

		--SELECT 'TagTemp' AS Step, @StepStartTime AS StartTime, DATEDIFF(ss, @StepStartTime, GETDATE()) AS StepDuration
		--SELECT @StepStartTime = GETDATE()

		IF OBJECT_ID('tempdb..#EventFilter') IS NOT NULL
			DROP TABLE #EventFilter
		SELECT ev.SEASON, ev.EVENT, ev.DATE
		INTO #EventFilter
		FROM dbo.TK_EVENT ev WITH ( NOLOCK )
		INNER JOIN #SeasonTemp st
			ON ev.SEASON = st.Item
        WHERE     ( ( @TYPE = 'EG'
                        AND ev.EGROUP IN ( SELECT
                                            Item
                                            FROM
                                            #GroupingTemp )
                        )
                        OR ( @TYPE = 'EY'
                            AND ev.ETYPE IN ( SELECT
                                            Item
                                            FROM
                                            #GroupingTemp )
                            )
                        OR ( @TYPE = 'EV'
                            AND ev.EVENT IN ( SELECT
                                            Item
                                            FROM
                                            #GroupingTemp )
                            )
                        OR ( @TYPE = 'EC'
                            AND ev.CLASS IN ( SELECT
                                            Item
                                            FROM
                                            #GroupingTemp )
                            )
                        OR ( @TYPE = 'ET'
                            AND ev.TAG IN ( SELECT
                                            TAG
                                            FROM
                                            #tagtemp )
                            )
                    )

		--SELECT 'EventFilter' AS Step, @StepStartTime AS StartTime, DATEDIFF(ss, @StepStartTime, GETDATE()) AS StepDuration
		--SELECT @StepStartTime = GETDATE()

        SET @FIRSTDATE = ( SELECT MIN(ev.DATE)
						   FROM #EventFilter ev
                         )

		--SELECT 'FirstDate' AS Step, @StepStartTime AS StartTime, DATEDIFF(ss, @StepStartTime, GETDATE()) AS StepDuration
		--SELECT @StepStartTime = GETDATE()

		IF OBJECT_ID('tempdb..#orderedHH') IS NOT NULL
			DROP TABLE #orderedHH

        CREATE TABLE #orderedHH ( customer VARCHAR(20), FirstDate DATETIME )

        CREATE CLUSTERED INDEX CUSTOMER ON #orderedHH (customer)

        INSERT INTO #orderedHH (
			 customer
			,FirstDate)
        SELECT  
			 trans.CUSTOMER AS customer
			,MIN(ef.DATE) FirstDate
        FROM dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
		INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) 
			ON  prtype.SEASON = trans.SEASON
			AND prtype.PRTYPE = trans.E_PT
		INNER JOIN #EventFilter ef
			ON  trans.EVENT = ef.EVENT
			AND trans.SEASON = ef.SEASON
        WHERE prtype.KIND <> 'H'
			AND prtype.KIND IS NOT NULL
			AND prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
        GROUP BY trans.CUSTOMER

		--SELECT 'CustomerOrders' AS Step, @StepStartTime AS StartTime, DATEDIFF(ss, @StepStartTime, GETDATE()) AS StepDuration
		--SELECT @StepStartTime = GETDATE()

-------------------------------------------------------------------
		SELECT TOP 10
			s.SORT_ORDER AS [Year],
			eGroup.NAME AS Show,
			COUNT(DISTINCT trans.CUSTOMER) AS HH,
			SUM(trans.E_OQTY_TOT) AS Tickets
		FROM dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
		INNER JOIN #orderedHH oHH 
			ON  trans.CUSTOMER = oHH.customer
		INNER JOIN dbo.TK_EVENT e WITH ( NOLOCK ) 
			ON  trans.SEASON = e.SEASON
			AND trans.EVENT = e.EVENT
		INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) 
			ON  prtype.SEASON = trans.SEASON
			AND prtype.PRTYPE = trans.E_PT
		INNER JOIN dbo.TK_EGROUP eGroup WITH ( NOLOCK ) 
			ON  trans.SEASON = eGroup.SEASON
			AND e.EGROUP = eGroup.EGROUP
		INNER JOIN dbo.TK_SEASON s WITH ( NOLOCK ) 
			ON  trans.SEASON = s.SEASON
		LEFT OUTER JOIN #EventFilter ef
			ON  trans.EVENT = ef.EVENT
			AND trans.SEASON = ef.SEASON
		WHERE ef.SEASON IS NULL
            AND prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
			AND e.DATE < @FIRSTDATE
		GROUP BY 
			s.SORT_ORDER,
			eGroup.NAME
        ORDER BY COUNT(DISTINCT trans.CUSTOMER) DESC

		--SELECT 'Transactions' AS Step, @StepStartTime AS StartTime, DATEDIFF(ss, @StepStartTime, GETDATE()) AS StepDuration
		--SELECT @StepStartTime = GETDATE()

		--SELECT 'Final' AS Step, @StartTime AS StartTime, DATEDIFF(ss, @StartTime, GETDATE()) AS TotalDuration

        DROP TABLE #orderedHH
        DROP TABLE #tagtemp

        INSERT  [dbo].[TempVariableTrap]
        SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                + '|'
                , GETDATE()
                , 'PostEvent - AlsoPurchasedExit' 


    END
GO
