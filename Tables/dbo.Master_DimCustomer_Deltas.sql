CREATE TABLE [dbo].[Master_DimCustomer_Deltas]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[DimCustomerId] [int] NULL,
[SSID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Element] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ElementID] [int] NULL,
[Field] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FieldDisplay] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CD] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CD_Status] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Master] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayOrder] [int] NULL,
[AcceptedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AcceptedDate] [datetime] NULL,
[ProcessedDate] [datetime] NULL,
[InsertDate] [datetime] NULL CONSTRAINT [DF_Master_DimCustomer_Deltas_InsertDate] DEFAULT (getdate())
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
CREATE NONCLUSTERED INDEX [NCIX_Master_DimCustomer_Deltas_DimCustomerId] ON [dbo].[Master_DimCustomer_Deltas] ([DimCustomerId]) INCLUDE ([ElementID], [Field], [ProcessedDate]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_Master_DimCustomer_Deltas_InsertDate] ON [dbo].[Master_DimCustomer_Deltas] ([InsertDate] DESC) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE CLUSTERED INDEX [CIX_Master_DimCustomer_Deltas_ProcessedDate_DimCustomerId] ON [dbo].[Master_DimCustomer_Deltas] ([ProcessedDate], [DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
