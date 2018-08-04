SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE VIEW [dbo].[vw_Master_DimCustomer_Deltas]
AS  
SELECT
	 m.DimCustomerId  
	,m.SSID  
	,m.SourceSystem
	-- SOURCE  
	,s.Prefix AS s_Prefix  
	,s.FirstName AS s_FirstName  
	,s.MiddleName AS s_MiddleName  
	,s.LastName AS s_LastName  
	,s.Suffix AS s_Suffix  
	,s.FullName AS s_FullName  
	,s.AddressPrimaryStreet AS s_AddressPrimaryStreet  
	,s.AddressPrimarySuite AS s_AddressPrimarySuite  
	,s.AddressPrimaryPlus4 AS s_AddressPrimaryPlus4  
	,s.AddressPrimaryCity AS s_AddressPrimaryCity  
	,s.AddressPrimaryState AS s_AddressPrimaryState  
	,s.AddressPrimaryZip AS s_AddressPrimaryZip  
	,s.AddressPrimaryCounty AS s_AddressPrimaryCounty  
	,s.AddressPrimaryCountry AS s_AddressPrimaryCountry  
	,s.AddressOneStreet AS s_AddressOneStreet  
	,s.AddressOneSuite AS s_AddressOneSuite  
	,s.AddressOnePlus4 AS s_AddressOnePlus4  
	,s.AddressOneCity AS s_AddressOneCity  
	,s.AddressOneState AS s_AddressOneState  
	,s.AddressOneZip AS s_AddressOneZip  
	,s.AddressOneCounty AS s_AddressOneCounty  
	,s.AddressOneCountry AS s_AddressOneCountry  
	,s.AddressTwoStreet AS s_AddressTwoStreet  
	,s.AddressTwoSuite AS s_AddressTwoSuite  
	,s.AddressTwoPlus4 AS s_AddressTwoPlus4  
	,s.AddressTwoCity AS s_AddressTwoCity  
	,s.AddressTwoState AS s_AddressTwoState  
	,s.AddressTwoZip AS s_AddressTwoZip  
	,s.AddressTwoCounty AS s_AddressTwoCounty  
	,s.AddressTwoCountry AS s_AddressTwoCountry  
	,s.AddressThreeStreet AS s_AddressThreeStreet  
	,s.AddressThreeSuite AS s_AddressThreeSuite  
	,s.AddressThreePlus4 AS s_AddressThreePlus4  
	,s.AddressThreeCity AS s_AddressThreeCity  
	,s.AddressThreeState AS s_AddressThreeState  
	,s.AddressThreeZip AS s_AddressThreeZip  
	,s.AddressThreeCounty AS s_AddressThreeCounty  
	,s.AddressThreeCountry AS s_AddressThreeCountry  
	,s.AddressFourStreet AS s_AddressFourStreet  
	,s.AddressFourSuite AS s_AddressFourSuite  
	,s.AddressFourPlus4 AS s_AddressFourPlus4  
	,s.AddressFourCity AS s_AddressFourCity  
	,s.AddressFourState AS s_AddressFourState  
	,s.AddressFourZip AS s_AddressFourZip  
	,s.AddressFourCounty AS s_AddressFourCounty  
	,s.AddressFourCountry AS s_AddressFourCountry  
	,s.EmailPrimary AS s_EmailPrimary  
	,s.EmailOne AS s_EmailOne  
	,s.EmailTwo AS s_EmailTwo  
	,s.PhonePrimary AS s_PhonePrimary  
	,s.PhoneCell AS s_PhoneCell  
	,s.PhoneHome AS s_PhoneHome  
	,s.PhoneBusiness AS s_PhoneBusiness  
	,s.PhoneFax AS s_PhoneFax  
	,s.PhoneOther AS s_PhoneOther  
  
	-- CLEAN DATA  
	,c.Prefix AS c_Prefix  
	,c.FirstName AS c_FirstName  
	,c.MiddleName AS c_MiddleName  
	,c.LastName AS c_LastName  
	,c.Suffix AS c_Suffix  
	,c.FullName AS c_FullName  
	,c.AddressPrimaryStreet AS c_AddressPrimaryStreet  
	,c.AddressPrimarySuite AS c_AddressPrimarySuite  
	,c.AddressPrimaryPlus4 AS c_AddressPrimaryPlus4  
	,c.AddressPrimaryCity AS c_AddressPrimaryCity  
	,c.AddressPrimaryState AS c_AddressPrimaryState  
	,c.AddressPrimaryZip AS c_AddressPrimaryZip  
	,c.AddressPrimaryCounty AS c_AddressPrimaryCounty  
	,c.AddressPrimaryCountry AS c_AddressPrimaryCountry  
	,c.AddressOneStreet AS c_AddressOneStreet  
	,c.AddressOneSuite AS c_AddressOneSuite  
	,c.AddressOnePlus4 AS c_AddressOnePlus4  
	,c.AddressOneCity AS c_AddressOneCity  
	,c.AddressOneState AS c_AddressOneState  
	,c.AddressOneZip AS c_AddressOneZip  
	,c.AddressOneCounty AS c_AddressOneCounty  
	,c.AddressOneCountry AS c_AddressOneCountry  
	,c.AddressTwoStreet AS c_AddressTwoStreet  
	,c.AddressTwoSuite AS c_AddressTwoSuite  
	,c.AddressTwoPlus4 AS c_AddressTwoPlus4  
	,c.AddressTwoCity AS c_AddressTwoCity  
	,c.AddressTwoState AS c_AddressTwoState  
	,c.AddressTwoZip AS c_AddressTwoZip  
	,c.AddressTwoCounty AS c_AddressTwoCounty  
	,c.AddressTwoCountry AS c_AddressTwoCountry  
	,c.AddressThreeStreet AS c_AddressThreeStreet  
	,c.AddressThreeSuite AS c_AddressThreeSuite  
	,c.AddressThreePlus4 AS c_AddressThreePlus4  
	,c.AddressThreeCity AS c_AddressThreeCity  
	,c.AddressThreeState AS c_AddressThreeState  
	,c.AddressThreeZip AS c_AddressThreeZip  
	,c.AddressThreeCounty AS c_AddressThreeCounty  
	,c.AddressThreeCountry AS c_AddressThreeCountry  
	,c.AddressFourStreet AS c_AddressFourStreet  
	,c.AddressFourSuite AS c_AddressFourSuite  
	,c.AddressFourPlus4 AS c_AddressFourPlus4  
	,c.AddressFourCity AS c_AddressFourCity  
	,c.AddressFourState AS c_AddressFourState  
	,c.AddressFourZip AS c_AddressFourZip  
	,c.AddressFourCounty AS c_AddressFourCounty  
	,c.AddressFourCountry AS c_AddressFourCountry  
	,c.EmailPrimary AS c_EmailPrimary  
	,c.EmailOne AS c_EmailOne  
	,c.EmailTwo AS c_EmailTwo  
	,c.PhonePrimary AS c_PhonePrimary  
	,c.PhoneCell AS c_PhoneCell  
	,c.PhoneHome AS c_PhoneHome  
	,c.PhoneBusiness AS c_PhoneBusiness  
	,c.PhoneFax AS c_PhoneFax  
	,c.PhoneOther AS c_PhoneOther  
  
	,c.NameIsCleanStatus  
	,c.AddressPrimaryIsCleanStatus  
	,c.AddressOneIsCleanStatus  
	,c.AddressTwoIsCleanStatus  
	,c.AddressThreeIsCleanStatus  
	,c.AddressFourIsCleanStatus  
	,c.EmailPrimaryIsCleanStatus  
	,c.EmailOneIsCleanStatus  
	,c.EmailTwoIsCleanStatus  
	,c.PhonePrimaryIsCleanStatus  
	,c.PhoneCellIsCleanStatus  
	,c.PhoneHomeIsCleanStatus  
	,c.PhoneBusinessIsCleanStatus  
	,c.PhoneFaxIsCleanStatus  
	,c.PhoneOtherIsCleanStatus  
  
	-- MASTER  
	,m.Prefix AS m_Prefix  
	,m.FirstName AS m_FirstName  
	,m.MiddleName AS m_MiddleName  
	,m.LastName AS m_LastName  
	,m.Suffix AS m_Suffix  
	,m.FullName AS m_FullName  
	,m.AddressPrimaryStreet AS m_AddressPrimaryStreet  
	,m.AddressPrimarySuite AS m_AddressPrimarySuite  
	,m.AddressPrimaryPlus4 AS m_AddressPrimaryPlus4  
	,m.AddressPrimaryCity AS m_AddressPrimaryCity  
	,m.AddressPrimaryState AS m_AddressPrimaryState  
	,m.AddressPrimaryZip AS m_AddressPrimaryZip  
	,m.AddressPrimaryCounty AS m_AddressPrimaryCounty  
	,m.AddressPrimaryCountry AS m_AddressPrimaryCountry  
	,m.AddressOneStreet AS m_AddressOneStreet  
	,m.AddressOneSuite AS m_AddressOneSuite  
	,m.AddressOnePlus4 AS m_AddressOnePlus4  
	,m.AddressOneCity AS m_AddressOneCity  
	,m.AddressOneState AS m_AddressOneState  
	,m.AddressOneZip AS m_AddressOneZip  
	,m.AddressOneCounty AS m_AddressOneCounty  
	,m.AddressOneCountry AS m_AddressOneCountry  
	,m.AddressTwoStreet AS m_AddressTwoStreet  
	,m.AddressTwoSuite AS m_AddressTwoSuite  
	,m.AddressTwoPlus4 AS m_AddressTwoPlus4  
	,m.AddressTwoCity AS m_AddressTwoCity  
	,m.AddressTwoState AS m_AddressTwoState  
	,m.AddressTwoZip AS m_AddressTwoZip  
	,m.AddressTwoCounty AS m_AddressTwoCounty  
	,m.AddressTwoCountry AS m_AddressTwoCountry  
	,m.AddressThreeStreet AS m_AddressThreeStreet  
	,m.AddressThreeSuite AS m_AddressThreeSuite  
	,m.AddressThreePlus4 AS m_AddressThreePlus4  
	,m.AddressThreeCity AS m_AddressThreeCity  
	,m.AddressThreeState AS m_AddressThreeState  
	,m.AddressThreeZip AS m_AddressThreeZip  
	,m.AddressThreeCounty AS m_AddressThreeCounty  
	,m.AddressThreeCountry AS m_AddressThreeCountry  
	,m.AddressFourStreet AS m_AddressFourStreet  
	,m.AddressFourSuite AS m_AddressFourSuite  
	,m.AddressFourPlus4 AS m_AddressFourPlus4  
	,m.AddressFourCity AS m_AddressFourCity  
	,m.AddressFourState AS m_AddressFourState  
	,m.AddressFourZip AS m_AddressFourZip  
	,m.AddressFourCounty AS m_AddressFourCounty  
	,m.AddressFourCountry AS m_AddressFourCountry  
	,m.EmailPrimary AS m_EmailPrimary  
	,m.EmailOne AS m_EmailOne  
	,m.EmailTwo AS m_EmailTwo  
	,m.PhonePrimary AS m_PhonePrimary  
	,m.PhoneCell AS m_PhoneCell  
	,m.PhoneHome AS m_PhoneHome  
	,m.PhoneBusiness AS m_PhoneBusiness  
	,m.PhoneFax AS m_PhoneFax  
	,m.PhoneOther AS m_PhoneOther  
  
