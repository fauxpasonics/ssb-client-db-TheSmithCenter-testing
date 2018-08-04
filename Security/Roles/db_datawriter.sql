EXEC sp_addrolemember N'db_datawriter', N'db_svcLogi'
GO
EXEC sp_addrolemember N'db_datawriter', N'SSBCLOUD\SQL Deployers'
GO
EXEC sp_addrolemember N'db_datawriter', N'svcETL'
GO
EXEC sp_addrolemember N'db_datawriter', N'svcLogi'
GO
