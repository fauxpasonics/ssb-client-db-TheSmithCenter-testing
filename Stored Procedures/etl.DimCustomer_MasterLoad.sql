SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 


/* Note: DO NOT INCLUDE TM or Ticketing data in this proc currently */

CREATE PROCEDURE [etl].[DimCustomer_MasterLoad]

AS
BEGIN

select 1
-- Source 1 (eg.SKIDATA)
EXEC mdm.etl.LoadDimCustomer @ClientDB = 'ClientDB', @LoadView = 'Source View Name', @LogLevel = '0', @DropTemp = '1', @IsDataUploaderSource = '0'

-- Source 2 (eg.CRM_Contact)
EXEC mdm.etl.LoadDimCustomer @ClientDB = 'ClientDB', @LoadView = ' Source View Name (eg.ods.vw_CRM_Contact_LoadDimCustomer)', @LogLevel = '0', @DropTemp = '1', @IsDataUploaderSource = '0'

-- Source 3 
EXEC mdm.etl.LoadDimCustomer @ClientDB = 'ClientDB', @LoadView = 'Source View Name', @LogLevel = '0', @DropTemp = '1', @IsDataUploaderSource = '0'

END



 
GO
