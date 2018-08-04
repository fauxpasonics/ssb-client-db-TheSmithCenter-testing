SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[rptCust_Ticket_Sales_SSB_dev2] (@DATE DATETIME, @FISCALSTART DATETIME, @FISCALEND DATETIME)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--        DECLARE @DATE AS VARCHAR(20) = '2015-12-29'
--DECLARE @DATECHECK as varchar(20)
--DECLARE @DATENATIVE as datetime
--        DECLARE @FISCALSTART AS VARCHAR(20) = '2015-07-01'
--        DECLARE @FISCALEND AS VARCHAR(20) = '2016-06-30'

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


					select
					trans.SEASON,
					sum(trans.E_OQTY_TOT) E_OQTY_TOT,
					sum(trans.E_PRICE) E_PRICE,
					trans.E_PT,
					trans.Event,
					MaxDate
					into #trans
					from
					dbo.TK_TRANS_ITEM_EVENT trans
					INNER JOIN #TSCWEEKMONTH tscWeekMonth ON  tscWeekMonth.SEASON COLLATE SQL_Latin1_General_CP1_CI_AS = trans.SEASON
							                              AND tscWeekMonth.EVENT COLLATE SQL_Latin1_General_CP1_CI_AS = trans.EVENT					
					WHERE   trans.SALECODE <> 'SH'
					AND trans.DATE <= @DATE
					AND tscWeekMonth.MAXDATE <= @DATE
					AND ( tscWeekMonth.MAXDATE >= @FISCALSTART
                      AND tscWeekMonth.MAXDATE <= @FISCALEND)
					  group by trans.E_PT,trans.SEASON, trans.Event, tscWeekMonth.MAXDATE

					  
	
	SELECT att.* INTO  #attendance
	FROM
    (
					  SELECT    COUNT(*) ScanCount,Season,Event,'BC' AS RowType
                              FROM      dbo.TK_BC bc
                              WHERE     bc.ATTENDED = 'Y'						
							  GROUP BY season,event
							  UNION all
							  SELECT    SUM(trans2.E_OQTY_TOT), Season,Event,'TRANS' AS RowType
                              FROM      dbo.TK_TRANS_ITEM_EVENT trans2                              
									GROUP BY Season, Event
	) att					
	JOIN tk_event te ON att.Season = te.Season AND att.Event = te.Event
	WHERE (RowType = 'BC' AND NOT Etype IN ('PREN', 'BREN')) OR (RowType ='TRANS' and  Etype IN ('PREN', 'BREN'))
	


     SELECT 
                trans.SEASON AS SeasonCode
              , event.EGROUP AS EventGroup
              , tkEGroup.NAME AS EventGroupName
              , trans.EVENT AS EventCode
              , event.NAME AS EventName
              , event.DATE AS EventDate
              , DimDate.calendarMonthName + ' - ' + CAST(DimDate.calendarYearNum AS VARCHAR) AS EventMonth
              , event.TIME AS EventTime
              , event.ETYPE AS EventType
              , etype.NAME AS ETypeName
              , event.TAG AS EventTag
			  , event.EGROUP + '-' + DimDate.calendarMonthName COLLATE SQL_Latin1_General_CP1_CI_AS + '-' + CAST(DimDate.calendarYearNum AS VARCHAR) AS EventMonthGroup
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
			  , ScanCount AS Attendance
              /*, ( CASE WHEN event.ETYPE IN ( 'PREN', 'BREN' )
                       THEN ( SELECT    SUM(trans2.E_OQTY_TOT)
                              FROM      dbo.TK_TRANS_ITEM_EVENT trans2
                              WHERE     trans.SEASON = trans2.SEASON
                                        AND trans.EVENT = trans2.EVENT
                            )
                       ELSE ( SELECT    COUNT(bc.I_PT)
                              FROM      dbo.TK_BC bc
                                        INNER JOIN dbo.TK_PRTYPE prtype ON ( prtype.PRTYPE = bc.I_PT
                                                              AND prtype.SEASON = bc.SEASON
                                                              )
                              WHERE     bc.SEASON = trans.SEASON
                                        AND bc.EVENT = trans.EVENT
                                        AND bc.ATTENDED = 'Y'
                            )
                  END ) AS Attendance*/
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
				LEFT JOIN #attendance a ON a.Season = trans.Season AND a.Event = trans.Event 
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
			  , DimDate.calendarYearNum
			  ,ScanCount
        ORDER BY event.DATE
              , event.TIME
/*
DROP TABLE #TSCWEEKMONTH
DROP TABLE #trans
*/
--403

    END



GO
