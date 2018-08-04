SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rptCust_Post_Event_Region_SSB]
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
                      , 'PostEvent - RegionEnter'

        --DECLARE @TYPE AS VARCHAR(2) = 'EV'
        --DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
        --DECLARE @Season AS VARCHAR(15) = 'TSC1415'
----------------------------------------------------------



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


CREATE TABLE #AdType
    (
        ORDERREC INTEGER
    , ADTYPE VARCHAR(16)
    , TYPECOUNT INTEGER
    )

INSERT  INTO #AdType
        ( ORDERREC
        , ADTYPE
        , TYPECOUNT
        )
        SELECT DISTINCT
                ROW_NUMBER() OVER ( ORDER BY COUNT(ADTYPE) DESC ) AS number
                , ADTYPE
                , COUNT(ADTYPE)
        FROM    dbo.PD_ADDRESS WITH ( NOLOCK )
        GROUP BY ADTYPE
        ORDER BY COUNT(ADTYPE) DESC
---------------------------------------------------------------
CREATE TABLE #TSCORDERS
(
CUSTOMER VARCHAR(20)
, QTY INTEGER
, VALUE DECIMAL(18, 2)
)

INSERT  INTO #TSCORDERS
( CUSTOMER
, QTY
, VALUE
)
SELECT  trans.CUSTOMER
        , SUM(trans.E_OQTY_TOT) AS Qty
        , SUM(trans.E_OQTY_TOT * trans.E_PRICE) AS Value
FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
INNER JOIN dbo.TK_EVENT tkEvent WITH ( NOLOCK ) ON ( trans.SEASON = tkEvent.SEASON
    AND trans.EVENT = tkEvent.EVENT
    )
INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
    AND prtype.PRTYPE = trans.E_PT
    )
INNER JOIN #SeasonTemp st
	ON trans.SEASON = st.Item
WHERE   ISNULL(prtype.KIND, 'GREG') <> 'H'
        AND prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
        AND ( ( @TYPE = 'EG'
                AND tkEvent.EGROUP IN ( SELECT
                                                Item
                                        FROM  #GroupingTemp )
                )
                OR ( @TYPE = 'EY'
                    AND tkEvent.ETYPE IN ( SELECT
                                                Item
                                            FROM
                                                #GroupingTemp )
                    )
                OR ( @TYPE = 'EV'
                    AND tkEvent.EVENT IN ( SELECT
                                                Item
                                            FROM
                                                #GroupingTemp )
                    )
                OR ( @TYPE = 'EC'
                    AND tkEvent.CLASS IN ( SELECT
                                                Item
                                            FROM
                                                #GroupingTemp )
                    )
                OR ( @TYPE = 'ET'
                    AND TAG IN ( SELECT  TAG
                                FROM    #tagtemp )
                    )
            )
GROUP BY trans.CUSTOMER
HAVING  SUM(trans.E_OQTY_TOT) > 0

---------------------------------------------------------------
SELECT DISTINCT
        tscOrders.CUSTOMER
        , ISNULL(pdAdd.ADTYPE, 'No Address') AS ADTYPE
        , ISNULL(adtype.ORDERREC, '1000') AS ORDERREC
        , ISNULL(pdAdd.SYS_ZIP, 'No Zip Code') AS SYS_ZIP
        , ISNULL(LEFT(pdAdd.SYS_ZIP, 5), 'No Zip Code') AS SYS_ZIP5
        , ISNULL(region.REGION, 'No Region') AS Region
        , tscOrders.QTY
        , tscOrders.VALUE
INTO    #Output
FROM    #TSCORDERS tscOrders
LEFT OUTER JOIN dbo.PD_ADDRESS pdAdd WITH ( NOLOCK ) ON ( pdAdd.PATRON = tscOrders.CUSTOMER
    AND ISNULL(pdAdd.SYS_ZIP,
    'GREG') <> 'GREG'
    )
LEFT OUTER JOIN #AdType adtype WITH ( NOLOCK ) ON ( adtype.ADTYPE COLLATE SQL_Latin1_General_CP1_CS_AS = ISNULL(pdAdd.ADTYPE,
    'H') )
LEFT OUTER JOIN dbo.TK_REGION_ZIP region WITH ( NOLOCK ) ON ( region.ZIP = LEFT(SYS_ZIP,
    5) )
WHERE   adtype.ORDERREC = ISNULL(( SELECT   MIN(ORDERREC)
                                    FROM     #AdType ad2
                                            LEFT OUTER JOIN dbo.PD_ADDRESS pd ON ( pd.ADTYPE COLLATE SQL_Latin1_General_CP1_CI_AS = ad2.ADTYPE )
                                    WHERE    pd.PATRON = tscOrders.CUSTOMER
                                            AND ISNULL(pd.SYS_ZIP,
                                                        'GREG') <> 'GREG'
                                    ), '1')

SELECT  x.GroupingTag
        , x.GroupingTagSort
        , x.Patrons
        , CAST(x.Patrons AS NUMERIC(18, 2))
        / CAST(SUM(x.Patrons) OVER ( ) AS NUMERIC(18, 2)) AS Pct_Patrons
        , x.Quantity
        , CAST(x.Quantity AS NUMERIC(18, 2))
        / CAST(SUM(x.Quantity) OVER ( ) AS NUMERIC(18, 2)) AS Pct_Quantity
        , x.Value
        , x.Value / SUM(x.Value) OVER ( ) AS Pct_Value
INTO    #Results
FROM    ( SELECT    z.GroupingTag
                    , z.GroupingTagSort
                    , COUNT(z.CUSTOMER) AS Patrons
                    , SUM(z.QTY) AS Quantity
                    , SUM(z.VALUE) AS Value
            FROM      ( SELECT    CUSTOMER, QTY, VALUE
                                , CASE WHEN ADTYPE = 'No Address'
                                        THEN 'Unknown Purchasers'
                                        WHEN SYS_ZIP = 'No Zip Code'
                                        THEN 'Unknown Purchasers'
                                        WHEN Region = 'L'
                                        THEN 'Local Purchasers'
                                        WHEN Region <> 'L'
                                        THEN 'Non-Local Purchasers'
                                END AS GroupingTag
                                , CASE WHEN ADTYPE = 'No Address' THEN 3
                                        WHEN SYS_ZIP = 'No Zip Code'
                                        THEN 3
                                        WHEN Region = 'L' THEN 1
                                        WHEN Region <> 'L' THEN 2
                                END AS GroupingTagSort
                        FROM      #Output
                    ) z
            GROUP BY  GroupingTag
                    , GroupingTagSort
        ) x
		
SELECT  *
--		INTO [dbo].[TEMP_rptCust_Post_Event_Region_SSB]
FROM    ( SELECT    *
            FROM      #Results
            UNION ALL
            SELECT    'TOTAL'
                    , 4
                    , SUM(Patrons)
                    , NULL
                    , SUM(Quantity)
                    , NULL
                    , SUM(Value)
                    , NULL
            FROM      #Results
        ) y
ORDER BY y.GroupingTagSort


DROP TABLE #AdType
DROP TABLE #TSCORDERS
DROP TABLE #Output



--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_Region_SSB]


INSERT  [dbo].[TempVariableTrap]
        SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                + '|'
                , GETDATE()
                , 'PostEvent - RegionExit'


    END





GO