FROM dbo.DimCustomer m -- MASTER  
INNER JOIN dbo.Source_DimCustomer s ON m.DimCustomerId = s.DimCustomerId -- SOURCE  
INNER JOIN dbo.CD_DimCustomer c ON m.SSID = c.SSID -- CLEAN DATA  
	AND m.SourceSystem = c.SourceSystem  
WHERE 1=1   
AND ( -- Master != Source  
	(HASHBYTES('SHA2_256',  
		-- Name  
		ISNULL(UPPER(m.Prefix),'NA')  
		+ISNULL(UPPER(m.FirstName),'NA')  
		+ISNULL(UPPER(m.MiddleName),'NA')  
		+ISNULL(UPPER(m.LastName),'NA')  
		+ISNULL(UPPER(m.Suffix),'NA')  
		+ISNULL(UPPER(m.FullName),'NA')  
  
		-- Address  
		+ISNULL(UPPER(m.AddressPrimaryStreet),'NA')  
		+ISNULL(UPPER(m.AddressPrimarySuite),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryPlus4),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryCity),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryState),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryZip),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryCounty),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryCountry),'NA')  
		+ISNULL(UPPER(m.AddressOneStreet),'NA')  
		+ISNULL(UPPER(m.AddressOneSuite),'NA')  
		+ISNULL(UPPER(m.AddressOnePlus4),'NA')  
		+ISNULL(UPPER(m.AddressOneCity),'NA')  
		+ISNULL(UPPER(m.AddressOneState),'NA')  
		+ISNULL(UPPER(m.AddressOneZip),'NA')  
		+ISNULL(UPPER(m.AddressOneCounty),'NA')  
		+ISNULL(UPPER(m.AddressOneCountry),'NA')	  
		+ISNULL(UPPER(m.AddressTwoStreet),'NA')  
		+ISNULL(UPPER(m.AddressTwoSuite),'NA')  
		+ISNULL(UPPER(m.AddressTwoPlus4),'NA')  
		+ISNULL(UPPER(m.AddressTwoCity),'NA')  
		+ISNULL(UPPER(m.AddressTwoState),'NA')  
		+ISNULL(UPPER(m.AddressTwoZip),'NA')  
		+ISNULL(UPPER(m.AddressTwoCounty),'NA')  
		+ISNULL(UPPER(m.AddressTwoCountry),'NA')  
		+ISNULL(UPPER(m.AddressThreeStreet),'NA')  
		+ISNULL(UPPER(m.AddressThreeSuite),'NA')  
		+ISNULL(UPPER(m.AddressThreePlus4),'NA')  
		+ISNULL(UPPER(m.AddressThreeCity),'NA')  
		+ISNULL(UPPER(m.AddressThreeState),'NA')  
		+ISNULL(UPPER(m.AddressThreeZip),'NA')  
		+ISNULL(UPPER(m.AddressThreeCounty),'NA')  
		+ISNULL(UPPER(m.AddressThreeCountry),'NA')	  
		+ISNULL(UPPER(m.AddressFourStreet),'NA')  
		+ISNULL(UPPER(m.AddressFourSuite),'NA')  
		+ISNULL(UPPER(m.AddressFourPlus4),'NA')  
		+ISNULL(UPPER(m.AddressFourCity),'NA')  
		+ISNULL(UPPER(m.AddressFourState),'NA')  
		+ISNULL(UPPER(m.AddressFourZip),'NA')  
		+ISNULL(UPPER(m.AddressFourCounty),'NA')  
		+ISNULL(UPPER(m.AddressFourCountry),'NA')									  
  
		-- Email  
		+ISNULL(UPPER(m.EmailPrimary),'NA')  
		+ISNULL(UPPER(m.EmailOne),'NA')  
		+ISNULL(UPPER(m.EmailTwo),'NA')  
		  
		-- Phone  
		+ISNULL(UPPER(m.PhonePrimary),'NA')  
		+ISNULL(UPPER(m.PhoneCell),'NA')  
		+ISNULL(UPPER(m.PhoneHome),'NA')  
		+ISNULL(UPPER(m.PhoneBusiness),'NA')  
		+ISNULL(UPPER(m.PhoneFax),'NA')  
		+ISNULL(UPPER(m.PhoneOther),'NA'))   
	!=   
	HASHBYTES('SHA2_256',  
		-- Name  
		ISNULL(UPPER(s.Prefix),'NA')  
		+ISNULL(UPPER(s.FirstName),'NA')  
		+ISNULL(UPPER(s.MiddleName),'NA')  
		+ISNULL(UPPER(s.LastName),'NA')  
		+ISNULL(UPPER(s.Suffix),'NA')  
		+ISNULL(UPPER(s.FullName),'NA')  
  
		-- Address  
		+ISNULL(UPPER(s.AddressPrimaryStreet),'NA')  
		+ISNULL(UPPER(s.AddressPrimarySuite),'NA')  
		+ISNULL(UPPER(s.AddressPrimaryPlus4),'NA')  
		+ISNULL(UPPER(s.AddressPrimaryCity),'NA')  
		+ISNULL(UPPER(s.AddressPrimaryState),'NA')  
		+ISNULL(UPPER(s.AddressPrimaryZip),'NA')  
		+ISNULL(UPPER(s.AddressPrimaryCounty),'NA')  
		+ISNULL(UPPER(s.AddressPrimaryCountry),'NA')  
		+ISNULL(UPPER(s.AddressOneStreet),'NA')  
		+ISNULL(UPPER(s.AddressOneSuite),'NA')  
		+ISNULL(UPPER(s.AddressOnePlus4),'NA')  
		+ISNULL(UPPER(s.AddressOneCity),'NA')  
		+ISNULL(UPPER(s.AddressOneState),'NA')  
		+ISNULL(UPPER(s.AddressOneZip),'NA')  
		+ISNULL(UPPER(s.AddressOneCounty),'NA')  
		+ISNULL(UPPER(s.AddressOneCountry),'NA')	  
		+ISNULL(UPPER(s.AddressTwoStreet),'NA')  
		+ISNULL(UPPER(s.AddressTwoSuite),'NA')  
		+ISNULL(UPPER(s.AddressTwoPlus4),'NA')  
		+ISNULL(UPPER(s.AddressTwoCity),'NA')  
		+ISNULL(UPPER(s.AddressTwoState),'NA')  
		+ISNULL(UPPER(s.AddressTwoZip),'NA')  
		+ISNULL(UPPER(s.AddressTwoCounty),'NA')  
		+ISNULL(UPPER(s.AddressTwoCountry),'NA')  
		+ISNULL(UPPER(s.AddressThreeStreet),'NA')  
		+ISNULL(UPPER(s.AddressThreeSuite),'NA')  
		+ISNULL(UPPER(s.AddressThreePlus4),'NA')  
		+ISNULL(UPPER(s.AddressThreeCity),'NA')  
		+ISNULL(UPPER(s.AddressThreeState),'NA')  
		+ISNULL(UPPER(s.AddressThreeZip),'NA')  
		+ISNULL(UPPER(s.AddressThreeCounty),'NA')  
		+ISNULL(UPPER(s.AddressThreeCountry),'NA')	  
		+ISNULL(UPPER(s.AddressFourStreet),'NA')  
		+ISNULL(UPPER(s.AddressFourSuite),'NA')  
		+ISNULL(UPPER(s.AddressFourPlus4),'NA')  
		+ISNULL(UPPER(s.AddressFourCity),'NA')  
		+ISNULL(UPPER(s.AddressFourState),'NA')  
		+ISNULL(UPPER(s.AddressFourZip),'NA')  
		+ISNULL(UPPER(s.AddressFourCounty),'NA')  
		+ISNULL(UPPER(s.AddressFourCountry),'NA')		  
  
		-- Email  
		+ISNULL(UPPER(s.EmailPrimary),'NA')  
		+ISNULL(UPPER(s.EmailOne),'NA')  
		+ISNULL(UPPER(s.EmailTwo),'NA')  
		  
		-- Phone  
		+ISNULL(UPPER(s.PhonePrimary),'NA')  
		+ISNULL(UPPER(s.PhoneCell),'NA')  
		+ISNULL(UPPER(s.PhoneHome),'NA')  
		+ISNULL(UPPER(s.PhoneBusiness),'NA')  
		+ISNULL(UPPER(s.PhoneFax),'NA')  
		+ISNULL(UPPER(s.PhoneOther),'NA'))  
	)   
	OR -- Master != Clean Data  
	(HASHBYTES('SHA2_256',  
		-- Name  
		ISNULL(UPPER(m.Prefix),'NA')  
		+ISNULL(UPPER(m.FirstName),'NA')  
		+ISNULL(UPPER(m.MiddleName),'NA')  
		+ISNULL(UPPER(m.LastName),'NA')  
		+ISNULL(UPPER(m.Suffix),'NA')  
		+ISNULL(UPPER(m.FullName),'NA')  
  
		-- Address  
		+ISNULL(UPPER(m.AddressPrimaryStreet),'NA')  
		+ISNULL(UPPER(m.AddressPrimarySuite),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryPlus4),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryCity),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryState),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryZip),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryCounty),'NA')  
		+ISNULL(UPPER(m.AddressPrimaryCountry),'NA')  
		+ISNULL(UPPER(m.AddressOneStreet),'NA')  
		+ISNULL(UPPER(m.AddressOneSuite),'NA')  
		+ISNULL(UPPER(m.AddressOnePlus4),'NA')  
		+ISNULL(UPPER(m.AddressOneCity),'NA')  
		+ISNULL(UPPER(m.AddressOneState),'NA')  
		+ISNULL(UPPER(m.AddressOneZip),'NA')  
		+ISNULL(UPPER(m.AddressOneCounty),'NA')  
		+ISNULL(UPPER(m.AddressOneCountry),'NA')	  
		+ISNULL(UPPER(m.AddressTwoStreet),'NA')  
		+ISNULL(UPPER(m.AddressTwoSuite),'NA')  
		+ISNULL(UPPER(m.AddressTwoPlus4),'NA')  
		+ISNULL(UPPER(m.AddressTwoCity),'NA')  
		+ISNULL(UPPER(m.AddressTwoState),'NA')  
		+ISNULL(UPPER(m.AddressTwoZip),'NA')  
		+ISNULL(UPPER(m.AddressTwoCounty),'NA')  
		+ISNULL(UPPER(m.AddressTwoCountry),'NA')  
		+ISNULL(UPPER(m.AddressThreeStreet),'NA')  
		+ISNULL(UPPER(m.AddressThreeSuite),'NA')  
		+ISNULL(UPPER(m.AddressThreePlus4),'NA')  
		+ISNULL(UPPER(m.AddressThreeCity),'NA')  
		+ISNULL(UPPER(m.AddressThreeState),'NA')  
		+ISNULL(UPPER(m.AddressThreeZip),'NA')  
		+ISNULL(UPPER(m.AddressThreeCounty),'NA')  
		+ISNULL(UPPER(m.AddressThreeCountry),'NA')	  
		+ISNULL(UPPER(m.AddressFourStreet),'NA')  
		+ISNULL(UPPER(m.AddressFourSuite),'NA')  
		+ISNULL(UPPER(m.AddressFourPlus4),'NA')  
		+ISNULL(UPPER(m.AddressFourCity),'NA')  
		+ISNULL(UPPER(m.AddressFourState),'NA')  
		+ISNULL(UPPER(m.AddressFourZip),'NA')  
		+ISNULL(UPPER(m.AddressFourCounty),'NA')  
		+ISNULL(UPPER(m.AddressFourCountry),'NA')  
		  
		-- Email  
		+ISNULL(UPPER(m.EmailPrimary),'NA')  
		+ISNULL(UPPER(m.EmailOne),'NA')  
		+ISNULL(UPPER(m.EmailTwo),'NA')  
		  
		-- Phone  
		+ISNULL(UPPER(m.PhonePrimary),'NA')  
		+ISNULL(UPPER(m.PhoneCell),'NA')  
		+ISNULL(UPPER(m.PhoneHome),'NA')  
		+ISNULL(UPPER(m.PhoneBusiness),'NA')  
		+ISNULL(UPPER(m.PhoneFax),'NA')  
		+ISNULL(UPPER(m.PhoneOther),'NA'))   
		!=   
		HASHBYTES('SHA2_256',  
		-- Name  
		ISNULL(UPPER(c.Prefix),'NA')  
		+ISNULL(UPPER(c.FirstName),'NA')  
		+ISNULL(UPPER(c.MiddleName),'NA')  
		+ISNULL(UPPER(c.LastName),'NA')  
		+ISNULL(UPPER(c.Suffix),'NA')  
		+ISNULL(UPPER(c.FullName),'NA')  
		  
		-- Address  
		+ISNULL(UPPER(c.AddressPrimaryStreet),'NA')  
		+ISNULL(UPPER(c.AddressPrimarySuite),'NA')  
		+ISNULL(UPPER(c.AddressPrimaryPlus4),'NA')  
		+ISNULL(UPPER(c.AddressPrimaryCity),'NA')  
		+ISNULL(UPPER(c.AddressPrimaryState),'NA')  
		+ISNULL(UPPER(c.AddressPrimaryZip),'NA')  
		+ISNULL(UPPER(c.AddressPrimaryCounty),'NA')  
		+ISNULL(UPPER(c.AddressPrimaryCountry),'NA')  
		+ISNULL(UPPER(c.AddressOneStreet),'NA')  
		+ISNULL(UPPER(c.AddressOneSuite),'NA')  
		+ISNULL(UPPER(c.AddressOnePlus4),'NA')  
		+ISNULL(UPPER(c.AddressOneCity),'NA')  
		+ISNULL(UPPER(c.AddressOneState),'NA')  
		+ISNULL(UPPER(c.AddressOneZip),'NA')  
		+ISNULL(UPPER(c.AddressOneCounty),'NA')  
		+ISNULL(UPPER(c.AddressOneCountry),'NA')	  
		+ISNULL(UPPER(c.AddressTwoStreet),'NA')  
		+ISNULL(UPPER(c.AddressTwoSuite),'NA')  
		+ISNULL(UPPER(c.AddressTwoPlus4),'NA')  
		+ISNULL(UPPER(c.AddressTwoCity),'NA')  
		+ISNULL(UPPER(c.AddressTwoState),'NA')  
		+ISNULL(UPPER(c.AddressTwoZip),'NA')  
		+ISNULL(UPPER(c.AddressTwoCounty),'NA')  
		+ISNULL(UPPER(c.AddressTwoCountry),'NA')  
		+ISNULL(UPPER(c.AddressThreeStreet),'NA')  
		+ISNULL(UPPER(c.AddressThreeSuite),'NA')  
		+ISNULL(UPPER(c.AddressThreePlus4),'NA')  
		+ISNULL(UPPER(c.AddressThreeCity),'NA')  
		+ISNULL(UPPER(c.AddressThreeState),'NA')  
		+ISNULL(UPPER(c.AddressThreeZip),'NA')  
		+ISNULL(UPPER(c.AddressThreeCounty),'NA')  
		+ISNULL(UPPER(c.AddressThreeCountry),'NA')	  
		+ISNULL(UPPER(c.AddressFourStreet),'NA')  
		+ISNULL(UPPER(c.AddressFourSuite),'NA')  
		+ISNULL(UPPER(c.AddressFourPlus4),'NA')  
		+ISNULL(UPPER(c.AddressFourCity),'NA')  
		+ISNULL(UPPER(c.AddressFourState),'NA')  
		+ISNULL(UPPER(c.AddressFourZip),'NA')  
		+ISNULL(UPPER(c.AddressFourCounty),'NA')  
		+ISNULL(UPPER(c.AddressFourCountry),'NA')  
		  
		-- Email  
		+ISNULL(UPPER(c.EmailPrimary),'NA')  
		+ISNULL(UPPER(c.EmailOne),'NA')  
		+ISNULL(UPPER(c.EmailTwo),'NA')  
		  
		-- Phone  
		+ISNULL(UPPER(c.PhonePrimary),'NA')  
		+ISNULL(UPPER(c.PhoneCell),'NA')  
		+ISNULL(UPPER(c.PhoneHome),'NA')  
		+ISNULL(UPPER(c.PhoneBusiness),'NA')  
		+ISNULL(UPPER(c.PhoneFax),'NA')  
		+ISNULL(UPPER(c.PhoneOther),'NA'))  
	)  
)  
 
GO
