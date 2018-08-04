SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/*
EXEC [dbo].[rptCust_Days_Out_Event_SSB_Detail] @Season = 'TSC1516', -- varchar(25)
    @Type = 'EV', -- varchar(2)
    @Grouping = 'C0127L', -- varchar(25)
	@Venue = 'CJ' --varchar(25)
*/

--EXEC [dbo].[rptCust_Days_Out_Event_SSB_Detail] 'TSC1516','ET','BWAY','BWAY'
CREATE PROCEDURE [dbo].[rptCust_Days_Out_Event_SSB_Detail]
    @Season VARCHAR(500)
  , @Type VARCHAR(25)
  , @Grouping VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON



        SELECT DISTINCT
                TAG
        INTO    #tagtemp
        FROM    dbo.SplitSSB(@Grouping, ',') s
                JOIN TK_EVENT ON PATINDEX('% ' + s.Item + ' %',
                                          ' ' + TAG COLLATE SQL_Latin1_General_CP1_CI_AS
                                          + ' ') > 0 


        DECLARE @MINDATE DATETIME
          , @MAXDATE DATETIME
          , @DATEDIFF INTEGER
          , @OFFSET INTEGER
          , @MAXDAYSOUT INTEGER
          , @MINEVENTDATE DATETIME


		  

        SELECT  @MINDATE = MIN(trans.DATE)
              , @MAXDATE = MAX(ev.DATE)
              , @MAXDAYSOUT = MAX(DATEDIFF(d, trans.DATE, ev.DATE))
              , @MINEVENTDATE = MIN(ev.DATE)
        FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                INNER JOIN dbo.TK_EVENT ev WITH ( NOLOCK ) ON ( trans.SEASON = ev.SEASON
                                                              AND trans.EVENT = ev.EVENT
                                                              )
        WHERE   ( ( @Type = 'EG'
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
                AND trans.SEASON IN ( SELECT    Item
                                      FROM      [dbo].[SplitSSB](@Season, ',') )
                AND ev.FACILITY IN ( SELECT Item
                                     FROM   [dbo].[SplitSSB](@Venue, ',') )
        HAVING  SUM(trans.E_OQTY_TOT) <> 0

        			   
        SET @DATEDIFF = DATEDIFF(DAY, @MINDATE, @MAXDATE)
        SET @OFFSET = 1
        

        CREATE TABLE #DATES ( alldays INTEGER )

        WHILE ( @MINDATE < @MAXDATE + 14 )
            BEGIN
                INSERT  INTO #DATES
                        ( alldays )
                VALUES  ( DATEDIFF(d, @MINDATE, @MAXDATE) )
                SELECT  @MINDATE = DATEADD(DAY, 1, @MINDATE)
            END

		
	    
        SELECT  E_PRICE AS Value_On_Date
              , E_QTY AS Sold_On_Date
              , dates.alldays AS Days_Out
        INTO    #RunningTotal
        FROM    #DATES dates
                LEFT JOIN ( SELECT  SUM(trans.E_OQTY_TOT * trans.E_PRICE) AS E_PRICE
                                  , SUM(trans.E_OQTY_TOT) AS E_QTY
                                  , DATEDIFF(d, trans.DATE, event.DATE) AS DAYS_OUT
                            FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                                    INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) ON ( event.SEASON = trans.SEASON
                                                              AND trans.EVENT = event.EVENT
                                                              )
                                    INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                                                              AND prtype.PRTYPE = trans.E_PT
                                                              )
                                    INNER JOIN dbo.TK_SEASON season WITH ( NOLOCK ) ON ( season.SEASON = trans.SEASON )
                            WHERE   prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
                                    AND ( ( @Type = 'EG'
                                            AND event.EGROUP IN (
                                            SELECT  Item
                                            FROM    [dbo].[SplitSSB](@Grouping,
                                                              ',') )
                                          )
                                          OR ( @Type = 'EV'
                                               AND event.EVENT IN (
                                               SELECT   Item
                                               FROM     [dbo].[SplitSSB](@Grouping,
                                                              ',') )
                                             )
                                          OR ( @Type = 'ET'
                                               AND event.TAG IN ( SELECT
                                                              TAG
                                                              FROM
                                                              #tagtemp )
                                             )
                                        )
                                    AND trans.SEASON IN (
                                    SELECT  Item COLLATE SQL_Latin1_General_CP1_CI_AS
                                    FROM    [dbo].[SplitSSB](@Season, ',') )
                                    AND event.FACILITY IN (
                                    SELECT  Item
                                    FROM    [dbo].[SplitSSB](@Venue, ',') )
                                    AND ISNULL(prtype.KIND, 'GREG') NOT IN (
                                    'H', 'C' )
                                    AND ISNULL(prtype.CLASS, 'GREG') <> 'CNS'
                            GROUP BY DATEDIFF(d, trans.DATE, event.DATE)
                          ) sales ON dates.alldays = sales.DAYS_OUT
        WHERE   dates.alldays <= @MAXDAYSOUT
                AND ( sales.E_QTY <> 0
                      OR sales.E_PRICE <> 0
                    )
				--10924074.60

				
        SELECT  a.Days_Out
              , CAST(CONVERT(DATETIME, CONVERT(INT, @MINEVENTDATE)
                - a.Days_Out) AS DATE) AS Trans_Date
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
        DROP TABLE #tagtemp

    END




GO
