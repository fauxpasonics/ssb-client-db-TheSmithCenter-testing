SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
EXEC dbo.rptCust_Days_Out_EventGroup_SSB_1_Dev @Season = 'LVP1213', -- varchar(25)
    @EventType = 'PBUS', -- varchar(128)
    @EventGroup = 'SBS', -- varchar(25)
    @Venue = 'BUS' -- varchar(25)
*/



CREATE PROCEDURE [dbo].[rptCust_Days_Out_EventGroup_SSB_1]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @EventGroup VARCHAR(500)
  , @Venue VARCHAR(500)
    WITH RECOMPILE
AS
    BEGIN

	--	insert dbo.TempVariableTrap VALUES (@Season, @EventType, @EventGroup, @Venue,GETDATE() )
		
		

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

        IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
            DROP TABLE #Temp
	
        IF OBJECT_ID('tempdb..#SeasonEGroups') IS NOT NULL
            DROP TABLE #SeasonEGroups
	
        IF OBJECT_ID('tempdb..#DateAdd') IS NOT NULL
            DROP TABLE #DateAdd
	
	
        SELECT  *
        INTO    #Events
        FROM    vTK_Event_SSB evt
        WHERE   SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@Season, ',') )
                AND evt.EventTypeCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@EventType, ',') )
                AND evt.FacilityCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@Venue, ',') )
                AND evt.EventGroupCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@EventGroup, ',') )


        SELECT  meo.SeasonCode
              , metype.EventTypeFullName
              , metype.EventTypeCode
              , mevt.EventGroupCode AS 'EgroupCode'
              , mevt.EventCode AS 'EventCode'
              , MAX(mevt.EventDate) AS MaxDate
              , MIN(meo.TranDate) AS MinDate
              , mevt.FacilityCode
        INTO    #SeasonEgroups
        FROM    DW_EventTransOrigSales (NOLOCK) meo
                INNER JOIN #Events mevt ON mevt.SeasonCode = meo.SeasonCode
                                           AND mevt.EventCode = meo.EventCode
                INNER JOIN vTK_EventType metype ON metype.EventTypeCode = mevt.EventTypeCode
        GROUP BY meo.SeasonCode
              , mevt.EventGroupCode
              , mevt.EventDate
              , metype.EventTypeFullName
              , metype.EventTypeCode
              , mevt.EventCode
              , mevt.FacilityCode
	
        SELECT  ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7 AS 'EventAge'
              , sg.EgroupCode
              , sg.EventTypeFullName
              , sg.EventTypeCode
              , sg.EventCode
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
              , sg.EgroupCode
              , sg.EventTypeFullName
              , sg.EventTypeCode
              , sg.EventTypeCode
              , sg.MaxDate
              , sg.MinDate
              , sg.SeasonCode
              , sg.EventCode
              , sg.FacilityCode
        UNION ALL
        SELECT  ROUND(DATEDIFF(DAY, dm.calendarDate, sg.MaxDate) / 7, 0) * 7 AS 'EventAge'
              , sg.EgroupCode
              , sg.EventTypeFullName
              , sg.EventTypeCode
              , sg.EventCode
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
              , sg.EgroupCode
              , sg.EventTypeFullName
              , sg.EventTypeCode
              , sg.EventTypeCode
              , sg.MaxDate
              , sg.MinDate
              , sg.SeasonCode
              , sg.EventCode
              , sg.FacilityCode

        SELECT  da.SeasonCode
              , da.EgroupCode
              , CASE WHEN da.ValueType = 'A' THEN 'Revenue'
                     ELSE 'Ticket Quantity'
                END AS 'ValueType'
              , da.EventTypeFullName
              , da.EventTypeCode
              , CASE WHEN da.EventAge > 0 THEN da.EventAge
                     WHEN evt.EventDate IS NULL THEN da.EventAge
                     ELSE 0
                END AS 'EventAge'
              , SUM(ISNULL(eo.Value, 0)) AS Value
              , da.FacilityCode
        INTO    #Temp
        FROM    DW_EventTransOrigSales (NOLOCK) eo
                INNER JOIN dbo.TK_PRTYPE (NOLOCK) b ON b.PRTYPE = eo.PriceTypeCode AND b.SEASON = eo.SeasonCode
                INNER JOIN #Events (NOLOCK) evt ON evt.SeasonCode = eo.SeasonCode
                                                   AND evt.EventCode = eo.EventCode
                RIGHT OUTER JOIN #DateAdd da ON da.SeasonCode = eo.SeasonCode
                                                AND da.EgroupCode = ISNULL(evt.EventGroupCode,
                                                              '(none)')
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
                                                AND da.EventCode = eo.EventCode
        WHERE   ISNULL(b.KIND, '') <> 'C'
                AND ISNULL(b.CLASS, '') <> 'CNS'
        GROUP BY da.SeasonCode
              , da.EgroupCode
              , CASE WHEN da.ValueType = 'A' THEN 'Revenue'
                     ELSE 'Ticket Quantity'
                END
              , da.EventTypeFullName
              , da.EventTypeCode
              , CASE WHEN da.EventAge > 0 THEN da.EventAge
                     WHEN evt.EventDate IS NULL THEN da.EventAge
                     ELSE 0
                END
              , da.FacilityCode
	
        SELECT  a.SeasonCode
              , sea.Season
              , RIGHT('0000' + CAST(a.EventAge AS VARCHAR(32)), 4) AS 'EventAge'
              , a.EventTypeFullName AS 'EventType'
              , a.EgroupCode AS 'EventGroupCode'
              , egr.EventGroupFullName + ' (' + a.SeasonCode COLLATE SQL_Latin1_General_CP1_CI_AS
                + ')' AS 'EventGroup'
              , a.ValueType
              , a.Value AS 'Value'
              , SUM(b.Value) AS 'CommulativeValue'
              , a.FacilityCode
              , a.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS
                + a.EgroupCode COLLATE SQL_Latin1_General_CP1_CS_AS AS 'SeasonGroupCode'
        FROM    #Temp a
              , #Temp b
              , vTK_Season sea
              , vTK_EGroup egr
        WHERE   sea.SeasonCode = a.SeasonCode
                AND egr.SeasonCode = a.SeasonCode
                AND egr.EventGroupCode = a.EgroupCode
                AND a.SeasonCode = b.SeasonCode
                AND a.EgroupCode = b.EgroupCode
                AND a.ValueType = b.ValueType
                AND b.EventAge >= a.EventAge
                AND a.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@Season, ',') )
                AND a.EventTypeCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@EventType, ',') )
                AND a.EgroupCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@EventGroup, ',') )
                AND a.FacilityCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@Venue, ',') )
        GROUP BY a.SeasonCode
              , sea.Season
              , a.EventAge
              , a.EventTypeFullName
              , a.EgroupCode
              , a.ValueType
              , a.Value
              , egr.EventGroupFullName + ' (' + a.SeasonCode COLLATE SQL_Latin1_General_CP1_CI_AS
                + ')'
              , a.FacilityCode
        ORDER BY a.SeasonCode
              , a.EventAge DESC
              , a.EgroupCode
              , a.ValueType
              , a.Value

        DROP TABLE #Temp
        DROP TABLE #SeasonEgroups
        DROP TABLE #DateAdd

    END







GO
