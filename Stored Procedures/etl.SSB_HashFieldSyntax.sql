SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [etl].[SSB_HashFieldSyntax]
(
	@TableName AS NVARCHAR(255),
	@ColumnList AS NVARCHAR(MAX) = '',
	@Options AS NVARCHAR(MAX) = ''
) 

AS	
BEGIN

	SET @TableName = REPLACE(REPLACE(@TableName, '[', ''),']','')
	SET @ColumnList = REPLACE(REPLACE(REPLACE(@ColumnList, '[', ''),']',''),' ','')

	DECLARE @ExcludeColumns BIT = 1
	DECLARE @SqlString AS VARCHAR(MAX) = ''
	DECLARE @SqlStringMax AS VARCHAR(MAX) = ''
	DECLARE @SchemaName  AS VARCHAR(255) = [dbo].[fnGetValueFromDelimitedString](@TableName, '.' ,1)
	DECLARE @Table AS VARCHAR(255) = [dbo].[fnGetValueFromDelimitedString](@TableName, '.' ,2)
	DECLARE @ColumnCount INT = 0


	SELECT @SqlString = @SqlString +
	CASE DATA_TYPE 
	WHEN 'int' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ')),''DBNULL_INT'')'
	WHEN 'bigint' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ')),''DBNULL_BIGINT'')'
	WHEN 'datetime' THEN 'ISNULL(RTRIM(CONVERT(varchar(25),' + COLUMN_NAME + ')),''DBNULL_DATETIME'')'  
	WHEN 'datetime2' THEN 'ISNULL(RTRIM(CONVERT(varchar(25),' + COLUMN_NAME + ')),''DBNULL_DATETIME'')'
	WHEN 'date' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ',112)),''DBNULL_DATE'')' 
	WHEN 'bit' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ')),''DBNULL_BIT'')'  
	WHEN 'decimal' THEN 'ISNULL(RTRIM(CONVERT(varchar(25),'+ COLUMN_NAME + ')),''DBNULL_NUMBER'')' 
	WHEN 'numeric' THEN 'ISNULL(RTRIM(CONVERT(varchar(25),'+ COLUMN_NAME + ')),''DBNULL_NUMBER'')' 
	ELSE 'ISNULL(RTRIM(' + COLUMN_NAME + '),''DBNULL_TEXT'')'
	END + ' + '
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @Table 
	AND ISNULL(CHARACTER_MAXIMUM_LENGTH, 0) >= 0
	AND COLUMN_NAME NOT IN (
		SELECT Item FROM [dbo].[Split](@ColumnList, ',')
	)
	ORDER BY COLUMN_NAME

	SELECT @ColumnCount = COUNT(*)
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @Table
	AND ISNULL(CHARACTER_MAXIMUM_LENGTH, 0) >= 0
	AND COLUMN_NAME NOT IN (
		SELECT Item FROM [dbo].[Split](@ColumnList, ',')
	)

	PRINT @SqlString
		
	SELECT 'HASHBYTES(''sha2_256'', ' + LEFT(@SqlString, (LEN(@SqlString) - 2)) + ')' DeltaHashKey
	
	/*
	SELECT @SqlStringMax = @sqlStringMax + 'ISNULL(' + COLUMN_NAME + ','''') <> ' + 'ISNULL(' + COLUMN_NAME + ','''') AND '
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @Table
	AND ISNULL(CHARACTER_MAXIMUM_LENGTH, 0) < 0
	AND COLUMN_NAME NOT IN (
		SELECT Item FROM [dbo].[Split](@ColumnList, ',')
	)

	SET @SqlStringMax = ISNULL(@SqlStringMax,'')
	DECLARE @SqlStringMaxRemovalChar INT = CASE WHEN LEN(@SqlStringMax) > 0 THEN 4 ELSE 0 end

	SELECT LEFT(@SqlStringMax, (LEN(@SqlStringMax) - @SqlStringMaxRemovalChar))
	*/
	
	
END







GO
