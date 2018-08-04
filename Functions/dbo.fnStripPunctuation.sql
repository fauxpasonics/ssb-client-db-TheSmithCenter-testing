SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE FUNCTION [dbo].[fnStripPunctuation] (@InputString NVARCHAR(MAX)) 
RETURNS NVARCHAR(MAX) 
AS 
BEGIN 
IF @InputString IS NOT NULL 
BEGIN 
  DECLARE @Counter INT, @TestString NVARCHAR(40) 
 
  SET @TestString = '%[^a-z ^A-Z ^0-9]%' 
 
  SELECT @Counter = PATINDEX (@TestString, @InputString COLLATE Latin1_General_BIN) 
 
  WHILE @Counter <> 0 
  BEGIN 
    SELECT @InputString = STUFF(@InputString, @Counter, 1, '') 
    SELECT @Counter = PATINDEX (@TestString, @InputString COLLATE Latin1_General_BIN) 
  END 
END 
RETURN(@InputString) 
END
GO
