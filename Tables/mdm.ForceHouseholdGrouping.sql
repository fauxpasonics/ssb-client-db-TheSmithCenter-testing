CREATE TABLE [mdm].[ForceHouseholdGrouping]
(
[DimCustomerId] [int] NULL,
[GroupingID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__ForceHous__Creat__00632BE6] DEFAULT (getdate()),
[UpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__ForceHous__Updat__0157501F] DEFAULT (getdate()),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorGrouping] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
