CREATE TABLE [dbo].[DimCustomer]
(
[DimCustomerId] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[BatchId] [bigint] NULL,
[ODSRowLastUpdated] [datetime] NULL,
[SourceDB] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceSystemPriority] [int] NULL,
[SSID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_matchkey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[matchkey_updatedate] [datetime] NULL,
[AccountId] [int] NULL,
[AccountType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountRep] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalutationName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorMailName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorFormalName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Birthday] [date] NULL,
[Gender] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CD_Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MergedRecordFlag] [int] NULL,
[MergedIntoSSID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsBusiness] [bit] NULL,
[contactattrDirtyHash] [binary] (32) NULL,
[Prefix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameDirtyHash] [binary] (32) NULL,
[NameIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_NameIsCleanStatus] DEFAULT ('Dirty'),
[NameMasterId] [bigint] NULL,
[AddressPrimaryStreet] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimarySuite] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryCity] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryState] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryZip] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryPlus4] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryCounty] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryCountry] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryLatitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryLongitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryDirtyHash] [binary] (32) NULL,
[AddressPrimaryIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AddressPrimaryIsCleanStatus] DEFAULT ('Dirty'),
[AddressPrimaryNCOAStatus] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressPrimaryMasterId] [bigint] NULL,
[ContactDirtyHash] [binary] (32) NULL,
[ContactGUID] [uniqueidentifier] NULL,
[AddressOneStreet] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneSuite] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneCity] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneState] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneZip] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOnePlus4] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneCounty] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneCountry] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneLatitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneLongitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneDirtyHash] [binary] (32) NULL,
[AddressOneIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_AddressOneIsCleanStatus] DEFAULT ('Dirty'),
[AddressOneStreetNCOAStatus] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressOneMasterId] [bigint] NULL,
[AddressTwoStreet] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoSuite] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoCity] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoState] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoZip] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoPlus4] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoCounty] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoCountry] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoLatitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoLongitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoDirtyHash] [binary] (32) NULL,
[AddressTwoIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_AddressTwoIsCleanStatus] DEFAULT ('Dirty'),
[AddressTwoStreetNCOAStatus] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTwoMasterId] [bigint] NULL,
[AddressThreeStreet] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeSuite] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeCity] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeState] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeZip] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreePlus4] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeCounty] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeCountry] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeLatitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeLongitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeDirtyHash] [binary] (32) NULL,
[AddressThreeIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_AddressThreeIsCleanStatus] DEFAULT ('Dirty'),
[AddressThreeStreetNCOAStatus] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressThreeMasterId] [bigint] NULL,
[AddressFourStreet] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourSuite] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourCity] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourState] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourZip] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourPlus4] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourCounty] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourCountry] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourLatitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourLongitude] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourDirtyHash] [binary] (32) NULL,
[AddressFourIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_AddressFourIsCleanStatus] DEFAULT ('Dirty'),
[AddressFourStreetNCOAStatus] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressFourMasterId] [bigint] NULL,
[PhonePrimary] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhonePrimaryDNC] [bit] NULL,
[PhonePrimaryDirtyHash] [binary] (32) NULL,
[PhonePrimaryIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_PhonePrimaryIsCleanStatus] DEFAULT ('Dirty'),
[PhonePrimaryMasterId] [bigint] NULL,
[PhoneHome] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneHomeDNC] [bit] NULL,
[PhoneHomeDirtyHash] [binary] (32) NULL,
[PhoneHomeIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_PhoneHomeIsCleanStatus] DEFAULT ('Dirty'),
[PhoneHomeMasterId] [bigint] NULL,
[PhoneCell] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneCellDNC] [bit] NULL,
[PhoneCellDirtyHash] [binary] (32) NULL,
[PhoneCellIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_PhoneCellIsCleanStatus] DEFAULT ('Dirty'),
[PhoneCellMasterId] [bigint] NULL,
[PhoneBusiness] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneBusinessDNC] [bit] NULL,
[PhoneBusinessDirtyHash] [binary] (32) NULL,
[PhoneBusinessIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_PhoneBusinessIsCleanStatus] DEFAULT ('Dirty'),
[PhoneBusinessMasterId] [bigint] NULL,
[PhoneFax] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneFaxDNC] [bit] NULL,
[PhoneFaxDirtyHash] [binary] (32) NULL,
[PhoneFaxIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_PhoneFaxIsCleanStatus] DEFAULT ('Dirty'),
[PhoneFaxMasterId] [bigint] NULL,
[PhoneOther] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneOtherDNC] [bit] NULL,
[PhoneOtherDirtyHash] [binary] (32) NULL,
[PhoneOtherIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_PhoneOtherIsCleanStatus] DEFAULT ('Dirty'),
[PhoneOtherMasterId] [bigint] NULL,
[EmailPrimary] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailPrimaryDirtyHash] [binary] (32) NULL,
[EmailPrimaryIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_EmailPrimaryIsCleanStatus] DEFAULT ('Dirty'),
[EmailPrimaryMasterId] [bigint] NULL,
[EmailOne] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailOneDirtyHash] [binary] (32) NULL,
[EmailOneIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_EmailOneIsCleanStatus] DEFAULT ('Dirty'),
[EmailOneMasterId] [bigint] NULL,
[EmailTwo] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailTwoDirtyHash] [binary] (32) NULL,
[EmailTwoIsCleanStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DimCustomer_EmailTwoIsCleanStatus] DEFAULT ('Dirty'),
[EmailTwoMasterId] [bigint] NULL,
[ExtAttribute1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute4] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute5] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute6] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute7] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute8] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute9] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute10] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extattr1_10DirtyHash] [binary] (32) NULL,
[ExtAttribute11] [decimal] (18, 6) NULL,
[ExtAttribute12] [decimal] (18, 6) NULL,
[ExtAttribute13] [decimal] (18, 6) NULL,
[ExtAttribute14] [decimal] (18, 6) NULL,
[ExtAttribute15] [decimal] (18, 6) NULL,
[ExtAttribute16] [decimal] (18, 6) NULL,
[ExtAttribute17] [decimal] (18, 6) NULL,
[ExtAttribute18] [decimal] (18, 6) NULL,
[ExtAttribute19] [decimal] (18, 6) NULL,
[ExtAttribute20] [decimal] (18, 6) NULL,
[extattr11_20DirtyHash] [binary] (32) NULL,
[ExtAttribute21] [datetime] NULL,
[ExtAttribute22] [datetime] NULL,
[ExtAttribute23] [datetime] NULL,
[ExtAttribute24] [datetime] NULL,
[ExtAttribute25] [datetime] NULL,
[ExtAttribute26] [datetime] NULL,
[ExtAttribute27] [datetime] NULL,
[ExtAttribute28] [datetime] NULL,
[ExtAttribute29] [datetime] NULL,
[ExtAttribute30] [datetime] NULL,
[extattr21_30DirtyHash] [binary] (32) NULL,
[ExtAttribute31] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute32] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute33] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute34] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtAttribute35] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extattr31_35DirtyHash] [binary] (32) NULL,
[SSCreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSUpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSCreatedDate] [datetime] NULL,
[SSUpdatedDate] [datetime] NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL,
[UpdatedDate] [datetime] NOT NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_DimCustomer_IsDeleted] DEFAULT ((0)),
[DeleteDate] [datetime] NULL,
[FuzzyNameGUID] [uniqueidentifier] NULL
)
WITH
(
DATA_COMPRESSION = PAGE
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
	CREATE TRIGGER [dbo].[isdeleted_updated] 
	ON [dbo].[DimCustomer] 
	AFTER INSERT, UPDATE 
	AS  
	BEGIN 
		IF UPDATE(IsDeleted) 
		BEGIN 
			UPDATE dbo.DimCustomer 
			SET DeleteDate = CASE WHEN i.IsDeleted = 1 THEN CURRENT_TIMESTAMP ELSE NULL END 
			FROM dbo.DimCustomer a 
			INNER JOIN Inserted i ON a.DimCustomerId = i.DimCustomerId 
		END 
	END 
 
	
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
	CREATE TRIGGER [dbo].[matchkey_updated] 
	ON [dbo].[DimCustomer] 
	AFTER UPDATE 
	AS  
	BEGIN 
	IF UPDATE(customer_matchkey) OR UPDATE (CompanyName) 
		BEGIN 
		UPDATE dbo.DimCustomer 
		SET matchkey_updatedate = CURRENT_TIMESTAMP 
		FROM dbo.DimCustomer a 
		INNER join inserted i 
		ON a.dimcustomerid = i.dimcustomerid; 
		End 
	END
GO
ALTER TABLE [dbo].[DimCustomer] ADD CONSTRAINT [PK_DimCustomer_DimcustomerID] PRIMARY KEY CLUSTERED  ([DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_AccountId] ON [dbo].[DimCustomer] ([AccountId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_addressfourstatus] ON [dbo].[DimCustomer] ([AddressFourIsCleanStatus]) INCLUDE ([AddressFourStreet], [DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_AddressFour] ON [dbo].[DimCustomer] ([AddressFourIsCleanStatus], [IsDeleted]) INCLUDE ([AddressFourCity], [AddressFourCountry], [AddressFourCounty], [AddressFourState], [AddressFourStreet], [AddressFourSuite], [AddressFourZip], [CustomerType], [DimCustomerId], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_addressOnestatus] ON [dbo].[DimCustomer] ([AddressOneIsCleanStatus]) INCLUDE ([AddressOneStreet], [DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_AddressOne] ON [dbo].[DimCustomer] ([AddressOneIsCleanStatus], [IsDeleted]) INCLUDE ([AddressOneCity], [AddressOneCountry], [AddressOneCounty], [AddressOneState], [AddressOneStreet], [AddressOneSuite], [AddressOneZip], [CustomerType], [DimCustomerId], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_addressprimarystatus] ON [dbo].[DimCustomer] ([AddressPrimaryIsCleanStatus]) INCLUDE ([AddressPrimaryStreet], [DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_AddressPrimary] ON [dbo].[DimCustomer] ([AddressPrimaryIsCleanStatus], [IsDeleted]) INCLUDE ([AddressPrimaryCity], [AddressPrimaryCountry], [AddressPrimaryCounty], [AddressPrimaryState], [AddressPrimaryStreet], [AddressPrimarySuite], [AddressPrimaryZip], [CustomerType], [DimCustomerId], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_addressthreestatus] ON [dbo].[DimCustomer] ([AddressThreeIsCleanStatus]) INCLUDE ([AddressThreeStreet], [DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_AddressThree] ON [dbo].[DimCustomer] ([AddressThreeIsCleanStatus], [IsDeleted]) INCLUDE ([AddressThreeCity], [AddressThreeCountry], [AddressThreeCounty], [AddressThreeState], [AddressThreeStreet], [AddressThreeSuite], [AddressThreeZip], [CustomerType], [DimCustomerId], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_addresstwostatus] ON [dbo].[DimCustomer] ([AddressTwoIsCleanStatus]) INCLUDE ([AddressTwoStreet], [DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_AddressTwo] ON [dbo].[DimCustomer] ([AddressTwoIsCleanStatus], [IsDeleted]) INCLUDE ([AddressTwoCity], [AddressTwoCountry], [AddressTwoCounty], [AddressTwoState], [AddressTwoStreet], [AddressTwoSuite], [AddressTwoZip], [CustomerType], [DimCustomerId], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_emailonestatus] ON [dbo].[DimCustomer] ([EmailOneIsCleanStatus]) INCLUDE ([DimCustomerId], [EmailOne]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_EmailOne] ON [dbo].[DimCustomer] ([EmailOneIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [EmailOne], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_emailprimarystatus] ON [dbo].[DimCustomer] ([EmailPrimaryIsCleanStatus]) INCLUDE ([DimCustomerId], [EmailPrimary]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_EmailPrimary] ON [dbo].[DimCustomer] ([EmailPrimaryIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [EmailPrimary], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_emailtwostatus] ON [dbo].[DimCustomer] ([EmailTwoIsCleanStatus]) INCLUDE ([DimCustomerId], [EmailTwo]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_EmailTwo] ON [dbo].[DimCustomer] ([EmailTwoIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [EmailTwo], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_customer_matchkey] ON [dbo].[DimCustomer] ([FirstName], [LastName], [customer_matchkey]) INCLUDE ([DimCustomerId], [SourceSystem], [SourceSystemPriority], [SSCreatedDate], [SSID], [SSUpdatedDate]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_CompanyName] ON [dbo].[DimCustomer] ([IsDeleted]) INCLUDE ([CompanyName], [CustomerType], [DimCustomerId], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_isdeleted] ON [dbo].[DimCustomer] ([IsDeleted]) INCLUDE ([DimCustomerId], [SourceSystem], [SSID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_IsBusiness] ON [dbo].[DimCustomer] ([IsDeleted], [IsBusiness]) INCLUDE ([DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_NameIsCleanStatus] ON [dbo].[DimCustomer] ([NameIsCleanStatus], [IsDeleted]) INCLUDE ([DimCustomerId]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_phonebusinessstatus] ON [dbo].[DimCustomer] ([PhoneBusinessIsCleanStatus]) INCLUDE ([DimCustomerId], [PhoneBusiness]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_PhoneBusiness] ON [dbo].[DimCustomer] ([PhoneBusinessIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [PhoneBusiness], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_phonecellstatus] ON [dbo].[DimCustomer] ([PhoneCellIsCleanStatus]) INCLUDE ([DimCustomerId], [PhoneCell]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_PhoneCell] ON [dbo].[DimCustomer] ([PhoneCellIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [PhoneCell], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_phonefaxstatus] ON [dbo].[DimCustomer] ([PhoneFaxIsCleanStatus]) INCLUDE ([DimCustomerId], [PhoneFax]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_PhoneFax] ON [dbo].[DimCustomer] ([PhoneFaxIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [PhoneFax], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_phonehomestatus] ON [dbo].[DimCustomer] ([PhoneHomeIsCleanStatus]) INCLUDE ([DimCustomerId], [PhoneHome]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_PhoneHome] ON [dbo].[DimCustomer] ([PhoneHomeIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [PhoneHome], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_phoneotherstatus] ON [dbo].[DimCustomer] ([PhoneOtherIsCleanStatus]) INCLUDE ([DimCustomerId], [PhoneOther]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_PhoneOther] ON [dbo].[DimCustomer] ([PhoneOtherIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [PhoneOther], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_dimcustomer_phoneprimarystatus] ON [dbo].[DimCustomer] ([PhonePrimaryIsCleanStatus]) INCLUDE ([DimCustomerId], [PhonePrimary]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE NONCLUSTERED INDEX [NCIX_DimCustomer_PhonePrimary] ON [dbo].[DimCustomer] ([PhonePrimaryIsCleanStatus], [IsDeleted]) INCLUDE ([CustomerType], [DimCustomerId], [PhonePrimary], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
ALTER TABLE [dbo].[DimCustomer] ADD CONSTRAINT [UK_DimCustomer_SSID_SourceSystem] UNIQUE NONCLUSTERED  ([SSID], [SourceSystem]) WITH (DATA_COMPRESSION = PAGE)
GO
