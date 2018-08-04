SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[SSB_ConditionalReIndex]
(
	@Table NVARCHAR(MAX),
	@FragmentationLevelRebuild int = 10,
	@FragmentationLevelReorganize int = 20
)

AS
BEGIN


BEGIN TRY

DECLARE @CurrentDB NVARCHAR(255) = DB_NAME()
DECLARE @TableToIndex NVARCHAR(255) = @CurrentDB + '.' + @Table

EXECUTE dbo.IndexOptimize
	@Databases = @CurrentDB,
	@FragmentationLow = NULL,
	@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationLevel1 = @FragmentationLevelRebuild,
	@FragmentationLevel2 = @FragmentationLevelReorganize,
	@Indexes = @TableToIndex

END TRY
BEGIN CATCH
	--TO DO Log Error
END CATCH

END 



GO
