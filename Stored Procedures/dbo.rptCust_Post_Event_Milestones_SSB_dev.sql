SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC dbo.rptCust_Post_Event_Milestones_SSB_dev  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)


*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_Milestones_SSB_dev]
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
                      , 'PostEvent - MilestonesEnter'

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

        
		
------------------------------------------------------------------

        SELECT 
                trans.CUSTOMER
              , cust.TYPE
              , trans.DATE
              , rlv.e_oqty_tot QtyTot
			  , rlv.e_price AmtTot
        INTO    #temp
        FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
				inner join dbo.rpt_RunningLifetimeValue rlv on rlv.Customer = trans.Customer and rlv.Date = trans.Date
			    INNER JOIN dbo.TK_EVENT event ON ( trans.EVENT = event.EVENT
                                                   AND trans.SEASON = event.SEASON
                                                 )
                INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                                                              AND prtype.PRTYPE = trans.E_PT
                                                              )
                LEFT OUTER JOIN dbo.TK_CUSTOMER cust WITH ( NOLOCK ) ON ( trans.CUSTOMER = cust.CUSTOMER )
        WHERE   ISNULL(prtype.KIND, 'GREG') <> 'H'
                --AND trans.SALECODE <> 'SH'
                AND trans.SEASON IN ( SELECT    Item
                                      FROM      #SeasonTemp )
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
        
        ORDER BY trans.CUSTOMER
              , trans.DATE


        CREATE TABLE #output
            (
              sortOrder INT
            , category VARCHAR(50)
            , Individual BIGINT
            , Groups BIGINT
            )

        INSERT  INTO #Output
                ( sortOrder
                , category
                , Individual
                , Groups 
                )
                SELECT  CASE WHEN AmtTot > 50000 THEN 6
                             WHEN AmtTot > 40000 THEN 5
                             WHEN AmtTot > 30000 THEN 4
                             WHEN AmtTot > 20000 THEN 3
                             WHEN AmtTot > 10000 THEN 2
                             WHEN AmtTot > 5000 THEN 1
                        END AS sortOrder
                      , CASE WHEN AmtTot > 50000 THEN '$50000'
                             WHEN AmtTot > 40000 THEN '$40000'
                             WHEN AmtTot > 30000 THEN '$30000'
                             WHEN AmtTot > 20000 THEN '$20000'
                             WHEN AmtTot > 10000 THEN '$10000'
                             WHEN AmtTot > 5000 THEN '$5000'
                        END AS category
                      , COUNT(CASE WHEN TYPE = 'I' THEN CUSTOMER
                              END) AS Individual
                      , COUNT(CASE WHEN TYPE = 'G' THEN CUSTOMER
                              END) AS Groups
                FROM    ( SELECT    temp.CUSTOMER
                                  , temp.TYPE
                                  , MAX(temp.AmtTot) AS AmtTot
                          FROM      #temp temp
                          GROUP BY  temp.CUSTOMER
                                  , temp.TYPE
                        ) Amt
                GROUP BY CASE WHEN AmtTot > 50000 THEN 6
                              WHEN AmtTot > 40000 THEN 5
                              WHEN AmtTot > 30000 THEN 4
                              WHEN AmtTot > 20000 THEN 3
                              WHEN AmtTot > 10000 THEN 2
                              WHEN AmtTot > 5000 THEN 1
                         END
                      , CASE WHEN AmtTot > 50000 THEN '$50000'
                             WHEN AmtTot > 40000 THEN '$40000'
                             WHEN AmtTot > 30000 THEN '$30000'
                             WHEN AmtTot > 20000 THEN '$20000'
                             WHEN AmtTot > 10000 THEN '$10000'
                             WHEN AmtTot > 5000 THEN '$5000'
                        END
                UNION ALL
                SELECT  CASE WHEN qtytot > 500 THEN 11
                             WHEN qtytot > 400 THEN 10
                             WHEN qtytot > 300 THEN 9
                             WHEN qtytot > 200 THEN 8
                             WHEN qtytot > 100 THEN 7
                        END AS sortOrder
                      , CASE WHEN qtytot > 500 THEN '500 Tickets'
                             WHEN qtytot > 400 THEN '400 Tickets'
                             WHEN qtytot > 300 THEN '300 Tickets'
                             WHEN qtytot > 200 THEN '200 Tickets'
                             WHEN qtytot > 100 THEN '100 Tickets'
                        END AS category
                      , COUNT(CASE WHEN TYPE = 'I' THEN CUSTOMER
                              END) AS Individual
                      , COUNT(CASE WHEN TYPE = 'G' THEN CUSTOMER
                              END) AS Groups
                FROM    ( SELECT    temp.CUSTOMER
                                  , temp.TYPE
                                  , MAX(temp.QtyTot) AS qtytot
                          FROM      #temp temp
                          GROUP BY  temp.CUSTOMER
                                  , temp.TYPE
                        ) qty
                GROUP BY CASE WHEN qtytot > 500 THEN 11
                              WHEN qtytot > 400 THEN 10
                              WHEN qtytot > 300 THEN 9
                              WHEN qtytot > 200 THEN 8
                              WHEN qtytot > 100 THEN 7
                         END
                      , CASE WHEN qtytot > 500 THEN '500 Tickets'
                             WHEN qtytot > 400 THEN '400 Tickets'
                             WHEN qtytot > 300 THEN '300 Tickets'
                             WHEN qtytot > 200 THEN '200 Tickets'
                             WHEN qtytot > 100 THEN '100 Tickets'
                        END



        SELECT  * 
--INTO [dbo].[TEMP_rptCust_Post_Event_Milestones_SSB]
        FROM    #Output
        WHERE   category IS NOT NULL
        ORDER BY sortOrder



--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_Milestones_SSB]


        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - MilestonesExit'

    END







GO
