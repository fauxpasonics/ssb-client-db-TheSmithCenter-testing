SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rptCust_EventTypeBySeason_SSB]
    @Season VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        SET NOCOUNT ON

		--DECLARE 
		--	 @Season VARCHAR(500) = 'TSC1718'
		--	,@Venue VARCHAR(500) = 'BWAY,LHM,RH'

        SELECT DISTINCT
			 event.SEASON
			,event.ETYPE
			,etype.NAME COLLATE SQL_Latin1_General_CP1_CS_AS + ' ('
				+ event.ETYPE + ')' AS EventName
        FROM dbo.TK_EVENT event
        INNER JOIN dbo.TK_SEASON season 
			ON  season.SEASON = event.SEASON
		INNER JOIN dbo.TK_ETYPE etype 
			ON  etype.ETYPE = event.ETYPE
        WHERE event.SEASON IN (
				SELECT Item 
				FROM dbo.SplitSSB(@Season,',')
			)
            AND event.FACILITY IN (
				SELECT Item 
				FROM dbo.SplitSSB(@Venue,',')
			)

    END



GO
