SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Split]
(
      @String nvarchar(max), 
      @Delimiter nvarchar(max) = ','
)

RETURNS
@Values TABLE 
(     
      Item varchar(1000)      
)
AS
BEGIN

      DECLARE @Xdoc xml
      
      --XML parser doesn't work for the & symbol. 
      --Convert it to another value before parsing and then convert back before returning the table
      set @String = REPLACE(@String, '&', '*$and$*')
      
      
      SET @Xdoc = CONVERT(xml,'<r><v>' + REPLACE(@String, @Delimiter,'</v><v>') + '</v></r>')

      INSERT INTO @Values(Item)
      SELECT [Item] = replace(ltrim(rtrim(T.c.value('.','varchar(1000)'))),'*$and$*','&')
      FROM @Xdoc.nodes('/r/v') T(c) 


      RETURN

END


GO
