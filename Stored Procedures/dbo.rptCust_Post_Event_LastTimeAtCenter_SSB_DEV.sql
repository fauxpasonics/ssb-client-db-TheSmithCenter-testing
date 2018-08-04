SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC dbo.rptCust_Post_Event_LastTimeAtCenter_SSB_DEV  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_LastTimeAtCenter_SSB_DEV]
    @TYPE AS VARCHAR(2)
  , @GROUPING AS VARCHAR(500)
  , @Season AS VARCHAR(15)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON


--DECLARE @TYPE AS VARCHAR(2) = 'ET'
--DECLARE @GROUPING AS VARCHAR(500) = 'BWAY'
--DECLARE @Season AS VARCHAR(15) = 'TSC1415'
        
		DECLARE @FIRSTDATE AS DATETIME

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - LastTimeAtCenterEnter'

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
		
		SET @FIRSTDATE = ( SELECT   MIN(ev.DATE)
                           FROM     dbo.TK_EVENT ev WITH ( NOLOCK )
                           WHERE    ev.SEASON IN ( SELECT   Item
                                                   FROM     #SeasonTemp )
                                    AND ( ( @TYPE = 'EG'
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
                         )


        CREATE TABLE #orderedHH
            (
              customer VARCHAR(20)
            --, eDate DATETIME
            )

        INSERT  INTO #orderedHH
                ( customer
                --, eDate
                )
                SELECT  trans.CUSTOMER AS customer
                      --, MAX(e.DATE) AS eDate
                FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                        --INNER JOIN dbo.TK_CUSTOMER c WITH ( NOLOCK ) ON trans.CUSTOMER = c.CUSTOMER
                        INNER JOIN dbo.TK_EVENT e WITH ( NOLOCK ) ON trans.SEASON = e.SEASON
                                                              AND trans.EVENT = e.EVENT
                        INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                                                              AND prtype.PRTYPE = trans.E_PT
                                                              )
                WHERE   ISNULL(prtype.KIND, 'GREG') <> 'H'
                        AND trans.SALECODE <> 'SH'
                        AND trans.SEASON IN ( SELECT    Item
                                              FROM      #SeasonTemp )
                        AND ( ( @TYPE = 'EG'
                                AND e.EGROUP IN ( SELECT    Item
                                                  FROM      #GroupingTemp )
                              )
                              OR ( @TYPE = 'EY'
                                   AND e.ETYPE IN ( SELECT  Item
                                                    FROM    #GroupingTemp )
                                 )
                              OR ( @TYPE = 'EV'
                                   AND e.EVENT IN ( SELECT  Item
                                                    FROM    #GroupingTemp )
                                 )
                              OR ( @TYPE = 'EC'
                                   AND e.CLASS IN ( SELECT  Item
                                                    FROM    #GroupingTemp )
                                 )
                              OR ( @TYPE = 'ET'
                                   AND TAG IN ( SELECT  TAG
                                                FROM    #tagtemp )
                                 )
                            )
                GROUP BY trans.CUSTOMER

-------------------------------------------------------------------

        CREATE TABLE #lastPurchase
            (
              customer VARCHAR(20)
            , lastDate DATETIME
            )

        INSERT  INTO #lastPurchase
                ( customer
                , lastDate
                )
                SELECT  trans.CUSTOMER AS customer
                      , MAX(tkEvent.DATE) AS lastDate
                FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                        INNER JOIN TK_EVENT tkEvent WITH ( NOLOCK ) ON trans.SEASON = tkEvent.SEASON
                                                              AND trans.EVENT = tkEvent.EVENT
                        INNER JOIN #orderedHH oHH ON trans.CUSTOMER = oHH.customer
                WHERE   tkEvent.DATE < @FirstDate
                        AND trans.SALECODE <> 'SH'
                        AND ( NOT ( trans.SEASON IN ( SELECT  Item
                                                      FROM    #SeasonTemp )
                                    AND @TYPE = 'EG'
                                    AND tkEvent.EGROUP IN ( SELECT
                                                              Item
                                                            FROM
                                                              #GroupingTemp )
                                  )
                              AND NOT ( trans.SEASON IN ( SELECT
                                                              Item
                                                          FROM
                                                              #SeasonTemp )
                                        AND @TYPE = 'EV'
                                        AND tkEvent.EVENT IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                      )
                              AND NOT ( trans.SEASON IN ( SELECT
                                                              Item
                                                          FROM
                                                              #SeasonTemp )
                                        AND @TYPE = 'EY'
                                        AND tkEvent.ETYPE IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                      )
                              AND NOT ( trans.SEASON IN ( SELECT
                                                              Item
                                                          FROM
                                                              #SeasonTemp )
                                        AND @TYPE = 'EC'
                                        AND tkEvent.CLASS IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                      )
                              AND NOT ( trans.SEASON IN ( SELECT
                                                              Item
                                                          FROM
                                                              #SeasonTemp )
                                        AND @TYPE = 'ET'
                                        AND TAG IN ( SELECT TAG
                                                     FROM   #tagtemp )
                                      )
                            )
                GROUP BY trans.CUSTOMER

-------------------------------------------------------------------

        SELECT  A.LastTime
              , LastTimeSort
              , COUNT(A.cust) AS HH
              , ROUND(CAST(COUNT(A.cust) * 100 AS DECIMAL) / ( SELECT
                                                              COUNT(customer)
                                                              FROM
                                                              #orderedHH
                                                             ), 2) AS HH_Percent
--INTO [dbo].[TEMP_rptCust_Post_Event_LastTimeAtCenter_SSB]
        FROM    ( SELECT    CASE WHEN l.lastDate >= DATEADD(DAY, -30,
                                                            @FirstDate)
                                 THEN 'Last 30 Days'
                                 WHEN l.lastDate >= DATEADD(DAY, -60,
                                                            @FirstDate)
                                      AND l.lastDate < DATEADD(DAY, -30,
                                                              @FirstDate)
                                 THEN 'Last 60 Days'
                                 WHEN l.lastDate >= DATEADD(DAY, -90,
                                                            @FirstDate)
                                      AND l.lastDate < DATEADD(DAY, -60,
                                                              @FirstDate)
                                 THEN 'Last 90 Days'
                                 WHEN l.lastDate >= DATEADD(DAY, -120,
                                                            @FirstDate)
                                      AND l.lastDate < DATEADD(DAY, -90,
                                                              @FirstDate)
                                 THEN 'Last 120 Days'
                                 WHEN l.lastDate >= DATEADD(MONTH, -6,
                                                            @FirstDate)
                                      AND l.lastDate < DATEADD(DAY, -120,
                                                              @FirstDate)
                                 THEN 'Last 6 Months'
                                 ELSE 'More than 6 months ago'
                            END AS LastTime
                          , CASE WHEN l.lastDate >= DATEADD(DAY, -30,
                                                            @FirstDate) THEN 1
                                 WHEN l.lastDate >= DATEADD(DAY, -60,
                                                            @FirstDate)
                                      AND l.lastDate < DATEADD(DAY, -30,
                                                              @FirstDate)
                                 THEN 2
                                 WHEN l.lastDate >= DATEADD(DAY, -90,
                                                            @FirstDate)
                                      AND l.lastDate < DATEADD(DAY, -60,
                                                              @FirstDate)
                                 THEN 3
                                 WHEN l.lastDate >= DATEADD(DAY, -120,
                                                            @FirstDate)
                                      AND l.lastDate < DATEADD(DAY, -90,
                                                              @FirstDate)
                                 THEN 4
                                 WHEN l.lastDate >= DATEADD(MONTH, -6,
                                                            @FirstDate)
                                      AND l.lastDate < DATEADD(DAY, -120,
                                                              @FirstDate)
                                 THEN 5
                                 ELSE 6
                            END AS LastTimeSort
                          , l.customer AS cust
                  FROM      #orderedHH oHH
                            LEFT OUTER JOIN #lastPurchase l ON oHH.customer = l.customer
                ) A
        GROUP BY LastTime
              , A.LastTimeSort
        ORDER BY A.LastTimeSort

        DROP TABLE #orderedHH
        DROP TABLE #lastPurchase

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - LastTimeAtCenterExit'

--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_LastTimeAtCenter_SSB]


    END



GO
