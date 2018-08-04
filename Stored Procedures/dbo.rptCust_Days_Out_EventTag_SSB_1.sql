SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
EXEC dbo.rptCust_Days_Out_EventTag_SSB_1_dev  @Season = 'LVP1516,LVP1314,LVP1415', -- varchar(25)
    @EventType = 'PCLS', -- varchar(128)
    @EventTag = 'RESCO', -- varchar(25)
	@Venue = 'LHM' -- varchar(25)
*/

/*
SELECT SUM(Value) FROM DW_EventTransOrigSales eo JOIN vTK_Event_SSB ve ON eo.SeasonCode = ve.SeasonCode
AND eo.EventCode = ve.EventCode
WHERE eo.SeasonCode = 'LVP1516'
AND EventTypeCode = 'PCLS'
*/
	
CREATE PROC [dbo].[rptCust_Days_Out_EventTag_SSB_1]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @EventTag VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN



        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @EventType + '|' + @EventTag + '|'
                        + @Venue
                      , GETDATE()
                      , 'Proc1Enter'



        SELECT  evt.SeasonCode
              , evt.EventCode
              , evt.Item
        INTO    #Tags
        FROM    ( SELECT    evt.SeasonCode
                          , evt.EventCode
                          , t.Item
                  FROM      ( SELECT    *
                              FROM      vTK_Event_SSB evt
                              WHERE     SeasonCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                                        SELECT  Item
                                        FROM    [dbo].[SplitSSB](@Season, ',') )
                                        AND evt.EventTypeCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                                        SELECT  Item
                                        FROM    [dbo].[SplitSSB](@EventType,
                                                              ',') )
                                        AND evt.FacilityCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                                        SELECT  Item
                                        FROM    [dbo].[SplitSSB](@Venue, ',') )
                            ) evt
                            CROSS APPLY dbo.Split(evt.Tags, ' ') AS t
                ) evt
        WHERE   evt.Item COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                SELECT  Item
                FROM    [dbo].[SplitSSB](@EventTag, ',') )
		
			  
        SELECT  SUM(Value) AS Value
              , MAX(DaysOut) OVER ( PARTITION BY Season, EventType, Item ) EventStart
              , ValueType
              , DaysOut
              , Season
              , et.EventType
              , Item
              , dat2.SeasonCode
        INTO    #tempstg
        FROM    ( SELECT    ROUND(CASE WHEN DATEDIFF(DAY, dat.TranDate,
                                                     dat.EventDate) > 0
                                       THEN DATEDIFF(DAY, dat.TranDate,
                                                     dat.EventDate)
                                       ELSE 0
                                  END / 7, 0) * 7 AS DaysOut
                          , SeasonCode
                          , ValueType
                          , Value
                          , Item
                          , EventTypeCode
                          , TranDate
                  FROM      ( SELECT    eo.TranDate
                                      , EventDate
                                      , MIN(TranDate) AS MinEventDate
                                      , eo.SeasonCode
                                      , ValueType
                                      , SUM(Value) AS Value
                                      , tg.Item
                                      , EventTypeCode
                              FROM      DW_EventTransOrigSales eo
                                        INNER JOIN dbo.TK_PRTYPE (NOLOCK) b ON b.PRTYPE = eo.PriceTypeCode
                                                              AND b.SEASON = eo.SeasonCode
                                        JOIN vTK_Event_SSB vt ON eo.EventCode = vt.EventCode
                                                              AND eo.SeasonCode = vt.SeasonCode
                                        INNER JOIN #Tags tg ON tg.SeasonCode = eo.SeasonCode
                                                              AND tg.EventCode = eo.EventCode
                              WHERE     eo.SeasonCode  COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                                        SELECT  Item
                                        FROM    dbo.Split(@Season, ',') )
                                        AND EventTypeCode  COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                                        SELECT  Item
                                        FROM    dbo.Split(@EventType, ',') )
                                        AND vt.FacilityCode COLLATE SQL_Latin1_General_CP1_CS_AS IN (
                                        SELECT  Item
                                        FROM    [dbo].[SplitSSB](@Venue, ',') )
                                        AND ISNULL(b.KIND, '') <> 'C'
                                        AND ISNULL(b.CLASS, '') <> 'CNS'
                              GROUP BY  TranDate
                                      , EventDate
                                      , tg.Item
                                      , EventTypeCode
                                      , eo.SeasonCode
                                      , eo.EventCode
                                      , ValueType
                            ) dat
                ) dat2
                JOIN vTK_Season sea ON sea.SeasonCode = dat2.SeasonCode
                JOIN vTK_EventType et ON et.EventTypeCode = dat2.EventTypeCode
        GROUP BY dat2.ValueType
              , DaysOut
              , et.EventType
              , Season
              , Item
              , dat2.SeasonCode;
        WITH    NumberSequence ( Number, NumberLabel )
                  AS ( SELECT   0 AS Number
                              , RIGHT('0000' + CAST(0 AS VARCHAR(32)), 4)
                       UNION ALL
                       SELECT   Number + 7
                              , RIGHT('0000' + CAST(Number + 7 AS VARCHAR(32)),
                                      4)
                       FROM     NumberSequence
                       WHERE    Number < 3650
                     )
            SELECT  dat.SeasonCode
                  , dat.Season
                  , dat.EventAge
                  , dat.EventType
                  , dat.Item
                  , dat.ValueType
                  , dat.Value
                  , SUM(CASE WHEN dat.Number <= rt.DaysOut THEN rt.Value
                             ELSE 0
                        END) AS CumulativeValue
                  , dat.SeasonTagGroup
            FROM    ( SELECT    edim.SeasonCode
                              , edim.Season
                              , NumberLabel AS EventAge
                              , edim.EventType
                              , edim.Item
                              , CASE WHEN DataType = 'Q'
                                     THEN 'Ticket Quantity'
                                     ELSE 'Revenue'
                                END AS ValueType
                              , ISNULL(Value, 0) AS Value
                              , SUM(ISNULL(Value, 0)) OVER ( PARTITION BY edim.SeasonCode,
                                                             edim.EventType,
                                                             edim.Item ) AS CumulativeValue
                              , edim.SeasonCode  COLLATE SQL_Latin1_General_CP1_CS_AS
                                + edim.Item  COLLATE SQL_Latin1_General_CP1_CS_AS AS SeasonTagGroup
                              , Number
                              , edim.DataType
                      FROM      ( SELECT DISTINCT
                                            Season
                                          , Item
                                          , EventType
                                          , Number
                                          , NumberLabel
                                          , DataType
                                          , SeasonCode
                                  FROM      #tempstg
                                            CROSS JOIN ( SELECT
                                                              'A' AS DataType
                                                         UNION
                                                         SELECT
                                                              'Q' AS DataType
                                                       ) x
                                            JOIN NumberSequence ON Number <= EventStart
                                ) edim
                                LEFT JOIN #tempstg ts ON edim.Season = ts.Season
                                                         AND edim.Item = ts.Item
                                                         AND edim.EventType = ts.EventType
                                                         AND edim.Number = ts.DaysOut
                                                         AND edim.DataType = ts.ValueType
                    ) dat
                    LEFT JOIN #tempstg rt ON dat.SeasonCode = rt.SeasonCode
                                             AND dat.Item = rt.Item
                                             AND dat.EventType = rt.EventType
                                             AND dat.DataType = rt.ValueType
            GROUP BY dat.SeasonCode
                  , dat.Season
                  , dat.EventAge
                  , dat.EventType
                  , dat.Item
                  , dat.ValueType
                  , dat.Value
                  , dat.SeasonTagGroup
        OPTION  ( MAXRECURSION 10000 ) 


        INSERT  [dbo].[TempVariableTrap]
                SELECT  @Season + '|' + @EventType + '|' + @EventTag + '|'
                        + @Venue
                      , GETDATE()
                      , 'Proc1Exit'

    END
GO
