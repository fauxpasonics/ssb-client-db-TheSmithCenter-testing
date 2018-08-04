SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[rptCust_Seasons_SSB] 

AS 
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT 
		tkSeason.Season,
		tkSeason.NAME COLLATE SQL_Latin1_General_CP1_CS_AS + ' (' + tkSeason.Season + ')' AS SeasonName
		
	FROM 
		dbo.TK_SEASON tkSeason
	WHERE tkSeason.SEASON NOT IN ('TSCT', 'TNG', 'PAC')
		


	ORDER BY 
		tkSeason.SEASON DESC

	
END


GO
