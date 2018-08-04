SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
EXEC dbo.rptCust_Days_Out_EventTag_SSB_2_3 @Season = 'LVP1415', -- varchar(25)
    @EventType = 'PCLS', -- varchar(128)
    @EventTag = 'RESCO', -- varchar(25)
	@Venue = 'LHM' -- varchar(25)
*/


create PROCEDURE [dbo].[rptCust_Days_Out_EventTag_SSB_2_3_bak]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @EventTag VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON
		

--Event tag report for CUSTOM - Event Tag Days Out Report

        SELECT  evt.SeasonCode
              , evt.EventCode
              , t.Item
        INTO    #Tags
        FROM    vTK_Event_SSB evt
                CROSS APPLY dbo.Split(evt.Tags, ' ') AS t
        ORDER BY evt.SeasonCode
              , evt.EventCode

        SELECT  dts.SeasonCode
              , sea.Season
              , et.EventTypeFullName AS 'EventType'
			  , et.EventTypeCode
              , dts.EventCode
              , evt.EventTimeAsText AS 'EventTime'
              , dts.TranDate
              , dts.ValueType
              , SUM(dts.Value) AS 'Value'
			  , evt.FacilityCode
        INTO    #Summary
        FROM    vDW_EventTransSummary dts
                INNER JOIN vTK_Event_SSB evt ON evt.SeasonCode = dts.SeasonCode
                                            AND evt.EventCode = dts.EventCode
                INNER JOIN vTK_Season sea ON sea.SeasonCode = dts.SeasonCode
                INNER JOIN vTK_EventType et ON et.EventTypeCode = evt.EventTypeCode
        GROUP BY dts.SeasonCode
              , sea.Season
              , dts.EventCode
              , dts.TranDate
              , dts.ValueType
              , et.EventTypeFullName
			  , et.EventTypeCode
              , evt.EventTimeAsText
			  , evt.FacilityCode

        SELECT  cm.SeasonCode
              , cm.Season
              , cm.EventType
              , cm.TranDate
              , DATENAME(dw, cm.TranDate) AS 'DayOfWeek'
              , cm.EventTime
              , CASE WHEN cm.ValueType = 'A' THEN 'Revenue'
                     ELSE 'Ticket Quantity'
                END AS 'ValueType'
              , tg.Item AS 'Tag'
              , SUM(cm.Value) AS 'Value'
			  , cm.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS + tg.Item COLLATE SQL_Latin1_General_CP1_CS_AS AS 'SeasonTagGroup'
        FROM    #Summary cm
                INNER JOIN #Tags tg ON tg.SeasonCode = cm.SeasonCode
                                       AND tg.EventCode = cm.EventCode
        WHERE   cm.SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
                AND cm.EventTypeCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventType,','))
                AND tg.Item COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventTag,','))
				AND cm.FacilityCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
        GROUP BY cm.SeasonCode
              , cm.Season
              , cm.EventType
              , cm.ValueType
              , tg.Item
              , cm.TranDate
              , cm.EventTime

        DROP TABLE #Summary
        DROP TABLE #Tags

    END



GO
