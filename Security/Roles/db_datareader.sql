EXEC sp_addrolemember N'db_datareader', N'db_svcLogi'
GO
EXEC sp_addrolemember N'db_datareader', N'SSBCLOUD\CI - DB Read Only'
GO
EXEC sp_addrolemember N'db_datareader', N'SSBCLOUD\SQL Deployers'
GO
EXEC sp_addrolemember N'db_datareader', N'SSBINFO\SSB IE  Intern Sec'
GO
EXEC sp_addrolemember N'db_datareader', N'svcETL'
GO
EXEC sp_addrolemember N'db_datareader', N'svcLogi'
GO
EXEC sp_addrolemember N'db_datareader', N'svcQA'
GO
