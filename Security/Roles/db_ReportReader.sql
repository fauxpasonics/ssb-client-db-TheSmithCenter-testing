CREATE ROLE [db_ReportReader]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_ReportReader', N'svcReport'
GO
GRANT EXECUTE TO [db_ReportReader]
GRANT SELECT TO [db_ReportReader]
