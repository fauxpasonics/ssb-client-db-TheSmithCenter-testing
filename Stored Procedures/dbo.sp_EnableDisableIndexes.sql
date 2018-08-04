SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[sp_EnableDisableIndexes] 
	@Enable INT, @TableName VARCHAR(500), @ViewCurrentIndexState BIT = 0
AS
SET NOCOUNT ON;
--dbo.sp_EnableDisableIndexes 0, 'dbo.DimCustomer', 1

-- ENABLE
-- 1 or 0 = True/False -- WILL EXCLUDE CLUSTERED
-- -1 or -2 True/False -- WILL INCLUDE CLUSTERED

--SET @TableName = 'dbo.DimCustomer'
--SET @Enable = 1

DECLARE @idxtbl TABLE (
UID INT IDENTITY(1,1) PRIMARY KEY
, FullTblName VARCHAR(500)
, IndexId INT
, IndexName VARCHAR(500)
, IdxType VARCHAR(500)
, IsDisabled BIT
)

INSERT INTO @idxtbl
        ( [FullTblName] ,
          [IndexId] ,
          [IndexName] ,
          [IdxType] ,
		  [IsDisabled]
        )
SELECT sch.name + '.' + tbl.Name FullTable, idx.[index_id], idx.[name], idx.type_desc, idx.[is_disabled]
FROM sys.indexes idx
INNER JOIN sys.tables tbl ON idx.[object_id] = tbl.[object_id]
INNER JOIN sys.schemas sch ON tbl.[schema_id] = sch.[schema_id]
WHERE sch.name + '.' + tbl.Name = @TableName

IF @ViewCurrentIndexState = 1
SELECT * FROM @idxtbl

--ALTER INDEX [PK__DimCustomer] ON dbo.DimCustomer REBUILD;

DECLARE @Loops INT, @LoopCounter INT, @SQL NVARCHAR(4000)
DECLARE @IndexType VARCHAR(500), @IndexName VARCHAR(500), @IsDisabled BIT
SET @Loops = (SELECT MAX(UID) FROM @idxtbl)
SET @LoopCounter = 1

PRINT @Loops
WHILE @Loops >= @LoopCounter
	BEGIN
		SET @IndexName = (SELECT IndexName FROM @idxtbl WHERE UID = @LoopCounter)
		SET @IndexType = (SELECT [IdxType] FROM @idxtbl WHERE UID = @LoopCounter)
		SET @IsDisabled = (SELECT [IsDisabled] FROM @idxtbl WHERE UID = @LoopCounter)

		IF ((@Enable = 0 AND @IndexType <> 'Clustered') OR ABS(@Enable) = 2) AND @IsDisabled = 0
		SET @SQL = 'ALTER INDEX ' + @IndexName + ' ON ' + @TableName + ' DISABLE;'

		IF ABS(@Enable) = 1 AND @IsDisabled = 1
		SET @SQL = 'ALTER INDEX ' + @IndexName + ' ON ' + @TableName + ' REBUILD;'

		PRINT @SQL
		EXEC sp_executeSQL @SQL

		SET @LoopCounter = @LoopCounter + 1
	END

 
GO
