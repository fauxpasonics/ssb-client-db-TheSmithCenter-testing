SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/*
EXEC dbo.rptCust_Days_Out_Event_SSB_1 @Season = 'CB2013', -- varchar(25)
    @EventType = 'CB', -- varchar(128)
    @Event = 'CC', -- varchar(25)
	@Venue = 'CB' -- varchar(25)

*/


CREATE PROCEDURE [dbo].[rptCust_Days_Out_Event_SSB_1_Bkp]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @Event VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

        IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
            DROP TABLE #Temp
	
        IF OBJECT_ID('tempdb..#SeasonEGroups') IS NOT NULL
            DROP TABLE #SeasonEGroups
	
        IF OBJECT_ID('tempdb..#DateAdd') IS NOT NULL
            DROP TABLE #DateAdd
	
        SELECT  meo.SeasonCode
              , metype.EventTypeFullName
              , metype.EventTypeCode
              , mevt.EventCode AS 'EventCode'
              , mevt.Event + ' (' + mevt.EventCode COLLATE Latin1_General_CI_AS
                + ')' AS 'Event'
              , mevt.EventDate AS MaxDate
              , MIN(meo.TranDate) AS MinDate
              , mevt.FacilityCode
        INTO    #SeasonEgroups
        FROM    DW_EventTransOrigSales (NOLOCK) meo
                INNER JOIN vTK_Event mevt ON mevt.SeasonCode = meo.SeasonCode
                                             AND mevt.EventCode = meo.EventCode
                INNER JOIN vTK_EventType metype ON metype.EventTypeCode = mevt.EventTypeCode
        GROUP BY meo.SeasonCode
              , mevt.EventCode
              , mevt.Event + ' (' + mevt.EventCode COLLATE Latin1_General_CI_AS
                + ')'
              , mevt.EventDate
              , metype.EventTypeFullName
              , metype.EventTypeCode
              , mevt.FacilityCode

	
        SELECT  ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7 AS 'EventAge'
              , sg.EventCode
              , sg.Event
              , sg.EventTypeFullName
              , sg.EventTypeCode
              , sg.MaxDate
              , sg.MinDate
              , sg.SeasonCode
              , 'A' AS 'ValueType'
              , 0 AS 'Value'
              , sg.FacilityCode
        INTO    #DateAdd
        FROM    dbo.TI_DIMDATE dm
                INNER JOIN #SeasonEgroups sg ON sg.MinDate <= dm.calendarDate
                                                AND sg.MaxDate >= dm.calendarDate
        GROUP BY ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7
              , sg.EventCode
              , sg.Event
              , sg.EventTypeFullName
              , sg.EventTypeCode
              , sg.MaxDate
              , sg.MinDate
              , sg.SeasonCode
              , sg.FacilityCode
        UNION ALL
        SELECT  ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7 AS 'EventAge'
              , sg.EventCode
              , sg.Event
              , sg.EventTypeFullName
              , sg.EventTypeCode
              , sg.MaxDate
              , sg.MinDate
              , sg.SeasonCode
              , 'Q' AS 'ValueType'
              , 0 AS 'Value'
              , sg.FacilityCode
        FROM    dbo.TI_DIMDATE dm
                INNER JOIN #SeasonEgroups sg ON sg.MinDate <= dm.calendarDate
                                                AND sg.MaxDate >= dm.calendarDate
        GROUP BY ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7
              , sg.EventCode
              , sg.Event
              , sg.EventTypeFullName
              , sg.EventTypeCode
              , sg.MaxDate
              , sg.MinDate
              , sg.SeasonCode
              , sg.FacilityCode


        SELECT  da.SeasonCode
              , da.EventCode
              , da.Event
              , CASE WHEN da.ValueType = 'A' THEN 'Revenue'
                     ELSE 'Ticket Quantity'
                END AS 'ValueType'
              , da.EventTypeFullName
              , da.EventTypeCode
              , CASE WHEN da.EventAge > 0 THEN da.EventAge
                     WHEN evt.EventDate IS NULL THEN da.EventAge
                     ELSE 0
                END AS 'EventAge'
              , da.MaxDate
              , da.MinDate
              , SUM(ISNULL(eo.Value, 0)) AS Value
              , da.FacilityCode
        INTO    #Temp
        FROM    DW_EventTransOrigSales (NOLOCK) eo
				INNER JOIN dbo.TK_PRTYPE (NOLOCK) b ON b.PRTYPE = eo.PriceTypeCode
                INNER JOIN vTK_Event (NOLOCK) evt ON evt.SeasonCode = eo.SeasonCode
                                                     AND evt.EventCode = eo.EventCode
                RIGHT OUTER JOIN #DateAdd da ON da.SeasonCode = eo.SeasonCode
                                                AND da.EventCode = evt.EventCode
                                                AND da.EventAge = ROUND(CASE
                                                              WHEN DATEDIFF(DAY,
                                                              eo.TranDate,
                                                              evt.EventDate) > 0
                                                              THEN DATEDIFF(DAY,
                                                              eo.TranDate,
                                                              evt.EventDate)
                                                              ELSE 0
                                                              END / 7, 0) * 7
                                                AND da.ValueType = eo.ValueType
		WHERE ISNULL(b.KIND, '') <> 'C' AND ISNULL(b.CLASS, '') <> 'CNS'
        GROUP BY da.SeasonCode
              , da.EventCode
              , da.Event
              , CASE WHEN da.ValueType = 'A' THEN 'Revenue'
                     ELSE 'Ticket Quantity'
                END
              , da.EventTypeFullName
              , da.EventTypeCode
              , CASE WHEN da.EventAge > 0 THEN da.EventAge
                     WHEN evt.EventDate IS NULL THEN da.EventAge
                     ELSE 0
                END
              , da.MaxDate
              , da.MinDate
              , da.FacilityCode

			  
	
        SELECT  a.SeasonCode
              , sea.Season
              , RIGHT('0000' + CAST(a.EventAge AS VARCHAR(32)), 4) AS 'EventAge'
              , a.EventTypeFullName AS 'EventType'
              , a.EventCode AS 'EventCode'
              , a.Event
              , a.MaxDate AS 'EventDate'
              , a.ValueType
              , a.Value AS 'Value'
              , SUM(b.Value) AS 'CommulativeValue'
              , a.FacilityCode
			  , a.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS + a.EventCode COLLATE SQL_Latin1_General_CP1_CS_AS AS 'SeasonEventGroup'
        FROM    #Temp a
              , #Temp b
              , vTK_Season sea
        WHERE   sea.SeasonCode = a.SeasonCode
                AND a.SeasonCode = b.SeasonCode
                AND a.EventCode = b.EventCode
                AND a.MaxDate = b.MaxDate
                AND a.ValueType = b.ValueType
                AND a.MinDate = b.MinDate
                AND b.EventAge >= a.EventAge
                AND a.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
                AND a.EventTypeCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@eventType,','))
                AND a.EventCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Event,','))
                AND a.FacilityCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
        GROUP BY a.SeasonCode
              , sea.Season
              , a.EventAge
              , a.EventTypeFullName
              , a.EventCode
              , a.Event
              , a.ValueType
              , a.Value
              , a.MaxDate
              , a.FacilityCode
        ORDER BY a.SeasonCode
              , a.EventAge DESC
              , a.EventCode
              , a.ValueType
              , a.Value

        DROP TABLE #Temp
        DROP TABLE #SeasonEgroups
        DROP TABLE #DateAdd

    END







GO
