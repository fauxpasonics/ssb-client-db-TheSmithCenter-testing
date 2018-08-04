SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[SplitMultiColumn]
(
      @String nvarchar(max), 
      @ColumnDelimeter nvarchar(4) = '|',
      @RowDelimeter nvarchar(4) = ','
)

RETURNS
@Values TABLE 
(     
	Col1 varchar(4000),
	Col2 varchar(4000)      
)
as

BEGIN

	DECLARE @Xdoc xml

	DECLARE @Rows table (Item varchar(4000))

	--XML parser doesn't work for the & symbol. 
	--Convert it to another value before parsing and then convert back before returning the table
	set @String = REPLACE(@String, '&', '*$and$*')

	SET @Xdoc = CONVERT(xml,'<r><v>' + REPLACE(@String, @RowDelimeter,'</v><v>') + '</v></r>')

	INSERT INTO @Rows(Item)
	SELECT [Item] = replace(ltrim(rtrim(T.c.value('.','varchar(1000)'))),'*$and$*','&')
	FROM @Xdoc.nodes('/r/v') T(c)            

	INSERT INTO @Values (Col1, Col2)
	SELECT dbo.fnGetValueFromDelimitedString(Item, @ColumnDelimeter, '1') Col1
	, dbo.fnGetValueFromDelimitedString(Item, @ColumnDelimeter, '2') Col2
	FROM @Rows



	RETURN

END


GO
