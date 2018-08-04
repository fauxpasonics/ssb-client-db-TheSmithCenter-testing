SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	CREATE   function [segmentation].[getSimpleDataType](@sqldatatype nvarchar(200))
	returns nvarchar(200)
	as
	begin
	--Mapping based on https://msdn.microsoft.com/en-us/library/cc716729(v=vs.110).aspx
	declare @return nvarchar(200)

	set @return=(case when @sqldatatype in ('bigint','int','smallint','tinyint','datetimeoffset') then 'integer'
				when @sqldatatype in ('real','float','decimal','money','numeric','smallmoney') then 'double'
				when @sqldatatype in ('date') then 'date'
				when @sqldatatype in ('datetime','datetime2','smalldatetime') then 'datetime'
				when @sqldatatype in ('time') then 'time'
				when @sqldatatype in ('bit') then 'boolean'
				else 'string'
				end)

				return @return

	END
GO
