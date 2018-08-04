SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [dbo].[Split_DS]
(
      @String NVARCHAR(MAX), 
      @Delimiter NVARCHAR(MAX) = ','
)

RETURNS
@Values TABLE 
(     
      ID INT IDENTITY(1,1),
	  Item VARCHAR(1000)      
)
AS
BEGIN

      DECLARE @Xdoc XML
      
      --XML parser doesn't work for the & symbol. 
      --Convert it to another value before parsing and then convert back before returning the table
      SET @String = REPLACE(@String, '&', '*$and$*')
      
      
      SET @Xdoc = CONVERT(XML,'<r><v>' + REPLACE(@String, @Delimiter,'</v><v>') + '</v></r>')

      INSERT INTO @Values(Item)
      SELECT [Item] = REPLACE(LTRIM(RTRIM(T.c.value('.','varchar(1000)'))),'*$and$*','&')
      FROM @Xdoc.nodes('/r/v') T(c) 


      RETURN

END




GO
