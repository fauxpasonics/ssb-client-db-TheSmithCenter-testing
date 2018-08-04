SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROC [segmentation].[insertActionResult]
@runid VARCHAR(50),
@actionname VARCHAR(200),
@contactids stringtable READONLY
AS
BEGIN

INSERT INTO segmentation.actionresults(SSB_CRM_CONTACT_ID,Runid,ActionName)
SELECT [value],@runid,@actionname FROM @contactids

END;
GO
