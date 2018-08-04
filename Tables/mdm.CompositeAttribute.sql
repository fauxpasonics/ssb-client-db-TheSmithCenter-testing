CREATE TABLE [mdm].[CompositeAttribute]
(
[DimCustomerID] [int] NOT NULL,
[SSB_CRMSYSTEM_CONTACT_ID] [uniqueidentifier] NOT NULL,
[DimCustomerAttrValsID] [int] NOT NULL,
[DimCustomerAttrID] [int] NOT NULL,
[AttributeName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AttributeValue] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertDate] [datetime] NOT NULL CONSTRAINT [DF_CompositeAttribute_InsertDate] DEFAULT (getdate())
)
GO
ALTER TABLE [mdm].[CompositeAttribute] ADD CONSTRAINT [PK_CompositeAttribute] PRIMARY KEY CLUSTERED  ([SSB_CRMSYSTEM_CONTACT_ID], [DimCustomerAttrValsID])
GO
