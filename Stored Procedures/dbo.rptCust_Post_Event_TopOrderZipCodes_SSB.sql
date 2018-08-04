SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
EXEC dbo.rptCust_Post_Event_TopOrderZipCodes_SSB  @TYPE = 'ET', -- varchar(2)
    @GROUPING = 'BWAY', -- varchar(25)
    @Season = 'TSC1415' -- varchar(15)
*/


CREATE PROCEDURE [dbo].[rptCust_Post_Event_TopOrderZipCodes_SSB]
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
                , 'PostEvent - TopOrderZipCodesEnter'

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

--DECLARE @TYPE AS VARCHAR(2) = 'EV'
--DECLARE @GROUPING AS VARCHAR(500) = 'R0430'
--DECLARE @Season AS VARCHAR(15) = 'TSC1415'

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
, orders BIGINT
, quantity BIGINT
, value DECIMAL(18, 2)
)

INSERT  INTO #orderedHH
( customer
, orders
, quantity
, value
)
SELECT  trans.CUSTOMER
        , SUM(CASE WHEN trans.E_OQTY > 0 THEN 1
                    ELSE 0
            END) AS Orders
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
HAVING  SUM(trans.E_OQTY_TOT) > 0

-------------------------------------------------------------------

SELECT TOP 5
        zip.zipCode
        , SUBSTRING(sysZip.CSZ, 1, CHARINDEX(',', sysZip.CSZ) + 3) AS City
        , COUNT(oHH.customer) AS HH
        , SUM(oHH.orders) AS Orders
        , SUM(oHH.quantity) AS Tickets
        , SUM(oHH.value) AS Amount
        , CAST(CAST(SUM(oHH.quantity) AS FLOAT)
        / CAST(SUM(oHH.orders) AS FLOAT) AS DECIMAL(18, 2)) AS AverageOrderSize
        , CAST(COUNT(oHH.customer) AS DECIMAL) / ( SELECT
                                                        COUNT(customer)
                                                        FROM
                                                        #orderedHH
                                                        ) AS HH_Percent
--		INTO [dbo].[TEMP_rptCust_Post_Event_TopOrderZipCodes_SSB]
FROM    PD_ADDRESS pdAdd
INNER JOIN #orderedHH oHH ON pdAdd.PATRON = oHH.customer
INNER JOIN #zipLookUp zip ON pdAdd.SYS_ZIP = zip.zipFull
INNER JOIN dbo.SYS_ZIP sysZip ON zip.zipCode = sysZip.SYS_ZIP
WHERE   pdAdd.ADTYPE = 'H'
GROUP BY zip.zipCode
        , sysZip.CSZ
ORDER BY SUM(oHH.orders) DESC

DROP TABLE #orderedHH
DROP TABLE #zipLookUp



--SELECT * FROM [dbo].[TEMP_rptCust_Post_Event_TopOrderZipCodes_SSB]

        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @TYPE + '|' + @GROUPING + '|'
                        + '|'
                      , GETDATE()
                      , 'PostEvent - TopOrderZipCodesExit'

    END




GO
