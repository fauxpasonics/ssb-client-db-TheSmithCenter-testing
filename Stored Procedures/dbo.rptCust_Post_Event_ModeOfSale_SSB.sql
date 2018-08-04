SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
EXEC dbo.rptCust_Post_Event_ModeOfSale_SSB  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)

*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_ModeOfSale_SSB]
    @TYPE AS VARCHAR(2)
  , @GROUPING AS VARCHAR(500)
  , @Season AS VARCHAR(15)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

        IF OBJECT_ID('tempdb..#ModeOfSale') IS NOT NULL
            DROP TABLE #ModeOfSale

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - ModeOfSaleEnter'
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

        CREATE TABLE #ModeOfSale
            (
              Salecode VARCHAR(50)
            , Qty DECIMAL(18, 0)
            , Value DECIMAL(18, 2)
            )

        INSERT  INTO #ModeOfSale
                ( Salecode
                , Qty
                , Value
                )
                SELECT DISTINCT
                        salecode.NAME AS Salecode
                      , SUM(trans.E_OQTY_TOT) AS Qty
                      , SUM(trans.E_OQTY_TOT * trans.E_PRICE) AS Value
                FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                        INNER JOIN dbo.TK_SALECODE salecode WITH ( NOLOCK ) ON ( salecode.SALECODE = trans.SALECODE )
                        INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) ON ( trans.SEASON = event.SEASON
                                                              AND event.EVENT = trans.EVENT
                                                              )
                        INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                                                              AND prtype.PRTYPE = trans.E_PT
                                                              )
						INNER JOIN #SeasonTemp st
							on trans.SEASON = st.Item
                WHERE   ISNULL(prtype.KIND, 'GREG') <> 'H'
                        AND ( ( @TYPE = 'EG'
                                AND event.EGROUP IN ( SELECT  Item
                                                      FROM    #GroupingTemp )
                              )
                              OR ( @TYPE = 'EY'
                                   AND event.ETYPE IN ( SELECT
                                                              Item
                                                        FROM  #GroupingTemp )
                                 )
                              OR ( @TYPE = 'EV'
                                   AND event.EVENT IN ( SELECT
                                                              Item
                                                        FROM  #GroupingTemp )
                                 )
                              OR ( @TYPE = 'EC'
                                   AND event.CLASS IN ( SELECT
                                                              Item
                                                        FROM  #GroupingTemp )
                                 )
                              OR ( @TYPE = 'ET'
                                   AND TAG IN ( SELECT  TAG
                                                FROM    #tagtemp )
                                 )
                            )
                GROUP BY salecode.NAME

        SELECT  Salecode
              , Qty
              , Value
              , ( ( Value / ( SELECT    SUM(Value)
                              FROM      #ModeOfSale
                            ) ) ) AS Percentage
--INTO [dbo].[TEMP_rptCust_Post_Event_ModeOfSale_SSB]
        FROM    #ModeOfSale
        ORDER BY Qty DESC



--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_ModeOfSale_SSB]

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - ModeOfSaleExit'

    END




GO
