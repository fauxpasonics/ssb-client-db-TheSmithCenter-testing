SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--[dbo].[rptCust_VenueBySeason_SSB] 'TSC1617,TSC1516'

create PROCEDURE [dbo].[rptCust_VenueBySeason_SSB_dev] @Season VARCHAR(25)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

		--SELECT @Season Season INTO 
		
 

        SELECT DISTINCT
                venue.FACILITY
              , CASE WHEN venue.NAME LIKE '%Reynolds%' THEN 'Reynolds Hall (RH)'
                     WHEN venue.NAME LIKE '%Studio%'
                     THEN 'Troesh Studio Theatre (ST)'
                     WHEN venue.NAME LIKE '%Cabaret%' THEN 'Cabaret Jazz (CJ)'
                     WHEN venue.NAME LIKE '%Symphony%' THEN 'Symphony Park (SP)'
					 ELSE 'Other'
                END AS EventName
		INTO #Temp
        FROM    dbo.TK_EVENT event
                JOIN dbo.TK_SEASON season ON season.SEASON = event.SEASON
                JOIN dbo.TK_FACILITY venue ON venue.FACILITY = event.FACILITY
        WHERE   event.SEASON IN ( SELECT    Item
                                  FROM      [dbo].[SplitSSB](@Season, ',') )


		SELECT DISTINCT EventName
		, STUFF(
			(SELECT ';' + temp2.FACILITY 
			FROM #Temp temp2
			WHERE temp.EventName = temp2.EventName
			FOR XML PATH('')), 1, 1, ''
			) AS VenueCodeSting 
		FROM #Temp temp


    END




GO
