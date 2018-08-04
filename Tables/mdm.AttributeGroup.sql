CREATE TABLE [mdm].[AttributeGroup]
(
[AttributeGroupID] [int] NOT NULL IDENTITY(1, 1),
[AttributeGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [mdm].[AttributeGroup] ADD CONSTRAINT [PK_AttributeGroup_AttributeGroupID] PRIMARY KEY CLUSTERED  ([AttributeGroupID]) WITH (DATA_COMPRESSION = PAGE)
GO
