CREATE TABLE [mdm].[overrides]
(
[OverrideID] [int] NOT NULL IDENTITY(1, 1),
[DimCustomerID] [int] NULL,
[ElementID] [int] NULL,
[Field] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Overrides_CreatedBy] DEFAULT (suser_sname()),
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF_overrides_DateCreated] DEFAULT (getdate()),
[DateUpdated] [datetime] NULL CONSTRAINT [DF_overrides_DateUpdated] DEFAULT (getdate())
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [mdm].[overrides] ADD CONSTRAINT [pk_OverrideID] PRIMARY KEY CLUSTERED  ([OverrideID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_ElementID] ON [mdm].[overrides] ([ElementID]) WITH (DATA_COMPRESSION = PAGE)
GO
ALTER TABLE [mdm].[overrides] ADD CONSTRAINT [fk_DimCustomerID] FOREIGN KEY ([DimCustomerID]) REFERENCES [dbo].[DimCustomer] ([DimCustomerId])
GO
