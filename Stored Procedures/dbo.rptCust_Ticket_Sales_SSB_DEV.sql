SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[rptCust_Ticket_Sales_SSB_DEV]
AS
    BEGIN


	--exec [dbo].[rptCust_Ticket_Sales_SSB] '01/20/2016', '7/1/2015','7/1/2016'

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        DECLARE @DATE AS VARCHAR(20) = '2016-01-20'
--DECLARE @DATECHECK as varchar(20)
--DECLARE @DATENATIVE as datetime
        DECLARE @FISCALSTART AS VARCHAR(20) = '2015-07-01'
        DECLARE @FISCALEND AS VARCHAR(20) = '2016-06-30'

--SET @DATENATIVE = Date  --Optional parameter for a date cutoff

--SET @FISCALSTART = Convert(varchar(4),DATEPART(yyyy,FiscalStart)) + '-' + Convert(varchar(2),DATEPART(MM,FiscalStart)) + '-' + Convert(varchar(2),DATEPART(dd,FiscalStart))
--SET @FISCALEND = Convert(varchar(4),DATEPART(yyyy,FiscalEnd)) + '-' + Convert(varchar(2),DATEPART(MM,FiscalEnd)) + '-' + Convert(varchar(2),DATEPART(dd,FiscalEnd))
--SET @DATE = Convert(varchar(4),DATEPART(yyyy,@DATENATIVE)) + '-' + Convert(varchar(2),DATEPART(MM,@DATENATIVE)) + '-' + Convert(varchar(2),DATEPART(dd,@DATENATIVE))

--IF @DATE = Convert(varchar(4),DATEPART(yyyy,GETDATE())) + '-' + Convert(varchar(2),DATEPART(MM,GETDATE())) + '-' + Convert(varchar(2),DATEPART(dd,GETDATE()))
--   SET @DATE = Convert(varchar(4),DATEPART(yyyy,GETDATE()-1)) + '-' + Convert(varchar(2),DATEPART(MM,GETDATE()-1)) + '-' + Convert(varchar(2),DATEPART(dd,GETDATE()-1))
--ELSE
--  SET @DATE = Convert(varchar(4),DATEPART(yyyy,@DATENATIVE)) + '-' + Convert(varchar(2),DATEPART(MM,@DATENATIVE)) + '-' + Convert(varchar(2),DATEPART(dd,@DATENATIVE))



---------------------------------------------------------------------------------
        CREATE TABLE #TSCWEEKMONTH
            (
              SEASON VARCHAR(15)
            , EVENT VARCHAR(32)
            , EGROUP VARCHAR(32)
            , DATE DATETIME
            , WEEKDAY VARCHAR(15)
            , MAXDATE DATETIME
            )

        INSERT  INTO #TSCWEEKMONTH
                SELECT DISTINCT
                        tkEvent.SEASON
                      , tkEvent.EVENT
                      , tkEvent.EGROUP
                      , tkEvent.DATE
                      , CASE WHEN ( DATEPART(iso_week, tkEvent.DATE) = '1'
                                    OR DATEPART(iso_week, tkEvent.DATE) = '53'
                                  )
                                  AND MONTH(tkEvent.DATE) = '12'
                             THEN +DATEPART(iso_week, tkEvent.DATE)
                                  + ( ( DATEPART(yyyy, tkEvent.DATE) + 1 )
                                      * 100 )
                             ELSE DATEPART(iso_week, tkEvent.DATE)
                                  + ( DATEPART(yyyy, tkEvent.DATE) * 100 )
                        END AS WeekDay
                      , ( SELECT    MAX(tkEvent2.DATE)
                          FROM      dbo.TK_EVENT tkEvent2
                          WHERE     ( CASE WHEN ( DATEPART(iso_week,
                                                           tkEvent.DATE) = '1'
                                                  OR DATEPART(iso_week,
                                                              tkEvent.DATE) = '53'
                                                )
                                                AND MONTH(tkEvent.DATE) = '12'
                                           THEN +DATEPART(iso_week,
                                                          tkEvent.DATE)
                                                + ( ( DATEPART(yyyy,
                                                              tkEvent.DATE)
                                                      + 1 ) * 100 )
                                           ELSE DATEPART(iso_week,
                                                         tkEvent.DATE)
                                                + ( DATEPART(yyyy,
                                                             tkEvent.DATE)
                                                    * 100 )
                                      END = CASE WHEN ( DATEPART(iso_week,
                                                              tkEvent2.DATE) = '1'
                                                        OR DATEPART(iso_week,
                                                              tkEvent2.DATE) = '53'
                                                      )
                                                      AND MONTH(tkEvent2.DATE) = '12'
                                                 THEN +DATEPART(iso_week,
                                                              tkEvent2.DATE)
                                                      + ( ( DATEPART(yyyy,
                                                              tkEvent2.DATE)
                                                            + 1 ) * 100 )
                                                 ELSE DATEPART(iso_week,
                                                              tkEvent2.DATE)
                                                      + ( DATEPART(yyyy,
                                                              tkEvent2.DATE)
                                                          * 100 )
                                            END )
                                    AND tkEvent2.EGROUP = tkEvent.EGROUP
                                    AND tkEvent2.SEASON = tkEvent.SEASON
                        ) AS MaxDate
                FROM    dbo.TK_EVENT tkEvent WITH ( NOLOCK )
                ORDER BY WeekDay

