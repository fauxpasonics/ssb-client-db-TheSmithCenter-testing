CREATE TABLE [dbo].[DimCustomerAttributes]
(
[DimCustomerAttrID] [int] NOT NULL IDENTITY(1, 1),
[DimCustomerID] [int] NULL,
[AttributeGroupID] [int] NULL,
[Attributes] [xml] NULL,
[CreatedDate] [datetime] NULL CONSTRAINT [DF_DimCustomerAttributes_CreatedDate] DEFAULT (getdate()),
[UpdatedDate] [datetime] NULL CONSTRAINT [DF_DimCustomerAttributes_UpdatedDate] DEFAULT (getdate())
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[DimCustomerAttributes] ADD CONSTRAINT [PK_DimCustomerAttributes_DimCustomerAttrID] PRIMARY KEY NONCLUSTERED  ([DimCustomerAttrID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE CLUSTERED INDEX [IXC_DimCustomerAttributes] ON [dbo].[DimCustomerAttributes] ([DimCustomerID], [AttributeGroupID]) WITH (DATA_COMPRESSION = PAGE)
GO
