SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
EXEC dbo.rptCust_Post_Event_BuyingTrend_SSB   @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/

CREATE PROCEDURE [dbo].[rptCust_Post_Event_BuyingTrend_SSB]
    @TYPE AS VARCHAR(2)
  , @GROUPING AS VARCHAR(500)
  , @Season AS VARCHAR(15)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - BuyingTrendEnter' 
        --DECLARE @TYPE AS VARCHAR(2) = 'EV'
        --DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
        --DECLARE @Season AS VARCHAR(15) = 'TSC1415'
	
        CREATE TABLE #DaysOutHelper
            (
              DaysOutStart INT
            , DaysOutEnd INT
            , DaysOutLabel VARCHAR(100)
            , DaysOutClass VARCHAR(100)
            , LabelSort INT
            )

        INSERT  #DaysOutHelper
        VALUES  ( -10000000, 0, 'Same Day', '', 1 )
        INSERT  #DaysOutHelper
        VALUES  ( 1, 1, 'One Day', '', 2 )
        INSERT  #DaysOutHelper
        VALUES  ( 2, 2, 'Two Days', '', 3 )
        INSERT  #DaysOutHelper
        VALUES  ( 3, 3, 'Three Days', '', 4 )
        INSERT  #DaysOutHelper
        VALUES  ( 4, 4, 'Four Days', '', 5 )
        INSERT  #DaysOutHelper
        VALUES  ( 5, 5, 'Five Days', '', 6 )
        INSERT  #DaysOutHelper
        VALUES  ( 6, 6, 'Six Days', '', 7 )
        INSERT  #DaysOutHelper
        VALUES  ( 1, 7, '', 'DaysOutSubtotal', 8 )
        INSERT  #DaysOutHelper
        VALUES  ( 8, 14, 'One Week', '', 9 )
        INSERT  #DaysOutHelper
        VALUES  ( 15, 21, 'Two Weeks', '', 10 )
        INSERT  #DaysOutHelper
        VALUES  ( 16, 28, 'Three Weeks', '', 11 )
        INSERT  #DaysOutHelper
        VALUES  ( 29, 35, 'Four Weeks', '', 12 )
        INSERT  #DaysOutHelper
        VALUES  ( 36, 60, 'More than 30 Days', '', 13 )
        INSERT  #DaysOutHelper
        VALUES  ( 61, 90, 'More than 60 Days', '', 14 )
        INSERT  #DaysOutHelper
        VALUES  ( 91, 120, 'More than 90 Days', '', 15 )
        INSERT  #DaysOutHelper
        VALUES  ( 121, 150, 'More than 120 Days', '', 16 )
        INSERT  #DaysOutHelper
        VALUES  ( 151, 1000000, 'More than 150 Days', '', 17 )

        SELECT  Item
        INTO    #GroupingTemp
        FROM    [dbo].[SplitSSB](@GROUPING, ',')

        SELECT  Item
        INTO    #SeasonTemp
        FROM    [dbo].[SplitSSB](@Season, ',')

        --SELECT DISTINCT
        --        TAG
        --INTO    #tagtemp
        --FROM    dbo.SplitSSB(@GROUPING, ',') s
        --        JOIN TK_EVENT ON PATINDEX('% ' + s.Item + ' %',
        --                                  ' ' + TAG COLLATE SQL_Latin1_General_CP1_CI_AS
        --                                  + ' ') > 0 

		SELECT DISTINCT TAG
		INTO #tagtemp
		FROM dbo.rptCust_EventTagParsing_SSB a
		JOIN #SeasonTemp b ON b.Item COLLATE SQL_Latin1_General_CP1_CI_AS = a.SEASON
		JOIN #GroupingTemp c ON c.Item COLLATE SQL_Latin1_General_CP1_CI_AS = a.TAG_CODE 

        SELECT  trans.DATE
              , trans.TRANS_NO
              , DATEDIFF(d, trans.DATE, event.DATE) AS DaysOut
              , trans.CUSTOMER
              , trans.E_OQTY_TOT AS Qty
              , ( trans.E_PRICE * trans.E_OQTY_TOT ) AS Amt
        INTO    #Output
        FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
        INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) ON ( trans.EVENT = event.EVENT
            AND trans.SEASON = event.SEASON
            )
        INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
            AND prtype.PRTYPE = trans.E_PT
            )
		INNER JOIN #SeasonTemp st
			ON trans.SEASON  = st.Item
        WHERE   ISNULL(prtype.KIND, 'GREG') <> 'H'
                AND prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
                AND trans.E_OQTY_TOT <> 0
                AND trans.E_PRICE <> 0
                AND ( ( @TYPE = 'EG'
                        AND event.EGROUP IN ( SELECT    Item
                                              FROM      #GroupingTemp )
                      )
                      OR ( @TYPE = 'EY'
                           AND event.ETYPE IN ( SELECT  Item
                                                FROM    #GroupingTemp )
                         )
                      OR ( @TYPE = 'EV'
                           AND event.EVENT IN ( SELECT  Item
                                                FROM    #GroupingTemp )
                         )
                      OR ( @TYPE = 'EC'
                           AND event.CLASS IN ( SELECT  Item
                                                FROM    #GroupingTemp )
                         )
                      OR ( @TYPE = 'ET'
                           AND event.TAG IN ( SELECT    TAG
                                              FROM      #tagtemp )
                         )
                    )
        ORDER BY DATEDIFF(d, trans.DATE, event.DATE) ASC

--SELECT DaysOut
--, SUM(Qty) Qty
--, SUM(Amt) Amt
--, CASE WHEN DaysOut < 0 THEN 'After the Event'
--	   WHEN DaysOut = 0 THEN 'Same Day'
--	   WHEN DaysOut = 1 THEN 'One Day'
--	   WHEN DaysOut = 2 THEN 'Two Day'
--	   WHEN DaysOut = 3 THEN 'Three Day'
--	   WHEN DaysOut = 4 THEN 'Four Day'
--	   WHEN DaysOut = 5 THEN 'Five Day'
--	   WHEN DaysOut = 6 THEN 'Six Day'
--	   WHEN DaysOut BETWEEN 7 AND 13 THEN 'One Week'
--	   WHEN DaysOut BETWEEN 14 AND 20 THEN 'Two Weeks'
--	   WHEN DaysOut BETWEEN 21 AND 27 THEN 'Three Weeks'
--	   WHEN DaysOut BETWEEN 28 AND 34 THEN 'One Week'
--FROM #Output
--GROUP BY DaysOut

/*BWH Addition starts here*/



        SELECT  SUM(Amt) Amt
              , SUM(Qty) Qty
              , DaysOutLabel
              , DaysOutClass
              , LabelSort
        FROM    #Output o
                JOIN #DaysOutHelper l ON o.DaysOut BETWEEN l.DaysOutStart AND l.DaysOutEnd
        GROUP BY DaysOutLabel
              , DaysOutClass
              , LabelSort

/*
SELECT 50 Qty, 3000 Amt, 'Same Day' DaysOutLabel, '' AS DaysOutClass
UNION all
SELECT 2000 Qty, 10000 Amt, '' DaysOutLabel, 'BuyingTrendSubtotal' AS DaysOutClass
*/

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - BuyingTrendExit' 

    END




GO
