CREATE TYPE [dbo].[stringtable] AS TABLE
(
[value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[stringtable] TO [db_segmentation]
GO
