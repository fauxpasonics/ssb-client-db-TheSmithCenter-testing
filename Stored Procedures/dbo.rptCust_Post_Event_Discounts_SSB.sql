SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC dbo.rptCust_Post_Event_Discounts_SSB @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_Discounts_SSB]
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
                      , 'PostEvent - DiscountsEnter' 

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

        CREATE TABLE #TSCCUSTLIST
            (
              CUSTOMER VARCHAR(20)
            , PRICETYPE VARCHAR(32)
            )
	
        INSERT  INTO #TSCCUSTLIST
                ( CUSTOMER
                , PRICETYPE
	            )
                SELECT DISTINCT
                        trans.CUSTOMER
                      , trans.E_PT
                FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                INNER JOIN dbo.TK_EVENT tkEvent WITH ( NOLOCK ) ON ( trans.SEASON = tkEvent.SEASON
                    AND trans.EVENT = tkEvent.EVENT
                    )
				INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                    AND prtype.PRTYPE = trans.E_PT
                    )
				INNER JOIN #SeasonTemp st
					ON trans.SEASON = st.Item
                WHERE    prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
                        AND ( ( @TYPE = 'EG'
                                AND tkEvent.EGROUP IN (
                                SELECT  Item
                                FROM    [dbo].[SplitSSB](@GROUPING, ',') )
                              )
                              OR ( @TYPE = 'EY'
                                   AND tkEvent.ETYPE IN (
                                   SELECT   Item
                                   FROM     [dbo].[SplitSSB](@GROUPING, ',') )
                                 )
                              OR ( @TYPE = 'EV'
                                   AND tkEvent.EVENT IN (
                                   SELECT   Item
                                   FROM     [dbo].[SplitSSB](@GROUPING, ',') )
                                 )
                              OR ( @TYPE = 'EC'
                                   AND tkEvent.CLASS IN (
                                   SELECT   Item
                                   FROM     [dbo].[SplitSSB](@GROUPING, ',') )
                                 )
                              OR ( @TYPE = 'ET'
                                   AND tkEvent.TAG IN ( SELECT
                                                              TAG
                                                        FROM  #tagtemp )
                                 )
                            )
                GROUP BY trans.CUSTOMER
                      , trans.E_PT
                HAVING  SUM(trans.E_OQTY_TOT) > 0

---------------------------------------------------------------------

        SELECT  CASE WHEN tkClass.CLASS = 'CMP' THEN 'Comp'
                     WHEN tkClass.CLASS = 'SUB' THEN 'Subscribers'
                     WHEN tkClass.CLASS = 'GRP' THEN 'Groups'
                     WHEN tkClass.CLASS = 'REG'
                          AND E_PT = 'P' THEN 'Full'
                     WHEN tkClass.CLASS = 'REG'
                          AND E_PT <> 'P' THEN 'Discounted'
                END AS Category
              , SUM(trans.E_OQTY_TOT) AS Qty
              , ( SELECT    COUNT(DISTINCT cust.CUSTOMER)
                  FROM      #TSCCUSTLIST cust
                  WHERE     trans.E_PT = cust.PRICETYPE COLLATE SQL_Latin1_General_CP1_CI_AS
                ) AS HH
              , SUM(trans.E_OQTY_TOT * trans.E_PRICE) AS Value
        INTO    #output
        FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
        INNER JOIN dbo.TK_EVENT tkEvent WITH ( NOLOCK ) ON ( trans.SEASON = tkEvent.SEASON
                                                        AND trans.EVENT = tkEvent.EVENT
                                                        )
        INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                                                        AND prtype.PRTYPE = trans.E_PT
                                                        )
        INNER JOIN dbo.TK_CLASS tkClass WITH ( NOLOCK ) ON ( tkClass.CLASS = prtype.CLASS )
		INNER JOIN #SeasonTemp st
			ON trans.SEASON = st.Item
        WHERE   prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
                AND ISNULL(prtype.KIND, 'GREG') <> 'H'
                AND ( ( @TYPE = 'EG'
                        AND tkEvent.EGROUP IN (
                        SELECT  Item
                        FROM    [dbo].[SplitSSB](@GROUPING, ',') )
                      )
                      OR ( @TYPE = 'EY'
                           AND tkEvent.ETYPE IN (
                           SELECT   Item
                           FROM     [dbo].[SplitSSB](@GROUPING, ',') )
                         )
                      OR ( @TYPE = 'EV'
                           AND tkEvent.EVENT IN (
                           SELECT   Item
                           FROM     [dbo].[SplitSSB](@GROUPING, ',') )
                         )
                      OR ( @TYPE = 'EC'
                           AND tkEvent.CLASS IN (
                           SELECT   Item
                           FROM     [dbo].[SplitSSB](@GROUPING, ',') )
                         )
                      OR ( @TYPE = 'ET'
                           AND tkEvent.TAG IN ( SELECT  TAG
                                                FROM    #tagtemp )
                         )
                    )
        GROUP BY CASE WHEN tkClass.CLASS = 'CMP' THEN 'Comp'
                      WHEN tkClass.CLASS = 'SUB' THEN 'Subscribers'
                      WHEN tkClass.CLASS = 'GRP' THEN 'Groups'
                      WHEN tkClass.CLASS = 'REG'
                           AND E_PT = 'P' THEN 'Full'
                      WHEN tkClass.CLASS = 'REG'
                           AND E_PT <> 'P' THEN 'Discounted'
                 END
              , trans.E_PT
        HAVING  SUM(trans.E_OQTY_TOT) > 0
        ORDER BY SUM(trans.E_OQTY_TOT) DESC


        SELECT  * 
	--	INTO [dbo].[TEMP_rptCust_Post_Event_Discounts_SSB]
        FROM    ( SELECT    Category
                          , SUM(Qty) qty
                          , SUM(HH) HH
                          , SUM(Value) Value
                  FROM      #Output
                  GROUP BY  Category
                  UNION ALL
                  SELECT    'TOTAL'
                          , SUM(Qty)
                          , SUM(HH)
                          , SUM(Value)
                  FROM      #Output
                ) x


        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - DiscountExit' 

    END







GO
