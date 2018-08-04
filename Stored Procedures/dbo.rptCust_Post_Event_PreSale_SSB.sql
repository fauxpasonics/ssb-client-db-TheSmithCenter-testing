SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC [dbo].[rptCust_Post_Event_PreSale_SSB]  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
	@SaleStart = '2016-01-15'

*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_PreSale_SSB]
    @TYPE AS VARCHAR(2)
  , @GROUPING AS VARCHAR(500)
  , @Season AS VARCHAR(15)
  , @SaleStart AS DATETIME
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - PreSaleEnter'

--DECLARE @TYPE AS VARCHAR(2) = 'EV'
--DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
--DECLARE @Season AS VARCHAR(15) = 'TSC1415'
--DECLARE @SaleStart AS DATETIME = '20140303'



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

        SELECT  CASE WHEN trans.DATE < @SaleStart THEN 'Presale'
                     WHEN trans.DATE = @SaleStart THEN 'Sale Start Date'
                     WHEN DATEDIFF(d, trans.DATE, event.DATE) > 90
                     THEN 'Sale Date - 90 Days'
                     WHEN DATEDIFF(d, trans.DATE, event.DATE) BETWEEN 61 AND 90
                     THEN '90-60 Days'
                     WHEN DATEDIFF(d, trans.DATE, event.DATE) BETWEEN 31 AND 60
                     THEN '60-30 Days'
                     WHEN DATEDIFF(d, trans.DATE, event.DATE) BETWEEN 7 AND 30
                     THEN '30-6 Days'
                     WHEN DATEDIFF(d, trans.DATE, event.DATE) BETWEEN 6 AND 0
                     THEN '6-0 Days'
                END AS DateGroup
--,trans.DATE as TransDate
--, event.Event
--, event.Date as EventDate
              , SUM(trans.E_OQTY_TOT) AS Qty
              , SUM(trans.E_OQTY_TOT * trans.E_PRICE) AS Value
        INTO    #temp
        FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) ON ( trans.SEASON = event.SEASON
                    AND trans.EVENT = event.EVENT
                    )
                INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                    AND prtype.PRTYPE = trans.E_PT
                    )
				INNER JOIN #SeasonTemp st
					ON trans.SEASON = st.Item
        WHERE   ISNULL(prtype.KIND, 'GREG') <> 'H'
                AND prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
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
                           AND TAG IN ( SELECT  TAG
                                        FROM    #tagtemp )
                         )
                    )
        GROUP BY CASE WHEN trans.DATE < @SaleStart THEN 'Presale'
                      WHEN trans.DATE = @SaleStart THEN 'Sale Start Date'
                      WHEN DATEDIFF(d, trans.DATE, event.DATE) > 90
                      THEN 'Sale Date - 90 Days'
                      WHEN DATEDIFF(d, trans.DATE, event.DATE) BETWEEN 61 AND 90
                      THEN '90-60 Days'
                      WHEN DATEDIFF(d, trans.DATE, event.DATE) BETWEEN 31 AND 60
                      THEN '60-30 Days'
                      WHEN DATEDIFF(d, trans.DATE, event.DATE) BETWEEN 7 AND 30
                      THEN '30-6 Days'
                      WHEN DATEDIFF(d, trans.DATE, event.DATE) BETWEEN 6 AND 0
                      THEN '6-0 Days'
                 END 
--trans.DATE, event.Event, event.DATE

        SELECT  DateGroup
              , Qty
              , SUM(Qty) OVER ( ) AS total_qty
              , Value
              , SUM(Value) OVER ( ) AS total_value
        INTO    #output
        FROM    #temp
        WHERE   DateGroup IS NOT NULL	

        SELECT  DateGroup
              , Qty
              , total_qty
              , CASE WHEN total_qty = 0 THEN 0
                     ELSE 1.0 * Qty / total_qty
                END AS pct_total_qty
              , Value
              , total_value
              , CASE WHEN total_value = 0 THEN 0
                     ELSE 1.0 * Value / total_value
                END AS pct_total_value
 --INTO [dbo].[TEMP_rptCust_Post_Event_PreSale_SSB]
        FROM    #Output

        DROP TABLE #Output
        DROP TABLE #temp



--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_PreSale_SSB]


        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - PreSaleExit'

    END







GO
