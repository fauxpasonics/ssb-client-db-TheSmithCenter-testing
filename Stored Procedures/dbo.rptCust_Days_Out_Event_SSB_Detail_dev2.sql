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
CREATE PROCEDURE [dbo].[rptCust_Days_Out_Event_SSB_Detail_dev2]
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



         SELECT   @MINDATE=MIN(trans.DATE), @MAXDAYSOUT =  MAX(DATEDIFF(d, trans.DATE, ev.DATE))
                         FROM   dbo.TK_TRANS_ITEM_EVENT trans
                                INNER JOIN dbo.TK_EVENT ev ON ( trans.SEASON = ev.SEASON
                                                              AND trans.EVENT = ev.EVENT
                                                              )
                         WHERE  ( ( @Type = 'EG'
                                    AND ev.EGROUP IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                  )                                 
                                  OR ( @Type = 'EV'
                                       AND ev.EVENT IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                     )
                                  OR ( @Type = 'ET'
                                       AND ev.TAG IN (SELECT TAG FROM #tagtemp)
                                     )
                                )
								AND trans.SEASON IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
								AND ev.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
                         HAVING SUM(trans.E_OQTY_TOT) <> 0
             
        SET @MAXDATE = ( SELECT MAX(DATE)
                         FROM   dbo.TK_EVENT ev
                         WHERE  ( ( @Type = 'EG'
                                    AND ev.EGROUP IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                  )                              
                                  OR ( @Type = 'EV'
                                       AND ev.EVENT IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                                     )
                                  OR ( @Type = 'ET'
                                       AND ev.TAG IN (SELECT TAG FROM #tagtemp)
                                     )
                                )
								AND ev.SEASON IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
								AND ev.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
                       )
					   
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
			

        SELECT  sales.DATE AS Trans_Date              
              , sales.E_PRICE AS Trans_EPrice
              , ISNULL(sales.E_QTY, 0) AS Trans_Qty
              , dates.alldays AS Days_Out
        INTO    #Output
        FROM    #DATES dates
                LEFT OUTER JOIN (
				SELECT 
                        trans.DATE AS DATE
                      , SUM(trans.E_PRICE * ISNULL(trans.E_OQTY_TOT,0)) AS E_PRICE
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
                          OR ( @Type = 'EV'
                               AND event.EVENT IN (SELECT Item FROM [dbo].[SplitSSB] (@Grouping,','))
                             )                          
                          OR ( @Type = 'ET'
                               AND event.TAG IN (SELECT TAG FROM #tagtemp)
                             )
                        )
						AND trans.SEASON IN (SELECT Item COLLATE SQL_Latin1_General_CP1_CI_AS FROM [dbo].[SplitSSB] (@Season,','))
								AND event.FACILITY IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
                GROUP BY trans.DATE                      
                      , DATEDIFF(d,  trans.DATE,event.DATE)    
				) sales ON dates.alldays = sales.DAYS_OUT        
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
