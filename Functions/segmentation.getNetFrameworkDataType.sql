SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   FUNCTION [segmentation].[getNetFrameworkDataType](@sqldatatype NVARCHAR(200))
	RETURNS NVARCHAR(200)
	AS
	BEGIN
	--Mapping based on https://msdn.microsoft.com/en-us/library/cc716729(v=vs.110).aspx
	DECLARE @return NVARCHAR(200)

	SET @return=(CASE WHEN @sqldatatype IN ('bigint') THEN 'System.Int64'
				WHEN @sqldatatype IN ('int') THEN 'System.Int32'
				WHEN @sqldatatype IN ('smallint') THEN 'System.Int16'
				WHEN @sqldatatype IN ('tinyint') THEN 'System.Byte'
				WHEN @sqldatatype IN ('real') THEN 'System.Single'
				WHEN @sqldatatype IN ('float') THEN 'System.Double'
				WHEN @sqldatatype IN ('decimal','money','numeric','smallmoney') THEN 'System.Decimal'
				WHEN @sqldatatype IN ('uniqueidentifier') THEN 'System.String' --Converting to System.Guid does not work well, in 90% of cases loading into a string will be fine and we can parse to a guid if needed.
				WHEN @sqldatatype IN ('date','datetime','datetime2','smalldatetime') THEN 'System.DateTime'
				WHEN @sqldatatype IN ('datetimeoffset') THEN 'System.DateTimeOffset'
				WHEN @sqldatatype IN ('time') THEN 'System.TimeSpan'
				WHEN @sqldatatype IN ('bit') THEN 'System.Boolean'
				WHEN @sqldatatype IN ('char','nchar','ntext','nvarchar','text','varchar') THEN 'System.String'
				WHEN @sqldatatype IN ('binary','varbinary','image','rowversion','timestamp') THEN 'System.Byte[]'
				WHEN @sqldatatype IN ('sql_variant') THEN 'System.Object'
				WHEN @sqldatatype IN ('xml') THEN 'System.Xml'
				ELSE 'System.String'
				END)

				RETURN @return

	END
GO
