SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC dbo.rptCust_Post_Event_Attendance_SSB  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_Attendance_SSB]
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
                      , 'PostEvent - AttendanceEnter' 

--DECLARE @TYPE AS VARCHAR(2) = 'EG'
--DECLARE @GROUPING AS VARCHAR(500) = 'TKI'
--DECLARE @Season AS VARCHAR(15) = 'TSC1718'	
--DROP TABLE #GroupingTemp
--DROP TABLE #SeasonTemp
--DROP TABLE #tagtemp
--DROP TABLE #Output

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

        SELECT DISTINCT
                ISNULL(prtype.KIND, 'F') AS KIND
              , bc.STATUS
              , bc.ATTENDED
              , COUNT(bc.ATTENDED) AS COUNT
              , SUM(odet.E_PRICE) AS Price
        INTO    #Output
        FROM    dbo.TK_BC bc WITH ( NOLOCK )
                INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( bc.SEASON = prtype.SEASON
                                                              AND bc.I_PT = prtype.PRTYPE
                                                              )
                INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) ON ( bc.SEASON = event.SEASON
                                                              AND bc.EVENT = event.EVENT
                                                              )
                LEFT OUTER JOIN dbo.TK_ODET_EVENT_ASSOC odet WITH ( NOLOCK ) ON ( bc.SEASON = odet.SEASON
                                                              AND bc.CUSTOMER = odet.CUSTOMER
                                                              AND bc.SEQ = odet.SEQ
                                                              AND bc.EVENT = odet.EVENT
                                                              )
				INNER JOIN #SeasonTemp st
					on bc.SEASON = st.Item
        WHERE   ISNULL(prtype.KIND, 'GREG') <> 'H'
                AND event.DATE <= GETDATE()
                AND ( ( @TYPE = 'EG'
                        AND event.EGROUP IN (
                        SELECT  Item
                        FROM   #GroupingTemp )
                      )
                      OR ( @TYPE = 'EY'
                           AND event.ETYPE IN (
                           SELECT   Item
                           FROM   #GroupingTemp )
                         )
                      OR ( @TYPE = 'EV'
                           AND event.EVENT IN (
                           SELECT   Item
                           FROM   #GroupingTemp )
                         )
                      OR ( @TYPE = 'EC'
                           AND event.CLASS IN (
                           SELECT   Item
                           FROM  #GroupingTemp )
                         )
                      OR ( @TYPE = 'ET'
                           AND event.TAG IN ( SELECT    TAG
                                              FROM      #tagtemp )
                         )
                    )
        GROUP BY ISNULL(prtype.KIND, 'F')
              , bc.STATUS
              , bc.ATTENDED
        ORDER BY ISNULL(prtype.KIND, 'F')
              , bc.STATUS
              , bc.ATTENDED


        SELECT  *
	--	INTO [dbo].[TEMP_rptCust_Post_Event_Attendance_SSB]
        FROM    ( SELECT    x.GroupTag
                          , x.GroupTagSort
                          , ISNULL(x.Attended, 0) Attended
                          , ISNULL(x.Sold, 0) Sold
                          , ISNULL(CAST(x.Attended AS NUMERIC(18, 2))
                                   / CAST(x.Sold AS NUMERIC(18, 2)), 0) Pct_Attended
                          , ISNULL(x.No_Show, 0) No_Show
                          , ISNULL(CAST(x.No_Show AS NUMERIC(18, 2))
                                   / CAST(x.Sold AS NUMERIC(18, 2)), 0) Pct_No_Show
                          , ISNULL(x.No_Show_Price, 0) No_Show_Price
                  FROM      ( SELECT    CASE WHEN KIND = 'F'
                                             THEN 'Tickets Sold'
                                             WHEN KIND = 'C' THEN 'Comps'
                                        END AS GroupTag
                                      , CASE WHEN KIND = 'F' THEN 1
                                             WHEN KIND = 'C' THEN 2
                                        END AS GroupTagSort
                                      , SUM(CASE WHEN ATTENDED = 'Y'
                                                 THEN COUNT
                                            END) AS Attended
                                      , SUM(CASE WHEN STATUS IS NULL
                                                 THEN COUNT
                                            END) AS Sold
                                      , SUM(CASE WHEN ATTENDED = 'N'
                                                      AND STATUS IS NULL
                                                 THEN COUNT
                                            END) AS No_Show
                                      , SUM(CASE WHEN ATTENDED = 'N'
                                                      AND STATUS IS NULL
                                                 THEN Price
                                            END) AS No_Show_Price
                              FROM      #Output
                              GROUP BY  KIND
                            ) x
                  UNION ALL
                  SELECT    'TOTAL'
                          , 99
                          , SUM(CASE WHEN ATTENDED = 'Y' THEN COUNT
                                END) AS Attended
                          , SUM(CASE WHEN STATUS IS NULL THEN COUNT
                                END) AS Sold
                          , CAST(SUM(CASE WHEN ATTENDED = 'Y' THEN COUNT
                                     END) AS NUMERIC(18, 2))
                            / CAST(SUM(CASE WHEN STATUS IS NULL THEN COUNT
                                       END) AS NUMERIC(18, 2))
                          , SUM(CASE WHEN ATTENDED = 'N'
                                          AND STATUS IS NULL THEN COUNT
                                END) AS No_Show
                          , CAST(SUM(CASE WHEN ATTENDED = 'N'
                                               AND STATUS IS NULL THEN COUNT
                                     END) AS NUMERIC(18, 2))
                            / CAST(SUM(CASE WHEN STATUS IS NULL THEN COUNT
                                       END) AS NUMERIC(18, 2))
                          , NULL
                  FROM      #Output
                ) z
        ORDER BY z.GroupTagSort

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - AttendanceExit' 

    END




GO
