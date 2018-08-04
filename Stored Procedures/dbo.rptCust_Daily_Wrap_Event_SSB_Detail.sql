SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








/*
EXEC [dbo].[rptCust_Daily_Wrap_Event_SSB_Detail] @Season = 'TSC1314', -- varchar(25)
    @Type = 'EG', -- varchar(2) --ReportType
    @Grouping = 'BOM', -- varchar(25) --Event
	@Venue = 'BWAY' --varchar(25)
*/


CREATE PROCEDURE [dbo].[rptCust_Daily_Wrap_Event_SSB_Detail]
    @Season VARCHAR(500)
  , @Type VARCHAR(25)
  , @Grouping VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

       
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

		--DECLARE @Season VARCHAR(500) = 'TSC1314'
		--DECLARE @Type VARCHAR(25) = 'EG'
		--DECLARE @Grouping VARCHAR(500) = 'BOM'
		--DECLARE @Venue VARCHAR(500) = 'BWAY'
		


        SELECT DISTINCT
                TAG
        INTO    #tagtemp
        FROM    dbo.SplitSSB(@Grouping, ',') s
                JOIN TK_EVENT WITH ( NOLOCK ) ON PATINDEX('% ' + s.Item + ' %',
                                                          ' ' + TAG COLLATE SQL_Latin1_General_CP1_CI_AS
                                                          + ' ') > 0 


		--DECLARE @capacity INT = (   SELECT COUNT(*)
		--							FROM dbo.TK_SEAT_SEAT seat
		--								JOIN dbo.TK_EVENT event ON event.SEASON COLLATE SQL_Latin1_General_CP1_CS_AS = seat.season COLLATE SQL_Latin1_General_CP1_CS_AS
		--														   AND event.EVENT  COLLATE SQL_Latin1_General_CP1_CS_AS = seat.EVENT  COLLATE SQL_Latin1_General_CP1_CS_AS
		--								LEFT JOIN dbo.TK_SSTAT stat ON stat.SEASON  COLLATE SQL_Latin1_General_CP1_CS_AS = seat.SEASON  COLLATE SQL_Latin1_General_CP1_CS_AS
		--															   AND stat.SSTAT  COLLATE SQL_Latin1_General_CP1_CS_AS = seat.STAT  COLLATE SQL_Latin1_General_CP1_CS_AS
		--							WHERE ISNULL(stat.name,'') NOT LIKE '%kill%'
		--								  AND stat.SEASON = @Season
		--								  AND event.FACILITY IN ( SELECT  Item
		--														  FROM    [dbo].[SplitSSB](@Venue, ',') )
		--								  AND ((@Type = 'EG'
		--										AND event.EGROUP IN (
		--										SELECT  Item
		--										FROM    [dbo].[SplitSSB](@Grouping, ',') )
		--										)
		--										OR ( @Type = 'EY'
		--											AND event.ETYPE IN (
		--											SELECT   Item
		--											FROM     [dbo].[SplitSSB](@Grouping, ',') )
		--											)
		--										OR ( @Type = 'EV'
		--											AND event.EVENT IN (
		--											SELECT   Item
		--											FROM     [dbo].[SplitSSB](@Grouping, ',') )
		--											)
		--										OR ( @Type = 'EC'
		--											AND event.CLASS IN (
		--											SELECT   Item
		--											FROM     [dbo].[SplitSSB](@Grouping, ',') )
		--											)
		--										OR ( @Type = 'ET'
		--											AND event.TAG IN ( SELECT  TAG
		--																FROM    #tagtemp )
		--											)
		--										)
		--							)
		
        DECLARE @capacity INT = ( SELECT    SUM(event.CAPACITY)
                                  FROM      dbo.TK_EVENT event
                                  WHERE     event.SEASON = @Season
                                            AND event.FACILITY IN (
                                            SELECT  Item
                                            FROM    [dbo].[SplitSSB](@Venue,
                                                              ',') )
                                            AND ( ( @Type = 'EG'
                                                    AND event.EGROUP IN (
                                                    SELECT  Item
                                                    FROM    [dbo].[SplitSSB](@Grouping,
                                                              ',') )
                                                  )
                                                  OR ( @Type = 'EY'
                                                       AND event.ETYPE IN (
                                                       SELECT Item
                                                       FROM   [dbo].[SplitSSB](@Grouping,
                                                              ',') )
                                                     )
                                                  OR ( @Type = 'EV'
                                                       AND event.EVENT IN (
                                                       SELECT Item
                                                       FROM   [dbo].[SplitSSB](@Grouping,
                                                              ',') )
                                                     )
                                                  OR ( @Type = 'EC'
                                                       AND event.CLASS IN (
                                                       SELECT Item
                                                       FROM   [dbo].[SplitSSB](@Grouping,
                                                              ',') )
                                                     )
												--OR ( @Type = 'ET'
												--	AND event.TAG IN ( SELECT  TAG
												--						FROM    #tagtemp )
												--	)
                                                )
                                )

        DECLARE @MINDATE DATETIME
          , @MAXDATE DATETIME
          , @OFFSET INTEGER
          --, @MAXDAYSOUT INTEGER
          , @MINEVENTDATE DATETIME


        SELECT  @MINDATE = MIN(x.DATE)
              , @MAXDATE = MAX(x.DATE)
              --, @MAXDAYSOUT = MAX(DATEDIFF(d, trans.DATE, ev.DATE))
              , @MINEVENTDATE = MIN(x.EventDate)
        FROM    ( SELECT    trans.DATE
                          , ev.DATE EventDate
                  FROM      dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                            INNER JOIN dbo.TK_EVENT ev WITH ( NOLOCK ) ON ( trans.SEASON = ev.SEASON
                                                              AND trans.EVENT = ev.EVENT
                                                              )
                  WHERE     ( ( @Type = 'EG'
                                AND ev.EGROUP IN (
                                SELECT  Item
                                FROM    [dbo].[SplitSSB](@Grouping, ',') )
                              )
                              OR ( @Type = 'EV'
                                   AND ev.EVENT IN (
                                   SELECT   Item
                                   FROM     [dbo].[SplitSSB](@Grouping, ',') )
                                 )
                              OR ( @Type = 'ET'
                                       ---AND ev.TAG IN (SELECT TAG FROM #tagtemp)
                                   )
                            )
                            AND trans.SEASON IN (
                            SELECT  Item
                            FROM    [dbo].[SplitSSB](@Season, ',') )
                            AND ev.FACILITY IN (
                            SELECT  Item
                            FROM    [dbo].[SplitSSB](@Venue, ',') )
                  GROUP BY  trans.DATE
                          , ev.DATE
                  HAVING    SUM(trans.E_OQTY_TOT) <> 0
                ) x

        			   

        SET @OFFSET = 1
        



        CREATE TABLE #DATES ( ALLDATE DATETIME )

        WHILE ( @MINDATE <= @MAXDATE )
            BEGIN
                INSERT  INTO #DATES
                        ( ALLDATE )
                VALUES  ( @MINDATE )
                SELECT  @MINDATE = DATEADD(DAY, 1, @MINDATE)
            END



-----------------------------------------------------------------------------------------

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
                FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                        INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) ON ( event.SEASON = trans.SEASON
                                                              AND trans.EVENT = event.EVENT
                                                              )
                        INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                                                              AND prtype.PRTYPE = trans.E_PT
                                                              )
                        INNER JOIN dbo.TK_SEASON season WITH ( NOLOCK ) ON ( season.SEASON = trans.SEASON )
                WHERE   trans.SEASON IN (
                        SELECT  Item
                        FROM    [dbo].[SplitSSB](@Season, ',') )
                        AND event.FACILITY IN (
                        SELECT  Item
                        FROM    [dbo].[SplitSSB](@Venue, ',') )
                        AND prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
                        AND ( ( @Type = 'EG'
                                AND event.EGROUP IN (
                                SELECT  Item
                                FROM    [dbo].[SplitSSB](@Grouping, ',') )
                              )
                              OR ( @Type = 'EY'
                                   AND event.ETYPE IN (
                                   SELECT   Item
                                   FROM     [dbo].[SplitSSB](@Grouping, ',') )
                                 )
                              OR ( @Type = 'EV'
                                   AND event.EVENT IN (
                                   SELECT   Item
                                   FROM     [dbo].[SplitSSB](@Grouping, ',') )
                                 )
                              OR ( @Type = 'EC'
                                   AND event.CLASS IN (
                                   SELECT   Item
                                   FROM     [dbo].[SplitSSB](@Grouping, ',') )
                                 )
                              OR ( @Type = 'ET'
                                   AND event.TAG IN ( SELECT  TAG
                                                      FROM    #tagtemp )
                                 )
                            )
                        AND ISNULL(prtype.KIND, 'GREG') NOT IN ( 'H', 'C' )
                        AND ISNULL(prtype.CLASS, 'GREG') <> 'CNS'
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
                HAVING  SUM(trans.E_OQTY_TOT) <> 0

        SELECT  dates.ALLDATE AS Trans_Date
              , sales.SEASON AS Trans_Season
              , sales.SEASON_NAME AS Season_Name
              , sales.SEASON_SORT AS Season_SortOrder
              , sales.EVENT AS Trans_Event
              , sales.EVENT_DATE AS Event_Date
              , @MINEVENTDATE AS MinimumEventDate
              , sales.EVENT_NAME AS Event_Name
              , sales.EVENT_TAG AS Event_Tag
              , sales.E_PT AS Trans_EPT
              , sales.E_PT_CLASS AS PT_Class
              , ISNULL(sales.E_PT_KIND, 'F') AS PT_Kind
              , sales.E_PT_SORT AS PT_Sort
              , sales.E_PRICE AS Trans_EPrice
              , ISNULL(sales.E_QTY, 0) AS Trans_Qty
              , 1 AS AllData
        INTO    #output
        FROM    #DATES dates
                LEFT OUTER JOIN #SALES sales ON dates.ALLDATE = sales.DATE
        ORDER BY dates.ALLDATE ASC

        DROP TABLE #DATES
        DROP TABLE #SALES
        DROP TABLE #tagtemp

        SELECT  o.Trans_Date
              , o.SoldOnDate
              , o.ValueOnDate
              , SUM(o_running.SoldOnDate) AS TotalSoldAsOf
              , SUM(o_running.ValueOnDate) AS TotalValueAsOf
              , CASE WHEN @capacity = 0 THEN 0
                     ELSE SUM(o_running.SoldOnDate * 1.0) / @capacity
                END AS QtyPercentOf
              , SUM(o_running.ValueOnDate) / TotalValue AS ValuePercentOf
              , o.MinimumEventDate
              , CASE WHEN o.Trans_Date = o.MinimumEventDate
                     THEN CONVERT(VARCHAR, o.Trans_Date, 101)
                          + ' - First Event'
                     ELSE CONVERT(VARCHAR, o.Trans_Date, 101)
                END AS TextDate
        FROM    ( SELECT    Trans_Date
                          , SUM(Trans_Qty) SoldOnDate
                          , SUM(Trans_Qty * ISNULL(Trans_EPrice, 0)) AS ValueOnDate
                          , MinimumEventDate
                  FROM      #output
                  GROUP BY  Trans_Date
                          , AllData
                          , MinimumEventDate
                ) o
                LEFT JOIN ( SELECT  Trans_Date
                                  , SUM(Trans_Qty) SoldOnDate
                                  , SUM(Trans_Qty * Trans_EPrice) AS ValueOnDate
                            FROM    #output
                            GROUP BY Trans_Date
                          ) o_running ON o_running.Trans_Date <= o.Trans_Date
                CROSS JOIN ( SELECT SUM(Trans_Qty) AS TotalQty
                                  , SUM(Trans_Qty * ISNULL(Trans_EPrice, 0)) TotalValue
                             FROM   #output
                           ) o_total
        GROUP BY o.Trans_Date
              , o.SoldOnDate
              , o.ValueOnDate
              , o_total.TotalQty
              , o_total.TotalValue
              , o.MinimumEventDate
        ORDER BY o.Trans_Date

        DROP TABLE #output
    END



GO
