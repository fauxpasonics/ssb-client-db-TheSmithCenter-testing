SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[rptCust_Days_Out_EventGroup_SSB_4]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @EventGroup VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN
/*	
declare		@Season  varchar(500),
    @EventType  varchar(500),
    @EventGroup  varchar(500),
    @Venue varchar(500)

	SET @Season = 'TSC1516,TSC1314,TSC1415,MER2015,NBT1314'
	SET @EventType = 'BLV,CAB,CLS,COM,ADD'
	SET @EventGroup = 'ANA,ANN,ASZ' 
	SET @Venue = 'BWAY,CJ,GA'
	*/

	SELECT DISTINCT mevt.Season + mevt.EGroup AS SeasonGroupCode, isnull(eg.Name, mevt.Egroup) as EventGroup
	 FROM TK_Event mevt  left join [dbo].[TK_EGROUP]  eg on mevt.EGroup = eg.EGroup AND eg.SEASON = mevt.SEASON
			WHERE mevt.Season COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Season,','))
              AND mevt.EType COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventType,','))
              AND mevt.Egroup COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@EventGroup,','))
                AND mevt.Facility COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT Item FROM [dbo].[SplitSSB] (@Venue,','))




end

GO
