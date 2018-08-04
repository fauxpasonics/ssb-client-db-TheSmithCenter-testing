SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
EXEC dbo.rptCust_Post_Event_ReferralLocation_SSB  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415'

*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_ReferralLocation_SSB]
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
                      , 'PostEvent - ReferralLocationEnter'

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

        SELECT  ISNULL(tkTransItem.INREFSOURCE, 'No Referral Data') AS Source
              , ISNULL(tkTransItem.INREFDATA, 'No Referral Data') AS Data
              , SUM(trans.E_OQTY_TOT) AS Qty
              , SUM(trans.E_OQTY_TOT * trans.E_PRICE) AS Value
        INTO    #temp
        FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
        INNER JOIN dbo.TK_TRANS_ITEM tkTransItem WITH ( NOLOCK ) ON ( trans.SEASON = tkTransItem.SEASON
            AND trans.TRANS_NO = tkTransItem.TRANS_NO
            AND trans.VMC = tkTransItem.VMC
            )
        INNER JOIN dbo.TK_EVENT tkEvent WITH ( NOLOCK ) ON ( trans.SEASON = tkEvent.SEASON
			AND trans.EVENT = tkEvent.EVENT
			)
		INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
            AND prtype.PRTYPE = trans.E_PT
            )
		INNER JOIN #SeasonTemp st
			ON  trans.SEASON = st.Item
        WHERE   prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
                AND ( ( @TYPE = 'EG'
                        AND tkEvent.EGROUP IN ( SELECT  Item
                                                FROM    #GroupingTemp )
                      )
                      OR ( @TYPE = 'EY'
                           AND tkEvent.ETYPE IN ( SELECT    Item
                                                  FROM      #GroupingTemp )
                         )
                      OR ( @TYPE = 'EV'
                           AND tkEvent.EVENT IN ( SELECT    Item
                                                  FROM      #GroupingTemp )
                         )
                      OR ( @TYPE = 'EC'
                           AND tkEvent.CLASS IN ( SELECT    Item
                                                  FROM      #GroupingTemp )
                         )
                      OR ( @TYPE = 'ET'
                           AND TAG IN ( SELECT  TAG
                                        FROM    #tagtemp )
                         )
                    )
        GROUP BY ISNULL(tkTransItem.INREFSOURCE, 'No Referral Data')
              , ISNULL(tkTransItem.INREFDATA, 'No Referral Data')
        HAVING  SUM(trans.E_OQTY_TOT) > 0
        ORDER BY SUM(trans.E_OQTY_TOT) DESC
              , SUM(trans.E_OQTY_TOT * trans.E_PRICE) DESC


        SELECT  Source
              , Data
              , Qty
              , SUM(temp.Qty) OVER ( ) AS total_qty
              , Value
              , SUM(temp.Value) OVER ( ) AS total_value
        INTO    #output
        FROM    #temp temp
        GROUP BY Source
              , Data
              , Qty
              , Value

        SELECT  Source
              , Data
              , Qty
              , total_qty
              , 1.0 * Qty / total_qty AS pct_total_qty
              , Value
              , total_value
              , Value / total_value AS pct_total_value
--INTO [dbo].[TEMP_rptCust_Post_Event_ReferralLocation_SSB]
        FROM    #Output
        ORDER BY CASE WHEN Source = 'No Referral Data' THEN 2
                      ELSE 1
                 END
              , Qty DESC	




--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_ReferralLocation_SSB]

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - ReferralLocationExit'

    END






GO
