CREATE TABLE [mdm].[Attributes]
(
[AttributeID] [int] NOT NULL IDENTITY(1, 1),
[Attribute] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttributeGroupID] [int] NULL,
[AttributeDataType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttributeDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [mdm].[Attributes] ADD CONSTRAINT [PK_Attributes_AttributeID] PRIMARY KEY CLUSTERED  ([AttributeID]) WITH (DATA_COMPRESSION = PAGE)
GO
