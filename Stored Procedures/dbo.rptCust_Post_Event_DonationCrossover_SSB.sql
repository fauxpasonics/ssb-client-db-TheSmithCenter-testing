SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rptCust_Post_Event_DonationCrossover_SSB]
    @TYPE AS VARCHAR(2)
  , @GROUPING AS VARCHAR(500)
  , @Season AS VARCHAR(15)
  , @DaysOut AS NUMERIC
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON
				
        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - DonationCrossoverEnter' 

--DECLARE @TYPE AS VARCHAR(2) = 'EV'
--DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
--DECLARE @Season AS VARCHAR(15) = 'TSC1415'
--DECLARE @DaysOut AS NUMERIC = 365


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


        DECLARE @LASTEVENTDATE AS DATE


        SET @LASTEVENTDATE = ( SELECT   MAX(DATE)
                               FROM     dbo.TK_EVENT te WITH ( NOLOCK )
							   INNER JOIN #SeasonTemp st
									ON te.SEASON = st.Item
                               WHERE   ( ( @TYPE = 'EG'
                                                AND EGROUP IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                              )
                                              OR ( @TYPE = 'EY'
                                                   AND ETYPE IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                                 )
                                              OR ( @TYPE = 'EV'
                                                   AND EVENT IN ( SELECT
                                                              Item
                                                              FROM
                                                              #GroupingTemp )
                                                 )
                                              OR ( @TYPE = 'EC'
                                                   AND CLASS IN ( SELECT
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

-----------------------------------------------------------------------------

        SELECT  trans.CUSTOMER, trans.E_OQTY_TOT, trans.E_PRICE
        INTO    #Trans
        FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) ON ( trans.SEASON = event.SEASON
                                                              AND trans.EVENT = event.EVENT
                                                              )
				INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                                                             AND prtype.PRTYPE = trans.E_PT
                                                             )
				INNER JOIN #SeasonTemp st
					ON trans.SEASON = st.Item
        WHERE  prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
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


        CREATE TABLE #TSCDONORSALES
            (
              CUSTOMER VARCHAR(20)
            , QTY BIGINT
            , VALUE DECIMAL(18, 2)
            )

        INSERT  INTO #TSCDONORSALES
                ( CUSTOMER
                , QTY
                , VALUE
	            )
                SELECT DISTINCT
                        trans.CUSTOMER
                      , SUM(trans.E_OQTY_TOT) AS Qty
                      , SUM(trans.E_OQTY_TOT * trans.E_PRICE) AS Value
                FROM    #Trans trans
    --    FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH (NOLOCK)
    --            INNER JOIN dbo.TK_EVENT event WITH (NOLOCK) ON ( trans.SEASON = event.SEASON
    --                                               AND trans.EVENT = event.EVENT
    --                                             )
    --    WHERE   trans.SEASON IN (SELECT Item FROM #SeasonTemp)
				--AND trans.SALECODE <> 'SH'
    --            AND ( ( @TYPE = 'EG'
    --                    AND event.EGROUP IN (SELECT Item FROM #GroupingTemp)
    --                  )
    --                  OR ( @TYPE = 'EY'
    --                       AND event.ETYPE IN (SELECT Item FROM #GroupingTemp)
    --                     )
    --                  OR ( @TYPE = 'EV'
    --                       AND event.EVENT IN (SELECT Item FROM #GroupingTemp)
    --                     )
    --                  OR ( @TYPE = 'EC'
    --                       AND event.CLASS IN (SELECT Item FROM #GroupingTemp)
    --                     )
    --                  OR ( @TYPE = 'ET'
    --                       AND event.TAG IN (SELECT TAG FROM #tagtemp)
    --                     )
    --                )
                GROUP BY trans.CUSTOMER

-----------------------------------------------------------------------------
        SELECT DISTINCT
                trans.CUSTOMER
              , ISNULL(gf.Gf_CnAls_1_01_Alias, 'NotADonor') AS Alias
              , ISNULL(gf.Gf_CnBio_ID, 'NotADonor') AS DonorID
              , donSales.QTY
              , donSales.VALUE
              , ISNULL(( SELECT SUM(gf2.Gf_Amount)
                         FROM   dbo.BB_giftdetail gf2
                         WHERE  gf.Gf_CnAls_1_01_Alias = gf2.Gf_CnAls_1_01_Alias
                                AND ISNULL(gf2.Gf_Letter_code, 'Greg12345') <> 'Round-Up'
                                AND gf2.Gf_Date <= @LASTEVENTDATE
                         GROUP BY gf2.Gf_CnAls_1_01_Alias
                       ), 0) AS TotalDonation
              , ISNULL(( SELECT SUM(gf3.Gf_Amount)
                         FROM   dbo.BB_giftdetail gf3
                         WHERE  gf.Gf_CnAls_1_01_Alias = gf3.Gf_CnAls_1_01_Alias
                                AND ISNULL(gf3.Gf_Letter_code, 'Greg12345') <> 'Round-Up'
                                AND gf3.Gf_Date >= DATEADD(DD,
                                                           ( -1 * @DaysOut ),
                                                           @LASTEVENTDATE)
                                AND gf3.Gf_Date <= @LASTEVENTDATE
                         GROUP BY gf3.Gf_CnAls_1_01_Alias
                       ), 0) AS DateRangeDonation
        INTO    #Detail
        FROM    #Trans trans
                LEFT OUTER JOIN dbo.BB_giftdetail gf WITH ( NOLOCK ) ON ( trans.CUSTOMER = gf.Gf_CnAls_1_01_Alias )
                INNER JOIN #TSCDONORSALES donSales ON ( donSales.CUSTOMER = trans.CUSTOMER )
--FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH (NOLOCK)
--        LEFT OUTER JOIN dbo.BB_giftdetail gf WITH (NOLOCK) ON ( trans.CUSTOMER = gf.Gf_CnAls_1_01_Alias )
--        INNER JOIN dbo.TK_EVENT ev WITH (NOLOCK) ON ( ev.EVENT = trans.EVENT
--                                        AND ev.SEASON = trans.SEASON
--                                      )
--        INNER JOIN #TSCDONORSALES donSales ON ( donSales.CUSTOMER = trans.CUSTOMER )
--WHERE   trans.SEASON IN (SELECT Item FROM #SeasonTemp)
--        AND ( ( @TYPE = 'EG'
--                AND ev.EGROUP IN (SELECT Item FROM #GroupingTemp)
--              )
--              OR ( @TYPE = 'EY'
--                   AND ev.ETYPE IN (SELECT Item FROM #GroupingTemp)
--                 )
--              OR ( @TYPE = 'EV'
--                   AND ev.EVENT IN (SELECT Item FROM #GroupingTemp)
--                 )
--              OR ( @TYPE = 'EC'
--                   AND ev.CLASS IN (SELECT Item FROM #GroupingTemp)
--                 )
--              OR ( @TYPE = 'ET'
--                   AND ev.TAG IN (SELECT TAG FROM #tagtemp)
--                 )
--            )
GROUP BY        trans.CUSTOMER
              , gf.Gf_CnAls_1_01_Alias
              , gf.Gf_CnBio_ID
              , donSales.QTY
              , donSales.VALUE
        ORDER BY trans.CUSTOMER

        SELECT  *
--INTO [dbo].[TEMP_rptCust_Post_Event_DonationCrossover_SSB]
        FROM    ( SELECT    x.GroupTag
                          , x.GroupSort
                          , x.Unique_Count
--, SUM(x.Unique_Count) OVER ( ) AS Total_Unique_Count
                          , CAST(x.Unique_Count AS NUMERIC(18, 2))
                            / CAST(SUM(x.Unique_Count) OVER ( ) AS NUMERIC(18,
                                                              2)) AS Pct_Unique_Count
                          , x.Ticket_Qty
--, SUM(x.Ticket_Qty) OVER () AS Total_Ticket_Qty
                          , x.Ticket_Value
                          , CAST(x.Ticket_Value AS NUMERIC(18, 2))
                            / CAST(SUM(x.Ticket_Value) OVER ( ) AS NUMERIC(18,
                                                              2)) AS Pct_Ticket_Rev
                          , x.Total_Donation
                          , x.Donation_Days_Out
                  FROM      ( SELECT    Detail.GroupTag
                                      , Detail.GroupSort
                                      , COUNT(DISTINCT Detail.CUSTOMER) Unique_Count
                                      , SUM(Detail.QTY) Ticket_Qty
                                      , SUM(Detail.VALUE) Ticket_Value
                                      , SUM(Detail.TotalDonation) Total_Donation
                                      , SUM(Detail.DateRangeDonation) Donation_Days_Out
                              FROM      ( SELECT    CASE WHEN TotalDonation BETWEEN 1 AND 99.99
                                                         THEN '$1.00-$99.99'
                                                         WHEN TotalDonation BETWEEN 100 AND 499.99
                                                         THEN '$100-$499.99'
                                                         WHEN TotalDonation BETWEEN 500 AND 999.99
                                                         THEN '$500-$999.99'
                                                         WHEN TotalDonation BETWEEN 1000 AND 4999.99
                                                         THEN '$1,000-$4,999.99'
                                                         WHEN TotalDonation BETWEEN 5000 AND 9999.99
                                                         THEN '$5,000-$9,999.99'
                                                         WHEN TotalDonation BETWEEN 10000 AND 24999.99
                                                         THEN '$10,000-$24,999.99'
                                                         WHEN TotalDonation BETWEEN 25000 AND 99999.99
                                                         THEN '$25,000-$99,999.99'
                                                         WHEN TotalDonation BETWEEN 100000 AND 499999.99
                                                         THEN '$100,000-$499,999.99'
                                                         WHEN TotalDonation BETWEEN 500000 AND 999999.99
                                                         THEN '$500,000-$999,999.99'
                                                         WHEN TotalDonation > 999999.99
                                                         THEN '$1,000,000+'
                                                         ELSE 'No Donation'
                                                    END AS GroupTag
                                                  , CASE WHEN TotalDonation BETWEEN 1 AND 99.99
                                                         THEN 1
                                                         WHEN TotalDonation BETWEEN 100 AND 499.99
                                                         THEN 2
                                                         WHEN TotalDonation BETWEEN 500 AND 999.99
                                                         THEN 3
                                                         WHEN TotalDonation BETWEEN 1000 AND 4999.99
                                                         THEN 4
                                                         WHEN TotalDonation BETWEEN 5000 AND 9999.99
                                                         THEN 5
                                                         WHEN TotalDonation BETWEEN 10000 AND 24999.99
                                                         THEN 6
                                                         WHEN TotalDonation BETWEEN 25000 AND 99999.99
                                                         THEN 7
                                                         WHEN TotalDonation BETWEEN 100000 AND 499999.99
                                                         THEN 8
                                                         WHEN TotalDonation BETWEEN 500000 AND 999999.99
                                                         THEN 9
                                                         WHEN TotalDonation > 999999.99
                                                         THEN 10
                                                         ELSE 99
                                                    END AS GroupSort
                                                  , *
                                          FROM      #Detail
                                        ) Detail
                              GROUP BY  Detail.GroupTag
                                      , Detail.GroupSort
                            ) x
                  UNION ALL
                  SELECT    'TOTAL'
                          , 999
                          , COUNT(DISTINCT CUSTOMER)
                          , NULL
                          , SUM(QTY)
                          , SUM(VALUE)
                          , NULL
                          , NULL
                          , NULL
                  FROM      #Detail
                ) Results
        ORDER BY Results.GroupSort

        DROP TABLE #TSCDONORSALES
        DROP TABLE #Detail

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - DonationCrossoverExit' 

--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_DonationCrossover_SSB]

    END



GO
