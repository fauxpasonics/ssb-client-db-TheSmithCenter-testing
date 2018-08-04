SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
EXEC dbo.rptCust_Post_Event_Milestones_SSB  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/

CREATE PROCEDURE [dbo].[rptCust_Post_Event_PacingChart_SSB]
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
                      , 'PostEvent - PacingChartEnter'

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

DECLARE @MINDATE DATETIME
    , @MAXDATE DATETIME
    , @DATE DATETIME

SET @MINDATE = ( SELECT MIN(trans.DATE)
                    FROM   dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
                    INNER JOIN dbo.TK_EVENT ev WITH ( NOLOCK ) ON ( trans.SEASON = ev.SEASON
                        AND trans.EVENT = ev.EVENT
                        )
					INNER JOIN #SeasonTemp st
						ON trans.SEASON = st.Item
                    WHERE  ( ( @TYPE = 'EG'
                                AND ev.EGROUP IN ( SELECT
                                                        Item
                                                    FROM
                                                        #GroupingTemp )
                                )
                                OR ( @TYPE = 'EY'
                                    AND ev.ETYPE IN ( SELECT
                                                        Item
                                                        FROM
                                                        #GroupingTemp )
                                    )
                                OR ( @TYPE = 'EV'
                                    AND ev.EVENT IN ( SELECT
                                                        Item
                                                        FROM
                                                        #GroupingTemp )
                                    )
                                OR ( @TYPE = 'EC'
                                    AND ev.CLASS IN ( SELECT
                                                        Item
                                                        FROM
                                                        #GroupingTemp )
                                    )
                                OR ( @TYPE = 'ET'
                                    AND TAG IN ( SELECT
                                                        TAG
                                                FROM  #tagtemp )
                                    )
                            )
                    HAVING SUM(trans.E_OQTY_TOT) <> 0
                )
SET @DATE = @MINDATE
SET @MAXDATE = ( SELECT MAX(DATE)
                    FROM   dbo.TK_EVENT te WITH ( NOLOCK )
					INNER JOIN #SeasonTemp st
						ON te.SEASON = st.Item
                    WHERE   ( ( @TYPE = 'EG'
                                AND EGROUP IN ( SELECT
                                                        Item
                                                FROM  #GroupingTemp )
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
                                                FROM  #tagtemp )
                                    )
                            )
                )

CREATE TABLE #TSCDATES ( DATES DATETIME )

WHILE ( @DATE <= @MAXDATE )
    BEGIN
        INSERT  INTO #TSCDATES
                ( DATES )
        VALUES  ( @DATE )
        SELECT  @DATE = DATEADD(DAY, 1, @DATE)
    END

CREATE TABLE #TSCPACING
    (
        DATE DATETIME
    , QTY INTEGER
    )

INSERT  INTO #TSCPACING
        ( DATE
        , QTY
        )
        SELECT DISTINCT
                trans.DATE
                , SUM(trans.E_OQTY_TOT)
        FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
        INNER JOIN dbo.TK_EVENT ev WITH ( NOLOCK ) ON ( ev.SEASON = trans.SEASON
            AND ev.EVENT = trans.EVENT
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
                        AND ev.EGROUP IN ( SELECT   Item
                                            FROM     #GroupingTemp )
                        )
                        OR ( @TYPE = 'EY'
                            AND ev.ETYPE IN ( SELECT Item
                                                FROM   #GroupingTemp )
                            )
                        OR ( @TYPE = 'EV'
                            AND ev.EVENT IN ( SELECT Item
                                                FROM   #GroupingTemp )
                            )
                        OR ( @TYPE = 'EC'
                            AND ev.CLASS IN ( SELECT Item
                                                FROM   #GroupingTemp )
                            )
                        OR ( @TYPE = 'ET'
                            AND TAG IN ( SELECT  TAG
                                        FROM    #tagtemp )
                            )
                    )
        GROUP BY trans.DATE
        ORDER BY trans.DATE

SELECT  dte.DATES AS Date
        , 'Header' AS Header
        , ( SELECT    SUM(pac2.QTY)
            FROM      #TSCPACING pac2
            WHERE     pac2.DATE <= dte.DATES
        ) AS Qty
FROM    #TSCDATES dte
INNER JOIN #TSCPACING pac ON ( pac.DATE = dte.DATES )
ORDER BY dte.DATES ASC

DROP TABLE #TSCDATES
DROP TABLE #TSCPACING

INSERT  [dbo].[TempVariableTrap]
        SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                + '|'
                , GETDATE()
                , 'PostEvent - PacingChartExit'

END	



GO
