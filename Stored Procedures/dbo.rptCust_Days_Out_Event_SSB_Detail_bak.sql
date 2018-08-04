SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
EXEC dbo.rptCust_Days_Out_Event_SSB_Detail @Season = 'TSC1516', -- varchar(25)
    @Type = 'EG', -- varchar(2)
    @Grouping = 'BAB', -- varchar(25)
	@Venue = 'BWAY' --varchar(25)
*/

--EXEC [dbo].[rptCust_Days_Out_Event_SSB_Detail] 'TSC1516','ET','BWAY','BWAY'
create PROCEDURE [dbo].[rptCust_Days_Out_Event_SSB_Detail_bak]
    @Season VARCHAR(500)
  , @Type VARCHAR(25)
  , @Grouping VARCHAR(500)
  , @Venue VARCHAR(500)
AS


    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON
/*
select @Season Season, @Type Typess, @Grouping Groupings, @Venue Venue
INTO 

SELECT * FROM dbo.rptTempDelete_SSB
*/

--DECLARE @Season VARCHAR(500) = 'TSC1516'
--DECLARE @Type VARCHAR(25) = 'ET'
--DECLARE @Grouping VARCHAR(500) = 'BWAY'
--DECLARE @Venue VARCHAR(500) = 'BWAY'

