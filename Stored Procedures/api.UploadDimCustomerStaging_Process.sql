SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [api].[UploadDimCustomerStaging_Process]  
    @DataTable dbo.UploadDimCustomerStaging_Type READONLY  
AS  
BEGIN  
	SET NOCOUNT ON;
	DECLARE @finalXml  XML  
  
	BEGIN TRY  
  
		DECLARE @recordCount INT  
		SELECT @recordCount = COUNT(*)
		FROM @DataTable  
			  
		INSERT INTO [api].[UploadDimCustomerStaging]  
		([SessionId], [DynamicData], [DimCustomerId], [BatchId], [ODSRowLastUpdated], [SourceDB], [SourceSystem], [SourceSystemPriority], [SSID], [CustomerType],  
		 [CustomerStatus], [AccountType], [AccountRep], [CompanyName], [SalutationName], [DonorMailName], [DonorFormalName], [Birthday], [Gender], [MergedRecordFlag],  
		 [MergedIntoSSID], [Prefix], [FirstName], [MiddleName], [LastName], [FullName], [Suffix], [NameIsCleanStatus], [NameMasterId], [AddressPrimaryStreet],  
		 [AddressPrimarySuite], [AddressPrimaryCity], [AddressPrimaryState], [AddressPrimaryZip], [AddressPrimaryCounty], [AddressPrimaryCountry],   
		 [AddressPrimaryIsCleanStatus], [AddressPrimaryMasterId], [ContactGUID], [AddressOneStreet], [AddressOneSuite], [AddressOneCity], [AddressOneState],  
		 [AddressOneZip], [AddressOneCounty], [AddressOneCountry], [AddressOneIsCleanStatus], [AddressOneMasterId], [AddressTwoStreet], [AddressTwoSuite],  
		 [AddressTwoCity], [AddressTwoState], [AddressTwoZip], [AddressTwoCounty], [AddressTwoCountry], [AddressTwoIsCleanStatus], [AddressTwoMasterId],  
		 [AddressThreeStreet], [AddressThreeSuite], [AddressThreeCity], [AddressThreeState], [AddressThreeZip], [AddressThreeCounty], [AddressThreeCountry],   
		 [AddressThreeIsCleanStatus], [AddressThreeMasterId], [AddressFourStreet], [AddressFourSuite], [AddressFourCity], [AddressFourState], [AddressFourZip], [AddressFourCounty],  
		 [AddressFourCountry], [AddressFourIsCleanStatus], [AddressFourMasterId], [PhonePrimary], [PhonePrimaryIsCleanStatus],  
		 [PhonePrimaryMasterId], [PhoneHome], [PhoneHomeIsCleanStatus], [PhoneHomeMasterId], [PhoneCell], [PhoneCellIsCleanStatus],  
		 [PhoneCellMasterId], [PhoneBusiness], [PhoneBusinessIsCleanStatus], [PhoneBusinessMasterId], [PhoneFax],   
		 [PhoneFaxIsCleanStatus], [PhoneFaxMasterId], [PhoneOther], [PhoneOtherIsCleanStatus], [PhoneOtherMasterId], [EmailPrimary],  
		 [EmailPrimaryIsCleanStatus], [EmailPrimaryMasterId], [EmailOne], [EmailOneIsCleanStatus], [EmailOneMasterId],  
		 [EmailTwo], [EmailTwoIsCleanStatus], [EmailTwoMasterId], [ExtAttribute1], [ExtAttribute2], [ExtAttribute3], [ExtAttribute4], [ExtAttribute5],  
		 [ExtAttribute6], [ExtAttribute7], [ExtAttribute8], [ExtAttribute9], [ExtAttribute10], [ExtAttribute11], [ExtAttribute12], [ExtAttribute13], [ExtAttribute14],  
		 [ExtAttribute15], [ExtAttribute16], [ExtAttribute17], [ExtAttribute18], [ExtAttribute19], [ExtAttribute20], [ExtAttribute21], [ExtAttribute22], [ExtAttribute23],  
		 [ExtAttribute24], [ExtAttribute25], [ExtAttribute26], [ExtAttribute27], [ExtAttribute28], [ExtAttribute29], [ExtAttribute30], [ExtAttribute31], [ExtAttribute32],   
		 [ExtAttribute33], [ExtAttribute34], [ExtAttribute35], [SSCreatedDate], [SSUpdatedDate], [AccountId], [AddressPrimaryNCOAStatus], [AddressOneStreetNCOAStatus],   
		 [AddressTwoStreetNCOAStatus], [AddressThreeStreetNCOAStatus], [AddressFourStreetNCOAStatus], [IsBusiness], [customer_matchkey], [IsDeleted])  
		SELECT [SessionId], [DynamicData], [DimCustomerId], [BatchId], [ODSRowLastUpdated], [SourceDB], [SourceSystem], [SourceSystemPriority], [SSID], [CustomerType],  
		 [CustomerStatus], [AccountType], [AccountRep], [CompanyName], [SalutationName], [DonorMailName], [DonorFormalName], [Birthday], [Gender], [MergedRecordFlag],  
		 [MergedIntoSSID], [Prefix], [FirstName], [MiddleName], [LastName], [FullName], [Suffix], [NameIsCleanStatus], [NameMasterId], [AddressPrimaryStreet],  
		 [AddressPrimarySuite], [AddressPrimaryCity], [AddressPrimaryState], [AddressPrimaryZip], [AddressPrimaryCounty], [AddressPrimaryCountry],   
		 [AddressPrimaryIsCleanStatus], [AddressPrimaryMasterId], [ContactGUID], [AddressOneStreet], [AddressOneSuite], [AddressOneCity], [AddressOneState],  
		 [AddressOneZip], [AddressOneCounty], [AddressOneCountry], [AddressOneIsCleanStatus], [AddressOneMasterId], [AddressTwoStreet], [AddressTwoSuite],  
		 [AddressTwoCity], [AddressTwoState], [AddressTwoZip], [AddressTwoCounty], [AddressTwoCountry], [AddressTwoIsCleanStatus], [AddressTwoMasterId],  
		 [AddressThreeStreet], [AddressThreeSuite], [AddressThreeCity], [AddressThreeState], [AddressThreeZip], [AddressThreeCounty], [AddressThreeCountry],   
		 [AddressThreeIsCleanStatus], [AddressThreeMasterId], [AddressFourStreet], [AddressFourSuite], [AddressFourCity], [AddressFourState], [AddressFourZip], [AddressFourCounty],  
		 [AddressFourCountry], [AddressFourIsCleanStatus], [AddressFourMasterId], [PhonePrimary], [PhonePrimaryIsCleanStatus],  
		 [PhonePrimaryMasterId], [PhoneHome], [PhoneHomeIsCleanStatus], [PhoneHomeMasterId], [PhoneCell], [PhoneCellIsCleanStatus],  
		 [PhoneCellMasterId], [PhoneBusiness], [PhoneBusinessIsCleanStatus], [PhoneBusinessMasterId], [PhoneFax],   
		 [PhoneFaxIsCleanStatus], [PhoneFaxMasterId], [PhoneOther], [PhoneOtherIsCleanStatus], [PhoneOtherMasterId], [EmailPrimary],  
		 [EmailPrimaryIsCleanStatus], [EmailPrimaryMasterId], [EmailOne], [EmailOneIsCleanStatus], [EmailOneMasterId],  
		 [EmailTwo], [EmailTwoIsCleanStatus], [EmailTwoMasterId], [ExtAttribute1], [ExtAttribute2], [ExtAttribute3], [ExtAttribute4], [ExtAttribute5],  
		 [ExtAttribute6], [ExtAttribute7], [ExtAttribute8], [ExtAttribute9], [ExtAttribute10], [ExtAttribute11], [ExtAttribute12], [ExtAttribute13], [ExtAttribute14],  
		 [ExtAttribute15], [ExtAttribute16], [ExtAttribute17], [ExtAttribute18], [ExtAttribute19], [ExtAttribute20], [ExtAttribute21], [ExtAttribute22], [ExtAttribute23],  
		 [ExtAttribute24], [ExtAttribute25], [ExtAttribute26], [ExtAttribute27], [ExtAttribute28], [ExtAttribute29], [ExtAttribute30], [ExtAttribute31], [ExtAttribute32],   
		 [ExtAttribute33], [ExtAttribute34], [ExtAttribute35], [SSCreatedDate], [SSUpdatedDate], [AccountId], [AddressPrimaryNCOAStatus], [AddressOneStreetNCOAStatus],   
		 [AddressTwoStreetNCOAStatus], [AddressThreeStreetNCOAStatus], [AddressFourStreetNCOAStatus], [IsBusiness], [customer_matchkey], [IsDeleted]  
		FROM @DataTable  
		  
		SET @finalXml = '<Root><ResponseInfo><Success>true</Success><RecordsInserted>' + CAST(@recordCount AS NVARCHAR(10)) + '</RecordsInserted></ResponseInfo></Root>'  
  
	END TRY  
  
  
	BEGIN CATCH  
	  
		-- TODO: Better error messaging here  
		SET @finalXml = '<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to upload this data.</ErrorMessage></ResponseInfo></Root>'  
  
	END CATCH  
  
  
	-- Return response  
	SELECT CAST(@finalXml AS XML)  
  
END  
  

 
GO
