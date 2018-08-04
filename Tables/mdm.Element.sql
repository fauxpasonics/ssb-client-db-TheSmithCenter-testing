CREATE TABLE [mdm].[Element]
(
[ElementID] [int] NOT NULL IDENTITY(1, 1),
[Element] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ElementType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ElementFieldList] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ElementUpdateStatement] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ElementIsCleanField] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Custom] [bit] NULL,
[IsDeleted] [bit] NULL,
[DateCreated] [date] NULL CONSTRAINT [DF_Element_DateCreated] DEFAULT (getdate()),
[DateUpdated] [date] NULL CONSTRAINT [DF_Element_DateUpdated] DEFAULT (getdate())
)
GO
ALTER TABLE [mdm].[Element] ADD CONSTRAINT [UQ_Element1] UNIQUE NONCLUSTERED  ([Element], [ElementType], [Custom], [IsDeleted]) WITH (DATA_COMPRESSION = PAGE)
GO
