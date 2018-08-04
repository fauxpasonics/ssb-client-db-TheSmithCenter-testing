CREATE TABLE [mdm].[MatchkeyConfig]
(
[MatchkeyID] [int] NOT NULL IDENTITY(1, 1),
[MatchkeyName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MatchKeyType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MatchkeyPreSql] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchkeyBaseTblFieldList] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MatchkeyBaseTbl] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MatchkeyBaseTblLookupCondition] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchkeyBaseTblLookupFieldList] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchkeyBaseTblHashSql] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MatchkeyHashIdentifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [bit] NULL CONSTRAINT [DF_MatchkeyConfig_Active] DEFAULT ((0)),
[InsertDate] [datetime] NOT NULL CONSTRAINT [DF_MatchkeyConfig_InsertDate] DEFAULT (getdate()),
[UpdateDate] [datetime] NULL CONSTRAINT [DF_MatchkeyConfig_UpdateDate] DEFAULT (getdate()),
[ActivateDate] [datetime] NULL,
[DeactivateDate] [datetime] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MatchkeyConfig_CreatedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
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
CREATE TRIGGER [mdm].[trg_MatchkeyConfig_Update_Insert]    
ON [mdm].[MatchkeyConfig]    
AFTER UPDATE, INSERT    
AS     
BEGIN    
	SET NOCOUNT ON     
    
	DECLARE @action CHAR(1), @currentDatetime DATETIME = CURRENT_TIMESTAMP    
    
    --    
    -- Check if this is an INSERT, UPDATE or DELETE Action.    
    --     
    SET @action = 'I'; -- Set Action to Insert by default.    
    IF EXISTS(SELECT * FROM Deleted)    
    BEGIN    
        SET @action =     
            CASE    
                WHEN EXISTS(SELECT * FROM Inserted) THEN 'U' -- Set Action to Updated.    
                ELSE 'D' -- Set Action to Deleted.           
            END    
    END    
    ELSE IF NOT EXISTS(SELECT * FROM Inserted)     
		RETURN; -- Nothing updated or inserted.    
    
	IF @action = 'I'    
	BEGIN    
		UPDATE mdm.MatchkeyConfig    
		SET ActivateDate = CASE WHEN i.Active = 1 THEN i.InsertDate ELSE NULL END    
			, CreatedBy = SYSTEM_USER 
			, UpdateDate = NULL 
			, UpdatedBy = NULL 
		--SELECT *     
		FROM mdm.MatchkeyConfig a    
		INNER JOIN Inserted i ON a.MatchkeyID = i.MatchkeyID    
	END    
	ELSE IF @action = 'U'-- AND NOT UPDATE(InsertDate)   
	BEGIN    
		IF UPDATE(Active)    
			UPDATE mdm.MatchkeyConfig    
			SET ActivateDate = CASE WHEN i.Active = 1 THEN @currentDatetime ELSE i.ActivateDate END    
				, DeactivateDate = CASE WHEN i.Active = 0 THEN @currentDatetime ELSE i.DeactivateDate END    
				, UpdateDate = @currentDatetime 
				, UpdatedBy = SYSTEM_USER    
			FROM mdm.MatchkeyConfig a    
			INNER JOIN Inserted i ON a.MatchkeyID = i.MatchkeyID    
			INNER JOIN Deleted d ON i.MatchkeyID = d.MatchkeyID    
			WHERE 1=1    
			AND i.Active != d.Active    
    
		IF (UPDATE(MatchkeyPreSql)    
			OR UPDATE(MatchkeyBaseTblFieldList)     
			OR UPDATE(MatchkeyBaseTbl)     
			OR UPDATE(MatchkeyBaseTblLookupCondition)     
			OR UPDATE(MatchkeyBaseTblLookupFieldList)     
			OR UPDATE(MatchkeyBaseTblHashSql)     
			OR UPDATE(MatchkeyHashIdentifier))    
		BEGIN    
			UPDATE mdm.MatchkeyConfig    
			SET UpdateDate = @currentDatetime 
				, UpdatedBy = SYSTEM_USER   
			FROM mdm.MatchkeyConfig a    
			INNER JOIN Inserted i ON a.MatchkeyID = i.MatchkeyID    
			INNER JOIN Deleted d ON i.MatchkeyID = d.MatchkeyID    
			WHERE 1=1    
			AND (ISNULL(i.MatchkeyPreSql,'') != ISNULL(d.MatchkeyPreSql,'')    
				OR ISNULL(i.MatchkeyID,'') != ISNULL(d.MatchkeyID,'')    
				OR ISNULL(i.MatchkeyBaseTblFieldList,'') != ISNULL(d.MatchkeyBaseTblFieldList,'')    
				OR ISNULL(i.MatchkeyBaseTbl,'') != ISNULL(d.MatchkeyBaseTbl,'')    
				OR ISNULL(i.MatchkeyBaseTblLookupCondition,'') != ISNULL(d.MatchkeyBaseTblLookupCondition,'')    
				OR ISNULL(i.MatchkeyBaseTblLookupFieldList,'') != ISNULL(d.MatchkeyBaseTblLookupFieldList,'')    
				OR ISNULL(i.MatchkeyBaseTblHashSql,'') != ISNULL(d.MatchkeyBaseTblHashSql,'')    
				OR ISNULL(i.MatchkeyHashIdentifier,'') != ISNULL(d.MatchkeyHashIdentifier,'')    
			)    
		END    
	END    
    
	IF OBJECT_ID('tempdb..#cdFields') IS NOT NULL    
		DROP TABLE #cdFields    
    
	;WITH fieldlist AS (    
		SELECT (STUFF((    
		SELECT DISTINCT ',' + REPLACE(ElementFieldList,'dimcust.','')    
		FROM mdm.Element    
		WHERE 1=1    
		AND ElementIsCleanField IS NOT NULL    
		AND ElementType = 'Standard'    
		FOR XML PATH('')), 1, 1, '')) + ', ContactGUID' AS fieldList    
	)    
	SELECT fieldName    
	INTO #cdFields    
	FROM (    
		SELECT DISTINCT LTRIM(RTRIM(Split.a.value('.', 'VARCHAR(100)'))) AS fieldName    
		FROM (	    
			SELECT CAST ('<M>' + REPLACE(fieldList, ',', '</M><M>') + '</M>' AS XML) AS Data      
			FROM fieldlist    
		) AS A CROSS APPLY Data.nodes ('/M') AS Split(a)    
	) a    
	WHERE ISNULL(a.fieldName,'') != ''    
    
	IF OBJECT_ID('tempdb..#matchkeyFields') IS NOT NULL    
		DROP TABLE #matchkeyFields    
    
	;WITH fieldlist AS (    
		SELECT DISTINCT a.MatchkeyID, a.MatchkeyBaseTblFieldList as fieldList    
		FROM mdm.MatchkeyConfig a    
		INNER JOIN Inserted b ON a.MatchkeyID = b.MatchkeyID    
		WHERE (a.MatchkeyBaseTbl LIKE '%dbo.DimCustomer%' OR a.MatchkeyPreSql LIKE '%dbo.DimCustomer%')    
	)    
	SELECT a.MatchkeyId, fieldName    
	INTO #matchkeyFields    
	FROM (    
		SELECT DISTINCT a.MatchkeyID, LTRIM(RTRIM(Split.a.value('.', 'VARCHAR(100)'))) AS fieldName    
		FROM (	    
			SELECT MatchkeyID, CAST ('<M>' + REPLACE(fieldList, '||', '</M><M>') + '</M>' AS XML) AS Data      
			FROM fieldlist    
		) AS A CROSS APPLY Data.nodes ('/M') AS Split(a)    
	) a    
	INNER JOIN mdm.MatchkeyConfig b ON a.MatchkeyID = b.MatchkeyID    
	WHERE 1=1    
	AND ISNULL(a.fieldName,'') != ''    
	AND CHARINDEX(a.fieldName, b.MatchkeyBaseTblHashSql) > 0    
    
	IF OBJECT_ID('tempdb..#nonstandardFields') IS NOT NULL    
		DROP TABLE #nonstandardFields    
    
	;WITH nonstandardFields AS (    
		SELECT a.MatchkeyID, a.fieldName    
		FROM #matchkeyFields a    
		LEFT JOIN #cdFields b ON a.fieldName = b.fieldName    
		WHERE 1=1    
		AND b.fieldName IS NULL    
	)    
	SELECT a.MatchkeyID, (STUFF((    
		SELECT ',' + b.fieldName    
		FROM nonstandardFields b    
		WHERE b.MatchkeyID = a.MatchkeyID    
		FOR XML PATH('')), 1, 1, '')) AS fieldList    
	INTO #nonstandardFields    
	FROM nonstandardFields a    
	GROUP BY a.MatchkeyID    
    
	DECLARE @warning NVARCHAR(MAX) = 'Warning! The following matchkeys reference one or more non-standard/non-cleansed fields, meaning they will not be detected by the recognition process.' + CHAR(10)    
		+ 'To ensure inclusion, please verify an AFTER UPDATE trigger exists on the non-standard fields referenced by the matchkey to update dbo.DimCustomer.matchkey_updatedate accordingly (see matchkey_updated trigger for example)...' + CHAR(10) + CHAR(10)    
    
	;WITH cte AS (    
		SELECT a.MatchkeyID, AVG(CASE WHEN b.fieldName IS NOT NULL THEN 1 ELSE 0 END) AS cdFieldIncluded    
		FROM #matchkeyFields a    
		LEFT JOIN #cdFields b ON a.fieldName = b.fieldName    
		GROUP BY a.MatchkeyID    
	)    
	SELECT @warning = @warning     
	+ CASE     
		WHEN (SELECT COUNT(0) FROM cte a WHERE a.cdFieldIncluded != 1) = 0 THEN NULL     
		ELSE (    
			SELECT ' (' + CAST(b.MatchkeyID AS VARCHAR(5)) + ') ' + b.MatchkeyName + ' - ' + c.fieldList + CHAR(10)     
			FROM cte a     
			INNER JOIN mdm.MatchkeyConfig b ON a.MatchkeyID = b.MatchkeyID     
			INNER JOIN #nonstandardFields c ON a.MatchkeyID = c.MatchkeyID    
			WHERE a.cdFieldIncluded = 0 FOR XML PATH(''))    
	END    
	    
	----SELECT * FROM #matchkeyFields    
	----SELECT * FROM #cdFields    
	----SELECT * FROM #nonstandardFields    
    
	IF ISNULL(@warning,'') != ''    
		PRINT @warning    
  
END
GO
ALTER TABLE [mdm].[MatchkeyConfig] ADD CONSTRAINT [PK_MatchkeyConfig_MatchkeyID] PRIMARY KEY NONCLUSTERED  ([MatchkeyID]) WITH (DATA_COMPRESSION = PAGE)
GO
CREATE CLUSTERED INDEX [IX_MatchkeyConfig_MatchkeyID] ON [mdm].[MatchkeyConfig] ([MatchkeyID]) WITH (DATA_COMPRESSION = PAGE)
GO
