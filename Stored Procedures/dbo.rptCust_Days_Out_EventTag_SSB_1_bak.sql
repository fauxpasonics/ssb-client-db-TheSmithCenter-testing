SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/*
EXEC dbo.rptCust_Days_Out_EventTag_SSB_1 @Season = 'LVP1415', -- varchar(25)
    @EventType = 'PCLS', -- varchar(128)
    @EventTag = 'RESCO', -- varchar(25)
	@Venue = 'LHM' -- varchar(25)
*/



create PROCEDURE [dbo].[rptCust_Days_Out_EventTag_SSB_1_bak]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @EventTag VARCHAR(500)
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



        SELECT  evt.SeasonCode
              , evt.EventCode
              , t.Item
        INTO    #Tags
        FROM    vTK_Event_SSB evt
                CROSS APPLY dbo.Split(evt.Tags, ' ') AS t
        ORDER BY evt.SeasonCode
              , evt.EventCode
	
        SELECT  meo.SeasonCode
              , metype.EventTypeFullName
              , meo.EventCode
              , MAX(mevt.EventDate) AS MaxDate
              , MIN(meo.TranDate) AS MinDate
        INTO    #SeasonEgroups
        FROM    DW_EventTransOrigSales (NOLOCK) meo
                INNER JOIN vTK_Event_SSB mevt ON mevt.SeasonCode = meo.SeasonCode
                                             AND mevt.EventCode = meo.EventCode
                INNER JOIN vTK_EventType metype ON metype.EventTypeCode = mevt.EventTypeCode
        GROUP BY meo.SeasonCode
              , meo.EventCode
              , metype.EventTypeFullName
	
	

        SELECT  ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7 AS 'EventAge'
              , sg.*
              , 'A' AS 'ValueType'
              , 0 AS 'Value'
        INTO    #DateAdd
        FROM    dbo.TI_DIMDATE dm
                INNER JOIN #SeasonEgroups sg ON sg.MinDate <= dm.calendarDate
                                                AND sg.MaxDate >= dm.calendarDate
        GROUP BY ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7
              , sg.SeasonCode
              , sg.EventCode
              , sg.EventTypeFullName
              , sg.MaxDate
              , sg.MinDate
        UNION ALL
        SELECT  ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7 AS 'EventAge'
              , sg.*
              , 'Q' AS 'ValueType'
              , 0 AS 'Value'
        FROM    dbo.TI_DIMDATE dm
                INNER JOIN #SeasonEgroups sg ON sg.MinDate <= dm.calendarDate
                                                AND sg.MaxDate >= dm.calendarDate
        GROUP BY ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7
              , sg.SeasonCode
              , sg.EventCode
              , sg.EventTypeFullName
              , sg.MaxDate
              , sg.MinDate

        SELECT  da.SeasonCode
              , da.EventCode
              , CASE WHEN da.ValueType = 'A' THEN 'Revenue'
                     ELSE 'Ticket Quantity'
                END AS 'ValueType'
              , da.EventTypeFullName
              , evt.EventTypeCode
              , CASE WHEN da.EventAge > 0 THEN da.EventAge
                     WHEN evt.EventDate IS NULL THEN da.EventAge
                     ELSE 0
                END AS 'EventAge'
              , da.MaxDate
              , da.MinDate
              , SUM(ISNULL(eo.Value, 0)) AS Value
              , evt.FacilityCode
        INTO    #Temp
        FROM    DW_EventTransOrigSales (NOLOCK) eo
                INNER JOIN vTK_Event_SSB (NOLOCK) evt ON evt.SeasonCode = eo.SeasonCode
                                                     AND evt.EventCode = eo.EventCode
                RIGHT OUTER JOIN #DateAdd da ON da.SeasonCode = eo.SeasonCode
                                                AND da.EventCode = evt.EventCode
                                                AND da.EventAge = ROUND(CASE
                                                              WHEN DATEDIFF(DAY,
                                                              eo.TranDate,
                                                              evt.EventGroupFirstDate) > 0
                                                              THEN DATEDIFF(DAY,
                                                              eo.TranDate,
                                                              evt.EventGroupFirstDate)
                                                              ELSE 0
                                                              END / 7, 0) * 7
                                                AND da.ValueType = eo.ValueType
        GROUP BY da.SeasonCode
              , da.EventCode
              , CASE WHEN da.ValueType = 'A' THEN 'Revenue'
                     ELSE 'Ticket Quantity'
                END
              , da.EventTypeFullName
              , CASE WHEN da.EventAge > 0 THEN da.EventAge
                     WHEN evt.EventDate IS NULL THEN da.EventAge
                     ELSE 0
                END
              , da.MaxDate
              , da.MinDate
              , evt.EventTypeCode
              , evt.FacilityCode
	
        SELECT  tmp.SeasonCode
              , tg.Item
              , tmp.ValueType
              , tmp.EventTypeFullName
              , tmp.EventAge
              , SUM(tmp.Value) AS Value
              , tmp.EventTypeCode
              , tmp.FacilityCode
        INTO    #TempTag
        FROM    #Temp tmp
                INNER JOIN #Tags tg ON tg.SeasonCode = tmp.SeasonCode
                                       AND tg.EventCode = tmp.EventCode
        GROUP BY tmp.SeasonCode
              , tg.Item
              , tmp.ValueType
              , tmp.EventTypeFullName
              , tmp.EventAge
              , tmp.EventTypeCode
              , tmp.FacilityCode


        SELECT  a.SeasonCode
              , sea.Season
              , RIGHT('0000' + CAST(a.EventAge AS VARCHAR(32)), 4) AS 'EventAge'
              , a.EventTypeFullName AS 'EventType'
              , a.Item
              , a.ValueType
              , a.Value AS 'Value'
              , SUM(b.Value) AS 'CumulativeValue'
			  , a.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS + a.Item COLLATE SQL_Latin1_General_CP1_CS_AS AS 'SeasonTagGroup'
        FROM    #TempTag a
              , #TempTag b
              , vTK_Season sea
        WHERE   sea.SeasonCode = a.SeasonCode
                AND a.SeasonCode = b.SeasonCode
                AND a.Item = b.Item
                AND a.ValueType = b.ValueType
                AND b.EventAge >= a.EventAge
                AND a.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
                AND a.EventTypeCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventType,','))
                AND a.Item COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventTag,','))
                AND a.FacilityCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
        GROUP BY a.SeasonCode
              , sea.Season
              , a.EventAge
              , a.EventTypeFullName
              , a.ValueType
              , a.Value
              , a.Item
        ORDER BY a.SeasonCode
              , a.EventAge DESC
              , a.ValueType
              , a.Value

        DROP TABLE #Temp
        DROP TABLE #SeasonEgroups
        DROP TABLE #DateAdd
        DROP TABLE #Tags
        DROP TABLE #TempTag

    END








GO
