SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
EXEC [dbo].[rptCust_Days_Out_EventGroup_SSB_2_3_Dev] @Season = 'LVP1213', -- varchar(25)
    @EventType = 'PBUS', -- varchar(128)
    @EventGroup = 'SBS', -- varchar(25)
    @Venue = 'BUS' -- varchar(25)
*/



--NBT1112
--NBT Dance
--STS
CREATE PROCEDURE [dbo].[rptCust_Days_Out_EventGroup_SSB_2_3_Dev]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @EventGroup VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

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

--Event group report for CUSTOM - Event Group Days Out Report

        SELECT  dts.SeasonCode
              , dts.EventCode
              , DATENAME(dw, dts.TranDate) AS 'DayOfWeek'
              , CASE WHEN dts.ValueType = 'A' THEN 'Revenue'
                     ELSE 'Ticket Quantity'
                END AS 'ValueType'
              , SUM(dts.Value) AS 'Value'
        INTO    #Temp
        FROM    vDW_EventTransSummary dts
        GROUP BY dts.SeasonCode
              , dts.EventCode
              , DATENAME(dw, dts.TranDate)
              , dts.ValueType

        SELECT  tp.SeasonCode
              , sea.Season AS 'Season'
              , et.EventTypeFullName AS 'EventType'
              , et.EventTypeCode
              , tp.EventCode
              , evt.Event + ' (' + tp.EventCode COLLATE Latin1_General_CI_AS
                + ')' AS 'Event'
              , evt.EventTimeAsText AS 'EventTime'
              , tp.DayOfWeek
              , tp.ValueType
              , tp.Value
              , evt.FacilityCode
        INTO    #Temp2
        FROM    #Temp tp
                INNER JOIN #Events evt ON evt.SeasonCode = tp.SeasonCode
                                          AND evt.EventCode = tp.EventCode
                INNER JOIN vTK_Season sea ON sea.SeasonCode = tp.SeasonCode
                INNER JOIN vTK_EventType et ON et.EventTypeCode = evt.EventTypeCode

        SELECT  tp.SeasonCode
              , tp.Season
              , tp.EventType
              , tp.EventCode
              , tp.Event
              , eg.EventGroupCode
              , eg.EventGroupFullName + ' (' + tp.SeasonCode COLLATE Latin1_General_CI_AS
                + ')' AS 'EventGroup'
              , tp.EventTime
              , tp.DayOfWeek
              , tp.ValueType
              , tp.Value
              , tp.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS
                + eg.EventGroupCode COLLATE SQL_Latin1_General_CP1_CS_AS AS 'SeasonGroupCode'
        FROM    #Temp2 tp
                INNER JOIN #Events evt ON evt.SeasonCode = tp.SeasonCode
                                          AND evt.EventCode = tp.EventCode
                INNER JOIN vTK_EGroup eg ON eg.SeasonCode = tp.SeasonCode
                                            AND eg.EventGroupCode = evt.EventGroupCode
        WHERE   tp.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@Season, ',') )
                AND tp.EventTypeCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@EventType, ',') )
                AND eg.EventGroupCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@EventGroup, ',') )
                AND tp.FacilityCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@Venue, ',') )

        DROP TABLE #Temp
        DROP TABLE #Temp2

    END



GO
