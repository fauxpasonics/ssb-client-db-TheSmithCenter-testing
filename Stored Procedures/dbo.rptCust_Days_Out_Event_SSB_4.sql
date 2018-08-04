SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
EXEC dbo.rptCust_Days_Out_Event_SSB_4 @Season = 'CB2013', -- varchar(25)
    @EventType = 'CB', -- varchar(128)
    @Event = 'CC', -- varchar(25)
	@Venue = 'CB' -- varchar(25)

*/

CREATE PROCEDURE [dbo].[rptCust_Days_Out_Event_SSB_4]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @Event VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

		SELECT DISTINCT mevt.Season + Item AS SeasonEventGroup , 
		ISNULL(NULLIF(LEFT(Name,30),''),	Event)  + ' (' + Event COLLATE Latin1_General_CI_AS + ')'						AS Event
			 FROM TK_Event mevt   
			WHERE mevt.Season COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
              AND mevt.EType COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventType,','))
				AND mevt.Event COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Event,','))
                 AND mevt.Facility COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))

	END


GO