SELECT DISTINCT TAG 
INTO #tagtemp
FROM dbo.splitssb(@Grouping,',') s JOIN
tk_event ON
PATINDEX('% ' + s.Item + ' %', ' ' + TAG COLLATE SQL_Latin1_General_CP1_CI_AS + ' ') > 0 

        DECLARE @MINDATE DATETIME
          , @MAXDATE DATETIME
          , @DATEDIFF INTEGER
          , @OFFSET INTEGER
          , @MAXDAYSOUT INTEGER



        SET @MINDATE = ( SELECT MIN(trans.DATE)
                         FROM   dbo.TK_TRANS_ITEM_EVENT trans
                                INNER JOIN dbo.TK_EVENT ev ON ( trans.SEASON = ev.SEASON
                                                              AND trans.EVENT = ev.EVENT
                                                              )
                         WHERE  ( ( @Type = 'EG'
                                    AND ev.EGROUP IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                  )
                                  --OR ( @TYPE = 'EY'
                                  --     AND ev.ETYPE = @GROUPING
                                  --   )
                                  OR ( @Type = 'EV'
                                       AND ev.EVENT IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                     )
                                  --OR ( @TYPE = 'EC'
                                  --     AND ev.CLASS = @GROUPING
                                  --   )
                                  OR ( @Type = 'ET'
                                       AND ev.TAG IN (SELECT TAG FROM #tagtemp)
                                     )
                                )
								AND trans.SEASON IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
								AND ev.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
                         HAVING SUM(trans.E_OQTY_TOT) <> 0
                       )
        SET @MAXDATE = ( SELECT MAX(DATE)
                         FROM   dbo.TK_EVENT ev
                         WHERE  ( ( @Type = 'EG'
                                    AND ev.EGROUP IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                  )
                                  --OR ( @TYPE = 'EY'
                                  --     AND ev.ETYPE = @GROUPING
                                  --   )
                                  OR ( @Type = 'EV'
                                       AND ev.EVENT IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                     )
                                  --OR ( @TYPE = 'EC'
                                  --     AND ev.CLASS = @GROUPING
                                  --   )
                                  OR ( @Type = 'ET'
                                       AND ev.TAG IN (SELECT TAG FROM #tagtemp)
                                     )
                                )
								AND ev.SEASON IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
								AND ev.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
                       )
					   
        SET @DATEDIFF = DATEDIFF(DAY, @MINDATE, @MAXDATE)
        SET @OFFSET = 1
        SET @MAXDAYSOUT = ( SELECT  MAX(DATEDIFF(d, trans.DATE, event.DATE))
                            FROM    dbo.TK_TRANS_ITEM_EVENT trans
                                    INNER JOIN dbo.TK_EVENT event ON ( event.SEASON = trans.SEASON
                                                              AND trans.EVENT = event.EVENT
                                                              )
                            WHERE   ( ( @Type = 'EG'
                                        AND event.EGROUP IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                      )
                                  --OR ( @TYPE = 'EY'
                                  --     AND ev.ETYPE = @GROUPING
                                  --   )
                                      OR ( @Type = 'EV'
                                           AND event.EVENT IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                         )
                                  --OR ( @TYPE = 'EC'
                                  --     AND ev.CLASS = @GROUPING
                                  --   )
                                      OR ( @Type = 'ET'
                                           AND event.TAG IN (SELECT TAG FROM #tagtemp)
                                         )
                                    )
									AND trans.SEASON IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
								AND event.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
                          )

        CREATE TABLE #DATES ( alldays INTEGER )

        WHILE ( @MINDATE < @MAXDATE + 14 )
            BEGIN
                INSERT  INTO #DATES
                        ( alldays )
                VALUES  ( DATEDIFF(d, @MINDATE, @MAXDATE) )
                SELECT  @MINDATE = DATEADD(DAY, 1, @MINDATE)
            END

        CREATE TABLE #SALES
            (
              DATE DATETIME
            , SEASON VARCHAR(15)
            , SEASON_NAME VARCHAR(128)
            , SEASON_SORT INTEGER
            , EVENT VARCHAR(32)
            , EVENT_DATE DATETIME
            , EVENT_NAME VARCHAR(256)
            , EVENT_TAG VARCHAR(MAX)
            , E_PT VARCHAR(32)
            , E_PT_CLASS VARCHAR(32)
            , E_PT_KIND VARCHAR(10)
            , E_PT_SORT INTEGER
            , E_PRICE DECIMAL(18, 2)
            , E_QTY INTEGER
            , DAYS_OUT INTEGER
            )
	
        INSERT  INTO #SALES
                ( DATE
                , SEASON
                , SEASON_NAME
                , SEASON_SORT
                , EVENT
                , EVENT_DATE
                , EVENT_NAME
                , EVENT_TAG
                , E_PT
                , E_PT_CLASS
                , E_PT_KIND
                , E_PT_SORT
                , E_PRICE
                , E_QTY
                , DAYS_OUT
	            )
                SELECT DISTINCT
                        trans.DATE AS DATE
                      , trans.SEASON AS SEASON
                      , season.NAME AS SEASON_NAME
                      , season.SORT_ORDER AS SEASON_SORT
                      , trans.EVENT AS EVENT
                      , event.DATE AS EVENT_DATE
                      , event.NAME AS EVENT_NAME
                      , event.TAG AS EVENT_TAG
                      , trans.E_PT AS E_PT
                      , prtype.CLASS AS E_PT_CLASS
                      , prtype.KIND AS E_PT_KIND
                      , prtype.SORT AS E_PT_SORT
                      , trans.E_PRICE AS E_PRICE
                      , SUM(trans.E_OQTY_TOT) AS E_QTY
                      , DATEDIFF(d, trans.DATE, event.DATE) AS DAYS_OUT
                FROM    dbo.TK_TRANS_ITEM_EVENT trans
                        INNER JOIN dbo.TK_EVENT event ON ( event.SEASON = trans.SEASON
                                                           AND trans.EVENT = event.EVENT
                                                         )
                        INNER JOIN dbo.TK_PRTYPE prtype ON ( prtype.SEASON = trans.SEASON
                                                             AND prtype.PRTYPE = trans.E_PT
                                                           )
                        INNER JOIN dbo.TK_SEASON season ON ( season.SEASON = trans.SEASON )
                WHERE   ( ( @Type = 'EG'
                            AND event.EGROUP IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                          )
                          --OR ( @TYPE = 'EY'
                          --     AND event.ETYPE = @GROUPING
                          --   )
                          OR ( @Type = 'EV'
                               AND event.EVENT IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                             )
                          --OR ( @TYPE = 'EC'
                          --     AND event.CLASS = @GROUPING
                          --   )
                          OR ( @Type = 'ET'
                               AND event.TAG IN (SELECT TAG FROM #tagtemp)
                             )
                        )
						AND trans.SEASON IN (SELECT Item COLLATE SQL_Latin1_General_CP1_CI_AS FROM [dbo].[SplitSSB] (@Season,','))
								AND event.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
                GROUP BY trans.DATE
                      , trans.SEASON
                      , season.NAME
                      , season.SORT_ORDER
                      , trans.EVENT
                      , event.NAME
                      , event.DATE
                      , event.TAG
                      , trans.E_PT
                      , prtype.CLASS
                      , prtype.KIND
                      , prtype.SORT
                      , trans.E_PRICE
                      , DATEDIFF(d, event.DATE, trans.DATE)
                HAVING  SUM(trans.E_OQTY_TOT) <> 0

        SELECT  sales.DATE AS Trans_Date
              , sales.SEASON AS Trans_Season
              , sales.SEASON_NAME AS Season_Name
              , sales.SEASON_SORT AS Season_SortOrder
              , sales.EVENT AS Trans_Event
              , sales.EVENT_DATE AS Event_Date
              , sales.EVENT_NAME AS Event_Name
              , sales.EVENT_TAG AS Event_Tag
              , sales.E_PT AS Trans_EPT
              , sales.E_PT_CLASS AS PT_Class
              , ISNULL(sales.E_PT_KIND, 'F') AS PT_Kind
              , sales.E_PT_SORT AS PT_Sort
              , sales.E_PRICE AS Trans_EPrice
              , ISNULL(sales.E_QTY, 0) AS Trans_Qty
              , dates.alldays AS Days_Out
        INTO    #Output
        FROM    #DATES dates
                LEFT OUTER JOIN #SALES sales ON dates.alldays = sales.DAYS_OUT
        WHERE   dates.alldays <= @MAXDAYSOUT
                AND sales.SEASON COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
        ORDER BY dates.alldays DESC

        SELECT  Days_Out
              , Trans_Date
              , SUM(Trans_Qty) Sold_On_Date
              , SUM(Trans_Qty * Trans_EPrice) Value_On_Date
        INTO    #RunningTotal
        FROM    #Output
        GROUP BY Days_Out
              , Trans_Date

        SELECT  a.Days_Out
              , a.Trans_Date
              , a.Sold_On_Date
              , a.Value_On_Date
              , ( SELECT    SUM(b.Sold_On_Date)
                  FROM      #RunningTotal b
                  WHERE     a.Days_Out <= b.Days_Out
                ) Total_Sold_As_Of_Date
              , ( SELECT    SUM(b.Value_On_Date)
                  FROM      #RunningTotal b
                  WHERE     a.Days_Out <= b.Days_Out
                ) Total_Value_As_Of_Date
        FROM    #RunningTotal a
        ORDER BY a.Days_Out DESC

        DROP TABLE #DATES
        DROP TABLE #SALES
        DROP TABLE #Output
		DROP TABLE #tagtemp

    END




GO
