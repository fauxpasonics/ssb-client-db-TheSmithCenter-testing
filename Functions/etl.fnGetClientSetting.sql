SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [etl].[fnGetClientSetting]
(
      @Setting nvarchar(255)
)

RETURNS varchar(2000)
as 

BEGIN
	
	RETURN (SELECT value FROM etl.ClientSetting WHERE Setting = @Setting)


END


GO
