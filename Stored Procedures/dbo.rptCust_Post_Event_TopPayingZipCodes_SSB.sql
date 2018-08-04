SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*
EXEC dbo.rptCust_Post_Event_TopPayingZipCodes_SSB  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_TopPayingZipCodes_SSB]
    @TYPE AS VARCHAR(2)
  , @GROUPING AS VARCHAR(500)
  , @Season AS VARCHAR(15)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON


--DECLARE @TYPE AS VARCHAR(2) = 'EV'
--DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
--DECLARE @Season AS VARCHAR(15) = 'TSC1415'
INSERT  [dbo].[TempVariableTrap]
SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
        + '|'
        , GETDATE()
        , 'PostEvent - TopPayingZipCodesEnter'

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

CREATE TABLE #zipLookUp
(
zipFull VARCHAR(32) COLLATE SQL_Latin1_General_CP1_CS_AS
, zipCode VARCHAR(32) COLLATE SQL_Latin1_General_CP1_CS_AS
)

INSERT  INTO #zipLookUp
( zipFull
, zipCode
)
SELECT DISTINCT
        pdAdd.SYS_ZIP AS zipFull
        , CASE WHEN CHARINDEX('-', pdAdd.SYS_ZIP) > 0
                THEN SUBSTRING(pdAdd.SYS_ZIP, 1,
                            ( CHARINDEX('-', pdAdd.SYS_ZIP)
                                - 1 ))
                ELSE pdAdd.SYS_ZIP
        END zipCode
FROM    dbo.PD_ADDRESS pdAdd WITH ( NOLOCK )

-------------------------------------------------------------------

CREATE TABLE #orderedHH
(
customer VARCHAR(20)
, quantity BIGINT
, value DECIMAL(18, 2)
, price DECIMAL(18, 2)
)

INSERT  INTO #orderedHH
( customer
, price
, quantity
, value
)
SELECT  trans.CUSTOMER
        , trans.E_PRICE
        , SUM(trans.E_OQTY_TOT) AS Qty
        , SUM(( trans.E_PRICE + trans.E_CPRICE
                + trans.E_FPRICE )
            * trans.E_OQTY_TOT) AS value
FROM    dbo.TK_TRANS_ITEM_EVENT trans WITH ( NOLOCK )
INNER JOIN dbo.TK_EVENT tkEvent WITH ( NOLOCK ) ON ( trans.SEASON = tkEvent.SEASON
    AND trans.EVENT = tkEvent.EVENT
    )
INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
    AND prtype.PRTYPE = trans.E_PT
    )
INNER JOIN dbo.TK_CUSTOMER tkCustomer WITH ( NOLOCK ) 
	ON ( tkCustomer.CUSTOMER = trans.CUSTOMER )
INNER JOIN #SeasonTemp st
	ON trans.SEASON = st.Item
WHERE   tkCustomer.TYPE <> 'H'
        AND prtype.PRTYPE <> 'SH' AND prtype.KIND <> 'H'
        AND trans.E_PRICE > 0
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
        , trans.E_PRICE


-------------------------------------------------------------------

SELECT  *
        , CASE WHEN RANK() OVER ( ORDER BY Amount ) BETWEEN 1 AND 5
                THEN CAST(RANK() OVER ( ORDER BY Amount ) AS VARCHAR)
                ELSE 'Other'
        END AS AmountRank
FROM    
(
	SELECT    zip.zipCode
            , SUBSTRING(sysZip.CSZ, 1,
                        CHARINDEX(',', sysZip.CSZ) + 3) AS City
            , COUNT(DISTINCT oHH.customer) AS HH
            , SUM(oHH.quantity) AS Tickets
            , SUM(oHH.value) AS Amount
            , ROUND(AVG(oHH.price), 2) AS AvgPrice
            , CAST(COUNT(DISTINCT oHH.customer) AS DECIMAL)
                    / ( SELECT    COUNT(DISTINCT customer)
                        FROM      #orderedHH
                    ) AS HH_Percent
--INTO [dbo].[TEMP_rptCust_Post_Event_TopPayingZipCodes_SSB]
    FROM      PD_ADDRESS pdAdd WITH ( NOLOCK )
            INNER JOIN #orderedHH oHH ON pdAdd.PATRON = oHH.customer
            INNER JOIN #zipLookUp zip ON pdAdd.SYS_ZIP = zip.zipFull
            INNER JOIN dbo.SYS_ZIP sysZip WITH ( NOLOCK ) ON zip.zipCode = sysZip.SYS_ZIP
    WHERE     pdAdd.ADTYPE = 'H'
    GROUP BY  zip.zipCode
            , sysZip.CSZ
) x
ORDER BY Amount DESC


DROP TABLE #orderedHH
DROP TABLE #zipLookUp



--SELECT  *
--FROM    [dbo].[TEMP_rptCust_Post_Event_TopPayingZipCodes_SSB]


INSERT  [dbo].[TempVariableTrap]
        SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                + '|'
                , GETDATE()
                , 'PostEvent - TopPayingZipCodesExit'

    END





GO
