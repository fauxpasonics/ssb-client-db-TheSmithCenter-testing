SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnGetValueFromDelimitedString]
(
      @String nvarchar(max), 
      @Delimiter nvarchar(max) = ',',
      @ValuePosition int      
)

RETURNS varchar(4000)
as 

BEGIN

	declare @Result varchar(4000)	
		
	declare @Values table (ValueNumber int IDENTITY(1,1), Value varchar(4000))	
	declare @Xdoc xml

	--XML parser doesn't work for the & symbol. 
	--Convert it to another value before parsing and then convert back before returning the table
	set @String = REPLACE(@String, '&', '*$and$*')

	SET @Xdoc = CONVERT(xml,'<r><v>' + REPLACE(@String, @Delimiter,'</v><v>') + '</v></r>')

	INSERT INTO @Values(Value)
	SELECT [Item] = replace(ltrim(rtrim(T.c.value('.','varchar(1000)'))),'*$and$*','&')
	FROM @Xdoc.nodes('/r/v') T(c) 
	
	set @Result = (
					select Value
					from @Values
					where ValueNumber = @ValuePosition
	)
	
	RETURN @Result

END


GO
