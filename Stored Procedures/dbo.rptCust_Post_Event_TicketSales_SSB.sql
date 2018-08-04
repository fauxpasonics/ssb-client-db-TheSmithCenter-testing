SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC dbo.rptCust_Post_Event_TicketSales_SSB  @TYPE = 'EG', -- varchar(2)
    @GROUPING = 'TKI', -- varchar(25)
    @Season = 'TSC1718' -- varchar(15)
*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_TicketSales_SSB]
    @TYPE AS VARCHAR(2)
  , @GROUPING AS VARCHAR(500)
  , @Season AS VARCHAR(15)
AS
--DECLARE @TYPE AS VARCHAR(2) = 'EG' --'ET' --'EG'
--  , @GROUPING AS VARCHAR(500) = 'TKI' --'HOUSE OSD-12292017' --'TKI'
--  , @Season AS VARCHAR(15) = 'TSC1718'

    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

        IF OBJECT_ID('tempdb..#Group') IS NOT NULL
            DROP TABLE #Group

/***************** Set Attendance Variable **********************/

        INSERT dbo.TempVariableTrap
        SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                + '|'
                , GETDATE()
                , 'PostEvent - TicketSalesEnter'

        DECLARE @Attended AS NUMERIC
        DECLARE @Capacity AS NUMERIC

		--DECLARE @TYPE AS VARCHAR(2) = 'ET'
		--DECLARE @GROUPING AS VARCHAR(500) = 'BWAY'
		--DECLARE @Season AS VARCHAR(15) = 'TSC1415'

		IF OBJECT_ID('tempdb..#GroupingTemp') IS NOT NULL
			DROP TABLE #GroupingTemp
		IF OBJECT_ID('tempdb..#SeasonTemp') IS NOT NULL
			DROP TABLE #SeasonTemp
		IF OBJECT_ID('tempdb..#tagtemp') IS NOT NULL
			DROP TABLE #tagtemp
		IF OBJECT_ID('tempdb..#Output') IS NOT NULL
			DROP TABLE #Output

        SELECT  Item
        INTO    #GroupingTemp
        FROM    [dbo].[SplitSSB](@GROUPING, ',')
        WHERE   @TYPE <> 'ET'

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

		--IF OBJECT_ID('tempdb..#GroupJoin') IS NOT NULL
		--	DROP TABLE #GroupJoin
		--CREATE TABLE #GroupJoin (
		--	[Type] [VARCHAR](50),
		--	[EGroup] [VARCHAR](50),
		--	[EType] [VARCHAR](50),
		--	[Event] [VARCHAR](50),
		--	[Class] [VARCHAR](50),
		--	[Tag] [VARCHAR](50),
		--	[Item] [VARCHAR](50)
		--)
		--INSERT INTO #GroupJoin (
		--	[Type],
		--	[EGroup],
		--	[EType],
		--	[Event],
		--	[Class],
		--	[Tag],
		--	[Item]
		--)
		--SELECT
		--	@Type AS [Type],
		--	CASE WHEN @Type = 'EG' THEN Item END AS [EGroup],
		--	CASE WHEN @Type = 'EY' THEN Item END AS [EType],
		--	CASE WHEN @Type = 'EV' THEN Item END AS [Event],
		--	CASE WHEN @Type = 'EC' THEN Item END AS [Class],
		--	CASE WHEN @Type = 'ET' THEN Item END AS [Tag],
		--	Item
		--FROM dbo.SplitSSB(@GROUPING, ',')
  --      WHERE @TYPE <> 'ET'

		--INSERT INTO #GroupJoin (
		--	[Type],
		--	[Tag],
		--	[Item]
		--)
		--SELECT DISTINCT
		--	@TYPE AS [Type],
		--	[Tag],
		--	[Tag] AS Item
		--FROM dbo.SplitSSB(@GROUPING, ',') s
		--INNER JOIN dbo.TK_EVENT te
		--	ON  PATINDEX('% ' + s.Item + ' %', ' ' + TAG COLLATE SQL_Latin1_General_CP1_CI_AS + ' ') > 0 
		--INNER JOIN #SeasonTemp st
		--	ON  te.SEASON = st.Item
		--WHERE @TYPE = 'ET'
		--	AND te.Tag IS NOT NULL

        SET @Attended = ( 
			SELECT COUNT(bc.ATTENDED) AS [Count]
            FROM dbo.TK_BC bc WITH ( NOLOCK )
            INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK )
				ON  bc.SEASON = event.SEASON
                AND bc.EVENT = event.EVENT
			INNER JOIN #SeasonTemp st
				ON  bc.Season = st.Item
            WHERE 1 = 1
                AND bc.ATTENDED = 'Y'
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
                        OR ( @TYPE = 'EC'
                            AND event.CLASS IN ( SELECT
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

        SET @Capacity = (
			SELECT SUM(CAPACITY) AS Capacity
            FROM dbo.TK_EVENT event WITH ( NOLOCK )
			INNER JOIN #SeasonTemp st
				ON  event.Season = st.Item
            WHERE  1=1
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
                          OR ( @TYPE = 'EC'
                               AND event.CLASS IN ( SELECT
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

/***************** Set Group Variables **********************/

--DECLARE @TYPE AS VARCHAR(2) = 'EV'
--DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
--DECLARE @Season AS VARCHAR(15) = 'TSC1415'

        DECLARE @NumGroups NUMERIC
        DECLARE @MaxGroupSize NUMERIC
        DECLARE @MinGroupSize NUMERIC

		SELECT @NumGroups = COUNT(CUSTOMER), @MaxGroupSize = MAX(Group_Size), @MinGroupSize =  MIN(Group_Size)
		FROM (
				SELECT
					 trans.CUSTOMER
					,COUNT(trans.CUSTOMER) Group_Size
					,SUM(trans.E_OQTY_TOT) Qty
				--INTO    #Group
				FROM dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
				INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) 
					ON  trans.SEASON = event.SEASON
					AND trans.EVENT = event.EVENT
				INNER JOIN dbo.TK_PRTYPE pt WITH ( NOLOCK ) 
					ON  pt.SEASON = trans.SEASON
					AND pt.PRTYPE = trans.E_PT
				INNER JOIN #SeasonTemp st
					ON  trans.Season = st.Item
				WHERE 1=1
					AND pt.PRTYPE <> 'SH' AND pt.KIND <> 'H'
					AND pt.CLASS = 'GRP'
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
					GROUP BY trans.CUSTOMER
					HAVING  SUM(trans.E_OQTY_TOT) > 0
			) A

        --SET @NumGroups = ( SELECT   COUNT(CUSTOMER)
        --                   FROM     #Group
        --                 )
        --SET @MaxGroupSize = ( SELECT    MAX(Group_Size)
        --                      FROM      #Group
        --                    )
        --SET @MinGroupSize = ( SELECT    MIN(Group_Size)
        --                      FROM      #Group
        --                    )

/***************** Ticket Sales **********************/

--DECLARE @TYPE AS VARCHAR(2) = 'EV'
--DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
--DECLARE @Season AS VARCHAR(15) = 'TSC1415'

--SET @TYPE = '{?Pm-?EventSelect}'
--SET @GROUPING = '{?Pm-?EventValue}'


--        SELECT  SUM(Detail.E_PRICE * Detail.E_OQTY_TOT)
--                / SUM(Detail.E_OQTY_TOT) AS Avg_Net_Ticket
--              , SUM(( Detail.E_PRICE + Detail.E_FPRICE ) * Detail.E_OQTY_TOT)
--                / SUM(Detail.E_OQTY_TOT) AS Avg_Gross_Ticket
--              , SUM(( Detail.E_PRICE + Detail.E_FPRICE + Detail.E_CPRICE )
--                    * Detail.E_OQTY_TOT) / SUM(Detail.E_OQTY_TOT) AS Avg_Ticket_Price
--              , CAST(SUM(Detail.E_OQTY_TOT) / COUNT(DISTINCT Detail.CUSTOMER) AS NUMERIC(18,
--                                                              2)) AS Avg_Order_Size
--              , COUNT(DISTINCT Detail.EVENT) AS No_of_Perfs
--              , SUM(Detail.E_PRICE * Detail.E_OQTY_TOT) AS Net_Sales
--              , SUM(( Detail.E_PRICE + Detail.E_FPRICE ) * Detail.E_OQTY_TOT) AS Gross_Sales
--              , SUM(( Detail.E_PRICE + Detail.E_FPRICE + Detail.E_CPRICE )
--                    * Detail.E_OQTY_TOT) AS Total_Sales
--              , SUM(CASE WHEN Detail.E_PRICE > 0 THEN Detail.E_OQTY_TOT
--                    END) AS Tickets_Sold
--              , SUM(CASE WHEN Detail.E_PRICE = 0 THEN Detail.E_OQTY_TOT
--                    END) AS Tickets_Comps
--              , SUM(Detail.E_OQTY_TOT) AS Total_Tickets
--              , SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP'
--                         THEN Detail.E_OQTY_TOT
--                    END) AS Tickets_Sold_Groups
--              , ISNULL(SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP'
--                                THEN Detail.E_OQTY_TOT
--                           END) / NULLIF(@NumGroups, 0), 0) AS Avg_Tickets_Sold_Groups
--              , SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP'
--                         THEN ( Detail.E_OQTY_TOT * Detail.E_PRICE )
--                    END) AS Tickets_Rev_Groups
--              , ISNULL(SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP'
--                                THEN ( Detail.E_OQTY_TOT * Detail.E_PRICE )
--                           END) / NULLIF(@NumGroups, 0), 0) AS Avg_Tickets_Rev_Groups
--              , ISNULL(@NumGroups, 0) AS Num_of_Groups
--              , ISNULL(@MaxGroupSize, 0) AS Largest_Group
--              , ISNULL(@MinGroupSize, 0) AS Smallest_Group
--              , SUM(CAST(Detail.E_OQTY_TOT AS NUMERIC)) / @Capacity AS Pct_Sold
--              , @Attended / @Capacity AS Pct_Attended
--              , @Capacity AS Total_Capacity
--              , COUNT(DISTINCT CUSTOMER) AS Total_Unique_Patrons
----		INTO [dbo].[TEMP_rptCust_Post_Event_TicketSales_SSB]
--        FROM    ( SELECT    trans.E_PRICE
--                          , trans.E_OQTY_TOT
--                          , trans.CUSTOMER
--                          , trans.E_PQTY
--                          , event.CAPACITY
--                          , prtype.CLASS
--                          , event.SEASON
--                          , event.EVENT
--                          , trans.E_FPRICE
--                          , trans.E_CPRICE
--                          , trans.TOTAL_EPAY
--                          , trans.E_PT
--                  FROM      dbo.TK_TRANS_ITEM_EVENT trans
--                            INNER JOIN dbo.TK_EVENT event ON ( trans.EVENT = event.EVENT
--                                                              AND trans.SEASON = event.SEASON
--                                                             )
--                            INNER JOIN dbo.TK_PRTYPE prtype ON ( trans.E_PT = prtype.PRTYPE
--                                                              AND trans.SEASON = prtype.SEASON
--                                                              )
--                  WHERE     ISNULL(prtype.KIND, 'F') <> 'H'
--                            AND trans.SEASON IN ( SELECT    Item
--                                                  FROM      #SeasonTemp )
--                            AND trans.SALECODE <> 'SH'
--                            AND ( ( @TYPE = 'EG'
--                                    AND event.EGROUP IN ( SELECT
--                                                              Item
--                                                          FROM
--                                                              #GroupingTemp )
--                                  )
--                                  OR ( @TYPE = 'EY'
--                                       AND event.ETYPE IN ( SELECT
--                                                              Item
--                                                            FROM
--                                                              #GroupingTemp )
--                                     )
--                                  OR ( @TYPE = 'EV'
--                                       AND event.EVENT IN ( SELECT
--                                                              Item
--                                                            FROM
--                                                              #GroupingTemp )
--                                     )
--                                  OR ( @TYPE = 'EC'
--                                       AND event.CLASS IN ( SELECT
--                                                              Item
--                                                            FROM
--                                                              #GroupingTemp )
--                                     )
--                                  OR ( @TYPE = 'ET'
--                                       AND TAG IN ( SELECT  TAG
--                                                    FROM    #tagtemp )
--                                     )
--                                )
--                ) Detail

		SELECT  
			 SUM(Detail.E_PRICE * Detail.E_OQTY_TOT)
                / SUM(Detail.E_OQTY_TOT) AS Avg_Net_Ticket
			,SUM(( Detail.E_PRICE + Detail.E_FPRICE ) * Detail.E_OQTY_TOT)
				/ SUM(Detail.E_OQTY_TOT) AS Avg_Gross_Ticket
			,SUM(( Detail.E_PRICE + Detail.E_FPRICE + Detail.E_CPRICE )
				* Detail.E_OQTY_TOT) / SUM(Detail.E_OQTY_TOT) AS Avg_Ticket_Price
			,CAST(SUM(Detail.E_OQTY_TOT) / COUNT(DISTINCT Detail.CUSTOMER) AS NUMERIC(18, 2)) AS Avg_Order_Size
			,COUNT(DISTINCT Detail.EVENT) AS No_of_Perfs
			,SUM(Detail.E_PRICE * Detail.E_OQTY_TOT) AS Net_Sales
			,SUM(( Detail.E_PRICE + Detail.E_FPRICE ) * Detail.E_OQTY_TOT) AS Gross_Sales
			,SUM(( Detail.E_PRICE + Detail.E_FPRICE + Detail.E_CPRICE ) * Detail.E_OQTY_TOT) AS Total_Sales
			,SUM(CASE WHEN Detail.E_PRICE > 0 THEN Detail.E_OQTY_TOT END) AS Tickets_Sold
			,SUM(CASE WHEN Detail.E_PRICE = 0 THEN Detail.E_OQTY_TOT END) AS Tickets_Comps
			,SUM(Detail.E_OQTY_TOT) AS Total_Tickets
			,SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP' THEN Detail.E_OQTY_TOT END) AS Tickets_Sold_Groups
			,ISNULL(SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP' THEN Detail.E_OQTY_TOT END) 
				/ NULLIF(@NumGroups, 0), 0) AS Avg_Tickets_Sold_Groups
			,SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP' THEN ( Detail.E_OQTY_TOT * Detail.E_PRICE ) END) AS Tickets_Rev_Groups
			,ISNULL(SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP' THEN ( Detail.E_OQTY_TOT * Detail.E_PRICE ) END) / NULLIF(@NumGroups, 0), 0) AS Avg_Tickets_Rev_Groups
			,ISNULL(@NumGroups, 0) AS Num_of_Groups
			,ISNULL(@MaxGroupSize, 0) AS Largest_Group
			,ISNULL(@MinGroupSize, 0) AS Smallest_Group
			,SUM(CAST(Detail.E_OQTY_TOT AS NUMERIC)) / @Capacity AS Pct_Sold
			,@Attended / @Capacity AS Pct_Attended
			,@Capacity AS Total_Capacity
			,COUNT(DISTINCT CUSTOMER) AS Total_Unique_Patrons
		FROM (
				SELECT  
					 trans.E_PRICE
					,trans.E_OQTY_TOT
					,trans.CUSTOMER
					,event.CAPACITY
					,prtype.CLASS
					,event.EVENT
					,trans.E_FPRICE
					,trans.E_CPRICE
					,trans.TOTAL_EPAY
				FROM dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
				INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) 
					ON  trans.EVENT = event.EVENT
					AND trans.SEASON = event.SEASON
				INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) 
					ON  trans.E_PT = prtype.PRTYPE
					AND trans.SEASON = prtype.SEASON
				INNER JOIN #SeasonTemp st
					ON  trans.Season = st.Item
				WHERE ISNULL(prtype.KIND, 'F') <> 'H'
					AND prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
						AND ( 
							   ( @TYPE = 'EG'
								AND event.EGROUP IN (SELECT Item
													 FROM #GroupingTemp)
								)
							OR ( @TYPE = 'EY'
								AND event.ETYPE IN (SELECT Item
													FROM #GroupingTemp)
								)
							OR ( @TYPE = 'EV'
								AND event.EVENT IN (SELECT Item
													FROM #GroupingTemp)
								)
							OR ( @TYPE = 'EC'
								AND event.CLASS IN (SELECT Item
													FROM #GroupingTemp)
								)
							OR ( @TYPE = 'ET'
								AND TAG IN (SELECT TAG
											FROM #tagtemp)
								)
						)
			) Detail

--        SELECT  SUM(Detail.E_PRICE * Detail.E_OQTY_TOT)
--                / SUM(Detail.E_OQTY_TOT) AS Avg_Net_Ticket
--              , SUM(( Detail.E_PRICE + Detail.E_FPRICE ) * Detail.E_OQTY_TOT)
--                / SUM(Detail.E_OQTY_TOT) AS Avg_Gross_Ticket
--              , SUM(( Detail.E_PRICE + Detail.E_FPRICE + Detail.E_CPRICE )
--                    * Detail.E_OQTY_TOT) / SUM(Detail.E_OQTY_TOT) AS Avg_Ticket_Price
--              , CAST(SUM(Detail.E_OQTY_TOT) / COUNT(DISTINCT Detail.CUSTOMER) AS NUMERIC(18,
--                                                              2)) AS Avg_Order_Size
--              , COUNT(DISTINCT Detail.EVENT) AS No_of_Perfs
--              , SUM(Detail.E_PRICE * Detail.E_OQTY_TOT) AS Net_Sales
--              , SUM(( Detail.E_PRICE + Detail.E_FPRICE ) * Detail.E_OQTY_TOT) AS Gross_Sales
--              , SUM(( Detail.E_PRICE + Detail.E_FPRICE + Detail.E_CPRICE )
--                    * Detail.E_OQTY_TOT) AS Total_Sales
--              , SUM(CASE WHEN Detail.E_PRICE > 0 THEN Detail.E_OQTY_TOT
--                    END) AS Tickets_Sold
--              , SUM(CASE WHEN Detail.E_PRICE = 0 THEN Detail.E_OQTY_TOT
--                    END) AS Tickets_Comps
--              , SUM(Detail.E_OQTY_TOT) AS Total_Tickets
--              , SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP'
--                         THEN Detail.E_OQTY_TOT
--                    END) AS Tickets_Sold_Groups
--              , ISNULL(SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP'
--                                THEN Detail.E_OQTY_TOT
--                           END) / NULLIF(@NumGroups, 0), 0) AS Avg_Tickets_Sold_Groups
--              , SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP'
--                         THEN ( Detail.E_OQTY_TOT * Detail.E_PRICE )
--                    END) AS Tickets_Rev_Groups
--              , ISNULL(SUM(CASE WHEN ISNULL(Detail.CLASS, '') = 'GRP'
--                                THEN ( Detail.E_OQTY_TOT * Detail.E_PRICE )
--                           END) / NULLIF(@NumGroups, 0), 0) AS Avg_Tickets_Rev_Groups
--              , ISNULL(@NumGroups, 0) AS Num_of_Groups
--              , ISNULL(@MaxGroupSize, 0) AS Largest_Group
--              , ISNULL(@MinGroupSize, 0) AS Smallest_Group
--              , SUM(CAST(Detail.E_OQTY_TOT AS NUMERIC)) / @Capacity AS Pct_Sold
--              , @Attended / @Capacity AS Pct_Attended
--              , @Capacity AS Total_Capacity
--              , COUNT(DISTINCT CUSTOMER) AS Total_Unique_Patrons
----		INTO [dbo].[TEMP_rptCust_Post_Event_TicketSales_SSB]
--        FROM    #Output Detail

--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_TicketSales_SSB]


        INSERT dbo.TempVariableTrap
        SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                + '|'
                , GETDATE()
                , 'PostEvent - TicketSalesExit'

    END
GO