-------------------------------------------------------------------------------

        SELECT  trans.ETLSID
              , trans.SEASON
              , trans.TRANS_NO
              , trans.VMC
              , trans.SVMC
              , trans.EVENT
              , trans.E_PL
              , trans.E_PRICE
              , trans.E_DAMT
              , trans.E_PQTY
              , trans.E_VQTY
              , trans.E_PTT_QTY
              , trans.E_PTF_QTY
              , trans.E_ITEM
              , trans.E_OQTY
              , trans.E_CQTY
              , trans.E_OTT_QTY
              , trans.E_OTF_QTY
              , trans.E_OQTY_TOT
              , trans.E_PT
              , trans.E_STAT
              , trans.E_CPRICE
              , trans.E_FEE
              , trans.E_FPRICE
              , trans.TOTAL_EPAY
              , trans.TOTAL_CPAY
              , trans.TOTAL_FPAY
              , trans.SALECODE
              , trans.E_SCAMT
              , trans.TOTAL_SPAY
              , trans.DATE
              , trans.CUSTOMER
              , trans.ZID
              , trans.SOURCE_ID
              , trans.EXPORT_DATETIME
              , tscWeekMonth.EGROUP
              , tscWeekMonth.DATE tscWeekMonthDate
              , tscWeekMonth.WEEKDAY
              , tscWeekMonth.MAXDATE
        INTO    #trans
        FROM    dbo.TK_TRANS_ITEM_EVENT trans
                INNER JOIN #TSCWEEKMONTH tscWeekMonth ON ( tscWeekMonth.SEASON COLLATE SQL_Latin1_General_CP1_CI_AS = trans.SEASON
                                                           AND tscWeekMonth.EVENT COLLATE SQL_Latin1_General_CP1_CI_AS = trans.EVENT
                                                         )
        WHERE   trans.SALECODE <> 'SH'
                AND trans.DATE <= @DATE
                AND tscWeekMonth.MAXDATE <= @DATE
                AND ( tscWeekMonth.MAXDATE >= @FISCALSTART
                      AND tscWeekMonth.MAXDATE <= @FISCALEND
                    )

        SELECT DISTINCT
                trans.SEASON AS SeasonCode
              , event.EGROUP AS EventGroup
              , tkEGroup.NAME AS EventGroupName
              , trans.EVENT AS EventCode
              , event.NAME AS EventName
              , event.DATE AS EventDate
              , DimDate.calendarMonthName AS EventMonth
              , event.TIME AS EventTime
              , event.ETYPE AS EventType
              , etype.NAME AS ETypeName
              , event.TAG AS EventTag
			  , event.EGROUP + '-' + DimDate.calendarMonthName COLLATE SQL_Latin1_General_CP1_CI_AS AS EventMonthGroup 
              , CASE WHEN event.TAG LIKE '%BWAY%' THEN 'Broadway Performances'
                     WHEN event.TAG LIKE '%HOUSE%' THEN 'House Presentations'
                     WHEN event.TAG LIKE '%RESCO%' THEN 'Resident Companies'
                     WHEN event.TAG LIKE '%4WALL%' THEN 'Rentals'
                     ELSE 'Uncategorized'
                END AS EventTagGrouping
              , facility.FACILITY AS Facility
              , facility.NAME AS FacName --Venue
              , SUM(CASE WHEN NOT ( ISNULL(prtype.CLASS, 'GREG') IN ( 'CNS',
                                                              'CMP' ) )
                         THEN trans.E_OQTY_TOT
                         ELSE '0'
                    END) AS PaidQty
	--,SUM(CASE WHEN IsNull(prtype.CLASS,'GREG') = 'CMP' THEN trans.E_OQTY_TOT Else '0' END) as CompQty
	--,SUM(CASE WHEN IsNull(prtype.CLASS,'GREG') = 'CNS' THEN trans.E_OQTY_TOT ELSE '0' END) as ConsignQty
              , SUM(trans.E_OQTY_TOT) AS TotalQty
              , SUM(CASE WHEN NOT ( prtype.CLASS IN ( 'CNS', 'CMP' ) )
                         THEN ( trans.E_OQTY_TOT * trans.E_PRICE )
                         ELSE '0'
                    END) AS Value --Ticket Revenue
              , event.CAPACITY AS Capacity
              , ( CASE WHEN event.ETYPE IN ( 'PREN', 'BREN' )
                       THEN ( SELECT    SUM(trans2.E_OQTY_TOT)
                              FROM      dbo.TK_TRANS_ITEM_EVENT trans2
                              WHERE     trans.SEASON = trans2.SEASON
                                        AND trans.EVENT = trans2.EVENT
                            )
                       ELSE ( SELECT    COUNT(bc.ATTENDED)
                              FROM      dbo.TK_BC bc
                                        INNER JOIN dbo.TK_PRTYPE prtype ON ( prtype.PRTYPE = bc.I_PT
                                                              AND prtype.SEASON = bc.SEASON
                                                              )
                              WHERE     bc.SEASON = trans.SEASON
                                        AND bc.EVENT = trans.EVENT
                                        AND bc.ATTENDED = 'Y'
                            )
                  END ) AS Attendance
              , trans.MAXDATE AS MaxDate
        FROM    #trans trans WITH ( NOLOCK )
                INNER JOIN dbo.TK_EVENT event WITH ( NOLOCK ) ON ( trans.SEASON = event.SEASON
                                                              AND trans.EVENT = event.EVENT
                                                              )
                INNER JOIN dbo.TK_ETYPE etype WITH ( NOLOCK ) ON ( etype.ETYPE = event.ETYPE )
                INNER JOIN dbo.TK_FACILITY facility WITH ( NOLOCK ) ON ( event.FACILITY = facility.FACILITY )
                INNER JOIN dbo.TK_PRTYPE prtype WITH ( NOLOCK ) ON ( prtype.SEASON = trans.SEASON
                                                              AND prtype.PRTYPE = trans.E_PT
                                                              )
                INNER JOIN dbo.TK_EGROUP tkEGroup WITH ( NOLOCK ) ON tkEGroup.EGROUP = event.EGROUP
                                                              AND tkEGroup.SEASON = trans.SEASON
                INNER JOIN dbo.TI_DIMDATE DimDate WITH ( NOLOCK ) ON DimDate.calendarDate = event.DATE
                --INNER JOIN #TSCWEEKMONTH tscWeekMonth ON ( tscWeekMonth.SEASON COLLATE SQL_Latin1_General_CP1_CI_AS = trans.SEASON
                --                                              AND tscWeekMonth.EVENT COLLATE SQL_Latin1_General_CP1_CI_AS = trans.EVENT
                --                                              )
        WHERE   ISNULL(prtype.KIND, 'F') <> 'H'
                --AND trans.SALECODE <> 'SH'
                --AND trans.DATE <= @DATE
                --AND tscWeekMonth.MAXDATE <= @DATE
                --AND ( tscWeekMonth.MAXDATE >= @FISCALSTART
                --      AND tscWeekMonth.MAXDATE <= @FISCALEND
                --    )
                AND ( PATINDEX('% ' + 'BWAY' + ' %', ' ' + event.TAG + ' ') > 0
                      OR PATINDEX('% ' + 'HOUSE' + ' %', ' ' + event.TAG + ' ') > 0
                      OR PATINDEX('% ' + 'RESCO' + ' %', ' ' + event.TAG + ' ') > 0
                      OR PATINDEX('% ' + '4WALL' + ' %', ' ' + event.TAG + ' ') > 0
                    )
					--AND Event.EGROUP IN ('CLH','BOM')
        GROUP BY trans.SEASON
              , trans.EVENT
              , event.NAME
              , event.ETYPE
              , etype.NAME
              , event.TAG
              , event.DATE
              , facility.FACILITY
              , facility.NAME
              , event.CAPACITY
              , event.DATE
              , event.TIME
              , trans.MAXDATE
              , event.EGROUP
              , tkEGroup.NAME
              , DimDate.calendarMonthName
        ORDER BY event.DATE
              , event.TIME
/*
DROP TABLE #TSCWEEKMONTH
DROP TABLE #trans
*/
--403

    END

GO
