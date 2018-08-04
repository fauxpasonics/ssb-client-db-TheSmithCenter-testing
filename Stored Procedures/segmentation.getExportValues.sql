SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Create/Update sprocs and functions
CREATE   PROC [segmentation].[getExportValues]
@SelectClause VARCHAR(MAX),
@FromClause VARCHAR(MAX),
@Ids VARCHAR(MAX),
@IdColumn VARCHAR(200)
AS
BEGIN

--DECLARE @selectclause VARCHAR(MAX) = 'SELECT DISTINCT [PrimaryData].[First_Name_Updated],[PrimaryData].[Last_Name_Updated],[PrimaryData].[Primary_Address_State], [ReportBase].[SEASON],[ReportBase].[I_PT_NAME],[ReportBase].[ORDTOTAL]'
--DECLARE @fromclause VARCHAR(MAX) = 'FROM [Segmentation].[SegmentationFlatDataDE7A7FFB-F63C-44A2-AFE3-1A2364B49C7E] AS PrimaryData INNER JOIN [Segmentation].[SegmentationFlatData3E903D7B-25BF-411B-A652-11674441D065] AS ReportBase ON [PrimaryData].[SSB_CRMSYSTEM_CONTACT_ID] = [ReportBase].[SSB_CRMSYSTEM_CONTACT_ID]'
--DECLARE @ids VARCHAR(MAX)

--SELECT  @ids = COALESCE(@Ids + ',''','''') + SSB_CRMSYSTEM_CONTACT_ID + '''' 
--FROM (SELECT TOP 10000 SSB_CRMSYSTEM_CONTACT_ID FROM [Segmentation].[SegmentationFlatDataDE7A7FFB-F63C-44A2-AFE3-1A2364B49C7E] WITH (NOLOCK)) a
--SELECT @ids --+ ']'

--CREATE TABLE #ids(value VARCHAR(50) NOT NULL PRIMARY KEY)

--INSERT INTO #ids
--(
--    value
--)
--SELECT value FROM OPENJSON(@ids)

--SELECT * FROM #ids


DECLARE @sqlstring VARCHAR(MAX) = @selectclause + ',' + @IdColumn + ' _Identifier ' + @fromclause + ' WHERE ' + @IdColumn + ' in (' + @ids + ')'

--PRINT @sqlstring

EXEC(@sqlstring)

END;
GO
