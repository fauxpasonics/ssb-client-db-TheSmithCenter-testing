SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROC [api].[GetElementsAndCriteria]
AS
BEGIN
	SET NOCOUNT Off;
	-- Init
	DECLARE @totalCount    INT,
		@xmlDataNode       XML,
		@rootNodeName      NVARCHAR(100),
		@responseInfoNode  NVARCHAR(MAX),
		@finalXml          XML
			
	DECLARE @baseData TABLE (
		ElementID                    INT,
		ElementName                  NVARCHAR(50),
		ElementType                  NVARCHAR(50),
		ElementIsCustom              BIT,
		ElementDisplayOrder          INT,
		CriteriaID                   INT,
		CriteriaName                 NVARCHAR(100),
		CriteriaDescription          NVARCHAR(MAX),
		CriteriaDefaultDisplayOrder  INT,
		HasConfiguration             BIT,
		HasPriority                  BIT,
		[Priority]                   INT
	)


	-- Load base data with the data needed for the response

	INSERT INTO @baseData
	(ElementID, ElementName, ElementType, ElementIsCustom, ElementDisplayOrder, 
	 CriteriaID, CriteriaName, CriteriaDescription, CriteriaDefaultDisplayOrder, 
	 HasConfiguration, HasPriority, [Priority])
	SELECT
		e.ElementID, e.Element AS ElementName, e.ElementType, e.Custom AS ElementIsCustom, null AS ElementDisplayOrder,
		c.CriteriaID, c.Criteria AS CriteriaName, c.[Description] AS CriteriaDescription, c.DefaultDisplayOrder AS CriteriaDefaultDisplayOrder,
		c.Custom as HasConfiguration, 
		CASE WHEN cbr.[priority] IS NULL THEN 0 ELSE 1 END AS HasPriority,
		ISNULL(cbr.[priority], 0) AS [Priority]
	FROM mdm.Element e
		CROSS JOIN mdm.Criteria c
		LEFT OUTER JOIN mdm.BusinessRules cbr ON e.ElementID = cbr.ElementID AND c.CriteriaID = cbr.CriteriaID
	WHERE 1 = 1

	
	----For Troublshooting:  this query shows the base data in the proper order:

	--SELECT
	--	ElementID, ElementName, ElementType, ElementIsCustom, ElementDisplayOrder,
	--	CriteriaID, CriteriaName, CriteriaDescription, HasConfiguration, [Priority]
	--FROM @baseData
	--ORDER BY ElementDisplayOrder, HasPriority DESC, [Priority], CriteriaDefaultDisplayOrder
		
	
	-- Set count of total records in response

	SELECT @totalCount = COUNT(*) FROM @baseData
	

	-- Create XML response data node

	SET @xmlDataNode = (SELECT e.ElementID, e.ElementName, e.ElementType, e.ElementIsCustom, e.ElementDisplayOrder,
		(SELECT c.CriteriaID, c.CriteriaName, c.CriteriaDescription, c.HasConfiguration, c.HasPriority, c.[Priority], c.CriteriaDefaultDisplayOrder
		FROM @baseData AS c
		WHERE e.ElementId = c.ElementId
		GROUP BY c.CriteriaID, c.CriteriaName, c.CriteriaDescription, c.HasConfiguration, c.HasPriority, c.[Priority], c.CriteriaDefaultDisplayOrder
		ORDER BY c.HasPriority DESC, c.[Priority], c.CriteriaDefaultDisplayOrder
		FOR XML PATH ('Criterion'), TYPE) AS 'Criteria'
	FROM @baseData AS e
	GROUP BY e.ElementId, e.ElementName, e.ElementType, e.ElementIsCustom, e.ElementDisplayOrder
	ORDER BY e.ElementDisplayOrder
	FOR XML PATH ('Element'), ROOT('Elements'))
	

	SET @rootNodeName = 'Elements'
	

	-- Create response info node

	SET @responseInfoNode = ('<ResponseInfo>'
		+ '<TotalCount>' + CAST(@totalCount AS NVARCHAR(20)) + '</TotalCount>'
		+ '<RemainingCount>0</RemainingCount>'  -- No paging = remaining count = 0
		+ '<RecordsInResponse>' + CAST(@totalCount AS NVARCHAR(20)) + '</RecordsInResponse>'  -- No paging = remaining count = total count
		+ '<PagedResponse>false</PagedResponse>'
		+ '<RowsPerPage />'
		+ '<PageNumber />'
		+ '<RootNodeName>' + @rootNodeName + '</RootNodeName>'
		+ '</ResponseInfo>')

	
	-- Wrap response info and data, then return
	
	IF @xmlDataNode IS NULL
	BEGIN
		SET @xmlDataNode = '<' + @rootNodeName + ' />' 
	END
		
	SET @finalXml = '<Root>' + @responseInfoNode + CAST(@xmlDataNode AS NVARCHAR(MAX)) + '</Root>'

	SELECT CAST(@finalXml AS XML)

END
 
GO
