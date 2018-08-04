SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE     PROC [segmentation].[getExportValues2]
@SelectClause VARCHAR(MAX),
@FromClause VARCHAR(MAX),
@Ids stringtable READONLY,
@IdColumn VARCHAR(200)
AS
BEGIN

DECLARE @sqlstring NVARCHAR(MAX) = @selectclause + ',' + @IdColumn + ' _Identifier ' + @fromclause + ' inner join @idtbl b on ' + @idColumn + '=b.[value]'

PRINT @sqlstring

EXEC sp_executesql @sqlstring,N'@idtbl stringtable readonly',@ids

END;
GO
