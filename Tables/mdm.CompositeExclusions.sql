CREATE TABLE [mdm].[CompositeExclusions]
(
[ElementID] [int] NOT NULL,
[ExclusionID] [int] NOT NULL,
[IsDeleted] [bit] NULL,
[DateCreated] [date] NULL CONSTRAINT [DF_CompositeExclusions_DateCreated] DEFAULT (getdate()),
[DateUpdated] [date] NULL CONSTRAINT [DF_CompositeExclusions_DateUpdated] DEFAULT (getdate())
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
