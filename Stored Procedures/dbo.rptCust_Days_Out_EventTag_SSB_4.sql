SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--[dbo].[rptCust_Days_Out_EventTag_SSB_4] '1','1','1','1'


/*
EXEC dbo.rptCust_Days_Out_EventTag_SSB_4 @Season = 'LVP1415', -- varchar(25)
    @EventType = 'PCLS', -- varchar(128)
    @EventTag = 'RESCO', -- varchar(25)
	@Venue = 'LHM' -- varchar(25)
*/

CREATE PROCEDURE [dbo].[rptCust_Days_Out_EventTag_SSB_4]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @EventTag VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

	SELECT  evt.Season
              , evt.Event
              , t.Item
        INTO    #Tags
        FROM  TK_Event evt
                CROSS APPLY dbo.Split(evt.Tag, ' ') AS t
        ORDER BY evt.Season
              , evt.Event

			  
	
	SELECT DISTINCT mevt.Season COLLATE Latin1_General_CI_AS +t.Item COLLATE Latin1_General_CI_AS AS SeasonTagGroup , t.Item
	 FROM TK_Event mevt    JOIN #Tags t ON t.EVENT = mevt.Event AND t.Season = mevt.Season             
			WHERE mevt.Season COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
              AND mevt.EType COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventType,','))
			  AND t.Item COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventTag,','))              
                AND mevt.Facility COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))
				
		END

GO
