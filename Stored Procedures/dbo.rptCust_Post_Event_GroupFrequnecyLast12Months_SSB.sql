SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC dbo.rptCust_Post_Event_GroupFrequnecyLast12Months_SSB @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_GroupFrequnecyLast12Months_SSB]
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
                      , 'PostEvent - GroupFrequencyLast12MonthsEnter'

--DECLARE @TYPE AS VARCHAR(2) = 'EV'
--DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
--DECLARE @Season AS VARCHAR(15) = 'TSC1415'



        SELECT  Item
        INTO    #GroupingTemp
        FROM    [dbo].[SplitSSB](@GROUPING, ',')

        SELECT  Item
        INTO    #SeasonTemp
        FROM    [dbo].[SplitSSB](@Season, ',')

        SELECT DISTINCT
                TAG
        INTO    #tagtemp
        FROM    dbo.SplitSSB(@GROUPING, ',') s
                JOIN TK_EVENT ON PATINDEX('% ' + s.Item + ' %',
                                          ' ' + TAG COLLATE SQL_Latin1_General_CP1_CI_AS
                                          + ' ') > 0 

        DECLARE @FIRSTEVENTDATE AS DATETIME

        SET @FIRSTEVENTDATE = ( SELECT  MIN(event.DATE)
                                FROM    dbo.TK_EVENT event WITH ( NOLOCK )
                                WHERE   event.SEASON IN ( SELECT
                                                              Item
                                                          FROM
                                                              #SeasonTemp )
                                        AND ( ( @TYPE = 'EG'
                                                AND event.EGROUP IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                              )
                                              OR ( @TYPE = 'EY'
                                                   AND event.ETYPE IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                                 )
                                              OR ( @TYPE = 'EV'
                                                   AND event.EVENT IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                                 )
                                              OR ( @TYPE = 'ET'
                                                   AND TAG IN ( SELECT
                                                              TAG
                                                              FROM
                                                              #tagtemp )
                                                 )
                                            )
                              )
        SET @FIRSTEVENTDATE = DATEADD("m", -12, @FIRSTEVENTDATE)


        CREATE TABLE #tscEvents
            (
              SEASON VARCHAR(15)
            , EVENT VARCHAR(32)
            )
	
        INSERT  INTO #tscEvents
                ( SEASON
                , EVENT
	            )
                SELECT  SEASON
                      , EVENT
                FROM    dbo.TK_EVENT WITH ( NOLOCK )
                WHERE   SEASON IN ( SELECT  Item
                                    FROM    #SeasonTemp )
                        AND ( ( @TYPE = 'EG'
                                AND EGROUP IN ( SELECT  Item
                                                FROM    #GroupingTemp )
                              )
                              OR ( @TYPE = 'EY'
                                   AND ETYPE IN ( SELECT    Item
                                                  FROM      #GroupingTemp )
                                 )
                              OR ( @TYPE = 'EC'
                                   AND CLASS IN ( SELECT    Item
                                                  FROM      #GroupingTemp )
                                 )
                              OR ( @TYPE = 'EV'
                                   AND EVENT IN ( SELECT    Item
                                                  FROM      #GroupingTemp )
                                 )
                              OR ( @TYPE = 'ET'
                                   AND TAG IN ( SELECT  TAG
                                                FROM    #tagtemp )
                                 )
                            )

------------------------------------------------------------------------------------------------

        CREATE TABLE #orderedHH
            (
              customer VARCHAR(20)
            , frequency BIGINT
            , firstDate DATETIME
            , quantity BIGINT
            )

        INSERT  INTO #orderedHH
                ( customer
                , frequency
                , firstDate
                , quantity
                )
                SELECT  tkTransEvent.CUSTOMER
                      , '1'
                      , MIN(tkEvent.DATE) AS firstDate
                      , SUM(tkTransEvent.E_OQTY_TOT) AS quantity
                FROM    dbo.TK_TRANS_ITEM_EVENT tkTransEvent WITH ( NOLOCK )
                        INNER JOIN dbo.TK_EVENT tkEvent WITH ( NOLOCK ) ON ( tkTransEvent.SEASON = tkEvent.SEASON
                                                              AND tkTransEvent.EVENT = tkEvent.EVENT
                                                              )
                        INNER JOIN TK_PRTYPE tkPrtype WITH ( NOLOCK ) ON ( tkPrtype.SEASON = tkTransEvent.SEASON
                                                              AND tkPrtype.PRTYPE = tkTransEvent.E_PT
                                                              )
                WHERE   tkTransEvent.SEASON IN ( SELECT Item
                                                 FROM   #SeasonTemp )
                        AND tkTransEvent.SALECODE <> 'SH'
                        AND tkPrtype.CLASS = 'GRP'
                        AND ( ( @TYPE = 'EG'
                                AND tkEvent.EGROUP IN ( SELECT
                                                              Item
                                                        FROM  #GroupingTemp )
                              )
                              OR ( @TYPE = 'EY'
                                   AND tkEvent.ETYPE IN ( SELECT
                                                              Item
                                                          FROM
                                                              #GroupingTemp )
                                 )
                              OR ( @TYPE = 'EV'
                                   AND tkEvent.EVENT IN ( SELECT
                                                              Item
                                                          FROM
                                                              #GroupingTemp )
                                 )
                              OR ( @TYPE = 'ET'
                                   AND TAG IN ( SELECT  TAG
                                                FROM    #tagtemp )
                                 )
                            )
                GROUP BY tkTransEvent.CUSTOMER
                HAVING  SUM(tkTransEvent.E_OQTY_TOT) > 0

-------------------------------------------------------------------

        CREATE TABLE #pastpurch
            (
              customer VARCHAR(20)
            , season VARCHAR(32)
            , event VARCHAR(32)
            , eventdate DATE
            )
	
        INSERT  INTO #pastpurch
                ( customer
                , season
                , event
                , eventdate
	            )
                SELECT  tkTransEvent.CUSTOMER
                      , tkTransEvent.SEASON
                      , tkTransEvent.EVENT
                      , tkEvent.DATE
                FROM    dbo.TK_TRANS_ITEM_EVENT tkTransEvent WITH ( NOLOCK )
                        INNER JOIN dbo.TK_EVENT tkEvent WITH ( NOLOCK ) ON ( tkTransEvent.SEASON = tkEvent.SEASON
                                                              AND tkTransEvent.EVENT = tkEvent.EVENT
                                                              )
                        INNER JOIN #orderedHH oHH ON ( tkTransEvent.CUSTOMER = oHH.customer )
                        INNER JOIN TK_PRTYPE tkPrtype WITH ( NOLOCK ) ON ( tkPrtype.SEASON = tkTransEvent.SEASON
                                                              AND tkPrtype.PRTYPE = tkTransEvent.E_PT
                                                              )
                WHERE   tkTransEvent.SALECODE <> 'SH'
                        AND tkPrtype.CLASS = 'GRP'
                        AND tkEvent.DATE >= @FIRSTEVENTDATE
                GROUP BY tkTransEvent.CUSTOMER
                      , tkTransEvent.SEASON
                      , tkTransEvent.EVENT
                      , tkEvent.DATE
                HAVING  SUM(tkTransEvent.E_OQTY_TOT) > 0

-------------------------------------------------------------------

        CREATE TABLE #purchases
            (
              customer VARCHAR(20)
            , frequency BIGINT
            , tickets BIGINT
            )

        INSERT  INTO #purchases
                ( customer
                , frequency
                , tickets
                )
                SELECT  purch.customer
                      , COUNT(DISTINCT ( purch.season + purch.event )) AS frequency
                      , oHH.quantity
                FROM    #pastpurch purch
                        INNER JOIN #orderedHH oHH ON ( oHH.customer = purch.customer )
                        LEFT JOIN #tscEvents tscEvent ON ( tscEvent.SEASON COLLATE SQL_Latin1_General_CP1_CS_AS = purch.season
                                                           AND tscEvent.EVENT COLLATE SQL_Latin1_General_CP1_CS_AS = purch.event
                                                         )
                WHERE   purch.eventdate <= oHH.firstDate
                        AND ISNULL(tscEvent.EVENT, 'FAKEEVENT123') = 'FAKEEVENT123'
                GROUP BY purch.customer
                      , oHH.quantity

--------------------------------------------------------------------------------------------

        CREATE TABLE #tscCombined
            (
              CUSTOMER VARCHAR(20)
            , FREQUENCY BIGINT
            , TICKETS BIGINT
            )

        INSERT  INTO #tscCombined
                ( CUSTOMER
                , FREQUENCY
                , TICKETS
	            )
                SELECT  ordered.customer
                      , ( ordered.frequency + ISNULL(otherPurch.frequency, '0') )
                      , ordered.quantity
                FROM    #orderedHH ordered
                        LEFT OUTER JOIN #purchases otherPurch ON ( ordered.customer = otherPurch.customer )

-------------------------------------------------------------------------

        SELECT  t.FREQUENCY AS FREQUENCY
              , CASE WHEN t.FREQUENCY = 1 THEN '1st Time'
                     WHEN t.FREQUENCY = 2 THEN '2nd Time'
                     WHEN t.FREQUENCY = 3 THEN '3rd Time'
                     WHEN t.FREQUENCY = 4 THEN '4th Time'
                     WHEN t.FREQUENCY = 5 THEN '5th Time'
                     WHEN t.FREQUENCY = 6 THEN '6th Time'
                     WHEN t.FREQUENCY = 7 THEN '7th Time'
                     WHEN t.FREQUENCY = 8 THEN '8th Time'
                     WHEN t.FREQUENCY = 9 THEN '9th Time'
                     WHEN t.FREQUENCY > 9 THEN '10th+ Time'
                END AS FrequnecyGrouping
              , CASE WHEN t.FREQUENCY = 1 THEN 1
                     WHEN t.FREQUENCY = 2 THEN 2
                     WHEN t.FREQUENCY = 3 THEN 3
                     WHEN t.FREQUENCY = 4 THEN 4
                     WHEN t.FREQUENCY = 5 THEN 5
                     WHEN t.FREQUENCY = 6 THEN 6
                     WHEN t.FREQUENCY = 7 THEN 7
                     WHEN t.FREQUENCY = 8 THEN 8
                     WHEN t.FREQUENCY = 9 THEN 9
                     WHEN t.FREQUENCY > 9 THEN 99
                END AS FrequnecyGroupingSort
              , COUNT(t.CUSTOMER) AS HH
              , SUM(t.TICKETS) AS Tickets
              , ROUND(CAST(COUNT(t.CUSTOMER) * 100 AS DECIMAL) / ( SELECT
                                                              COUNT(customer)
                                                              FROM
                                                              #orderedHH
                                                              ), 2) AS HH_Percent
        INTO    #Output
        FROM    #tscCombined t
        GROUP BY t.FREQUENCY
        ORDER BY t.FREQUENCY ASC

        SELECT  x.FrequnecyGrouping
              , x.FrequnecyGroupingSort
              , x.HH
              , x.Tickets
              , CAST(x.HH AS NUMERIC(18, 2))
                / CAST(SUM(x.HH) OVER ( ) AS NUMERIC(18, 2)) AS Pct_HH
	--	INTO [dbo].[TEMP_rptCust_Post_Event_GroupFrequnecyLast12Months_SSB]
        FROM    ( SELECT    FrequnecyGrouping
                          , FrequnecyGroupingSort
                          , SUM(HH) HH
                          , SUM(Tickets) Tickets
                  FROM      #Output
                  GROUP BY  FrequnecyGrouping
                          , FrequnecyGroupingSort
                ) x


        DROP TABLE #orderedHH
        DROP TABLE #purchases
        DROP TABLE #tscEvents
        DROP TABLE #tscCombined
        DROP TABLE #pastpurch
        DROP TABLE #Output


        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - GroupFrequencyLast12MonthsExit'

    END




GO
