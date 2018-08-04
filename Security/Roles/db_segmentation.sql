CREATE ROLE [db_segmentation]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_segmentation', N'svcSegmentation'
GO
GRANT CREATE TABLE TO [db_segmentation]
GRANT REFERENCES TO [db_segmentation]
GRANT SELECT TO [db_segmentation]
GRANT VIEW DEFINITION TO [db_segmentation]
