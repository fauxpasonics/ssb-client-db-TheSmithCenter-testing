SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROC [segmentation].[SegmentationDataset]
    @TenantId VARCHAR(50),
    @ViewName sysname,
    @IDColumn sysname,
    @JoinColumn sysname,
    @AddSK BIT,
    @DocumentType VARCHAR(50),
    @SessionId VARCHAR(50),
    @Environment VARCHAR(50),
    @GetVersion BIT = 0,
    @Init BIT = 0,
    @getschema BIT = 0,
    @getCounts BIT = 0,
    @finalize BIT = 0,
    @RowsPerPage INT = 1000,
    @PageNumber INT = 1,
    @Debug BIT = 0,
    @UniverseDataProvider VARCHAR(20) = 'DocumentDb',
    @AdditionalIndexJSON VARCHAR(MAX) = ''
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Version VARCHAR(10) = '2.0'

    SET NOCOUNT ON;
    DECLARE @temptableschemaraw sysname = 'segmentation';
    DECLARE @temptableschema sysname = '[' + @temptableschemaraw + ']';

    DECLARE @temptableraw NVARCHAR(100) = 'SegmentationFlatData' + @SessionId;
    DECLARE @temptable NVARCHAR(100) = '[' + @temptableraw + ']';

    DECLARE @temptablefull NVARCHAR(300) = @temptableschema + '.' + @temptable;
    --print (@temptableSchema)
    --PRINT(@temptable)
    --CREATE TABLE seglog (logmsg VARCHAR(MAX))
    INSERT INTO segmentation.seglog
    (
        logmsg,
        sessionid
    )
    VALUES
    ('msg0 - tbl created', @SessionId -- logmsg - varchar(max)
    );
    IF (@GetVersion = 1)
    BEGIN
        SELECT @Version;
    END;
    ELSE IF (@Init = 1)
    BEGIN
        IF NOT EXISTS
        (
            SELECT *
            FROM sys.objects
            WHERE object_id = OBJECT_ID(@temptablefull)
        )
        BEGIN
            DECLARE @temptablesqlselectclause NVARCHAR(MAX) = 'select ';
            --declare @temptablesql nvarchar(max)='select top 100 '  -- ***** FOR TROUBLESHOOTING ONLY *****
            IF (@AddSK = 1)
            BEGIN
                SET @temptablesqlselectclause = @temptablesqlselectclause + ' newid() id,';
            END;


            SET @temptablesqlselectclause
                = @temptablesqlselectclause + '''' + @DocumentType + ''' DocumentType,' + '''' + UPPER(@SessionId)
                  + ''' SessionId,' + '''' + @Environment + ''' Environment,' + '''' + UPPER(@TenantId)
                  + ''' TenantId,';

            IF (@UniverseDataProvider = 'DocumentDb')
                SET @temptablesqlselectclause
                    = @temptablesqlselectclause + ' ROW_NUMBER() OVER ( ORDER BY NEWID() ) _rn,';

            SET @temptablesqlselectclause = @temptablesqlselectclause + '*';

            DECLARE @temptablesqlintoclause NVARCHAR(MAX) = ' into ' + @temptablefull;
            DECLARE @temptablesqlfromclause NVARCHAR(MAX) = ' from ' + @ViewName;

            DECLARE @temptablesql NVARCHAR(MAX)
                = @temptablesqlselectclause + @temptablesqlintoclause + @temptablesqlfromclause;
            DECLARE @temptablesqlinsert NVARCHAR(MAX)
                = 'INSERT INTO ' + @temptablefull + ' ' + @temptablesqlselectclause + @temptablesqlfromclause;

            IF (@Debug = 1)
            BEGIN
                PRINT '--- SELECT INTO ----';
                PRINT @temptablesql;
                PRINT '--- INSERT ---';
                PRINT @temptablesqlinsert;
            END;

            ELSE
            BEGIN
                INSERT INTO segmentation.seglog
                (
                    logmsg,
                    sessionid
                )
                VALUES
                ('msg1 - b4DocumentDb', @SessionId -- logmsg - varchar(max)
                );


                IF (@UniverseDataProvider = 'DocumentDb')
                BEGIN
                    EXEC sp_executesql @temptablesql;
                    DECLARE @fixcolumnsql NVARCHAR(MAX)
                        = 'alter table ' + @temptablefull + ' alter column ID uniqueidentifier not null';
                    EXEC sp_executesql @fixcolumnsql;
                    DECLARE @pksql NVARCHAR(MAX)
                        = 'alter table ' + @temptablefull + ' add CONSTRAINT [pk_' + @temptableraw
                          + '] primary key nonclustered (id)';
                    EXEC sp_executesql @pksql;
                    DECLARE @rnindexsql NVARCHAR(MAX)
                        = 'create clustered index [cix_' + @temptableraw + '] on ' + @temptablefull + '(_rn)';
                    EXEC sp_executesql @rnindexsql;
                END;
                ELSE IF (@UniverseDataProvider = 'Sql')
                BEGIN
                    

                    DECLARE @emptytablesql NVARCHAR(MAX) = (@temptablesql + ' Where 1=2');
					INSERT INTO segmentation.seglog
                    (
                        logmsg,
                        sessionid
                    )
                    VALUES
                    ('msg2-before 1=2:' + @emptytablesql, @SessionId -- logmsg - varchar(max)
                    );
                    EXEC sp_executesql @emptytablesql; --create the empty table first
                    --ADD clustered columnstorindex TODO: Should we create an empty table and add the columnstore index first?
                    --Guidance at https://docs.microsoft.com/en-us/sql/relational-databases/indexes/columnstore-indexes-data-loading-guidance?view=sql-server-2017
                    DECLARE @createcolumnstoreindex NVARCHAR(MAX)
                        = 'CREATE CLUSTERED COLUMNSTORE INDEX [ccix_' + @temptableraw + '] on ' + @temptablefull;
                    INSERT INTO segmentation.seglog
                    (
                        logmsg,
                        sessionid
                    )
                    VALUES
                    (   'msg3-before clustered: ' + @createcolumnstoreindex, -- logmsg - varchar(max)
                        @SessionId                                           -- sessionid - nvarchar(50)
                    );
                    EXEC sys.sp_executesql @createcolumnstoreindex;
                    INSERT INTO segmentation.seglog
                    (
                        logmsg,
                        sessionid
                    )
                    VALUES
                    (   'msg3-before insert', -- logmsg - varchar(max)
                        @SessionId            -- sessionid - nvarchar(50)
                    );
                    EXEC sp_executesql @temptablesqlinsert;
                    INSERT INTO segmentation.seglog
                    (
                        logmsg,
                        sessionid
                    )
                    VALUES
                    (   'msg3-after-insert', -- logmsg - varchar(max)
                        @SessionId           -- sessionid - nvarchar(50)
                    );
                --TODO: Create additional indexes based on index settings that were passed into the sproc
                --With Data Compression should be added.(Page)
                --DECLARE @json NVARCHAR(MAX) = '{"indexes":[{"name":"primarycustomer_id_name_address","unique":true,"columns":"id,name,address","includecolumns":"","filter":""},{"name":"primarycustomer_name_address","unique":false,"columns":"name,address","includecolumns":"id","filter":""}]}'
                --SELECT *
                --INTO #AdditionalIndexJSON 
                --FROM OPENJSON(@json,'$.indexes')
                --WITH(name VARCHAR(200) '$.name',IsUNIQUE bit '$.unique',indexColumns VARCHAR(200) '$.columns',includeColumns VARCHAR(200) '$.includecolumns',filter VARCHAR(200) '$.filter')
                ----DROP TABLE #AdditionalIndexJSON
                --SELECT * FROM #AdditionalIndexJSON
                END;
                ELSE
                BEGIN
                    DECLARE @ErrorMessage VARCHAR(200) = 'Bad DataProvider-' + @UniverseDataProvider;
                    RAISERROR(@ErrorMessage, 10, 1);
                    RETURN;
                END;

                INSERT INTO segmentation.seglog
                (
                    logmsg,
                    sessionid
                )
                VALUES
                ('msg3 - before non-xml', @SessionId -- logmsg - varchar(max)
                );
                --TODO: Get count in more efficient manner and return non-xml results
                SELECT SUM(rows) [count],@temptable [tablename], UPPER(@SessionId) session
				FROM sys.partitions WHERE index_id IN (0,1)
				AND object_id=OBJECT_ID(@temptablefull)
				FOR XML AUTO
                
				--DECLARE @rtrnsql NVARCHAR(MAX)
    --                = 'select sum(count) count, ''' + @temptable + ''' tablename,''' + UPPER(@SessionId)
    --                  + ''' session from (select 1 count from ' + @temptableschema + '.' + @temptable
    --                  + ' group by  Id) tbl for xml auto';
				
				--INSERT INTO segmentation.seglog
				--(
				--    logmsg,
				--    sessionid
				--)
				--VALUES
				--(   'RTRNSQL:' + @rtrnsql, -- logmsg - varchar(max)
				--    @SessionId -- sessionid - nvarchar(50)
				--)
				--BEGIN TRY
				--    EXEC (@rtrnsql);
				--END TRY
				--BEGIN CATCH
				--    INSERT dbo.seglog
				--    (
				--        logmsg,
				--        sessionid
				--    )
				--    VALUES
				--    (   'Error:' + @@ERROR, -- logmsg - varchar(max)
				--        @SessionId -- sessionid - nvarchar(50)
				--    )
				--END CATCH
                

				--DELETE FROM dbo.seglog WHERE sessionid=@SessionId
            END;





        END;
    END;
    ELSE IF (@finalize = 1)
    BEGIN
        EXEC ('drop table ' + @temptableschema + '.' + @temptable);
    END;
    ELSE IF (@getCounts = 1)
    BEGIN
        SELECT SUM(p.rows) itemcount,
               MAX(t.create_date) lastupdate
        FROM sys.partitions p
            INNER JOIN sys.tables t
                ON p.object_id = t.object_id
        WHERE index_id IN ( 0, 1 )
              AND p.object_id = OBJECT_ID(@temptablefull);

    END;
    ELSE IF (@getschema = 1)
    BEGIN
        INSERT INTO segmentation.seglog
        (
            logmsg
        )
        VALUES ('msg4 - getschema' -- logmsg - varchar(max)
               );
        /*
		SELECT COLUMN_NAME [@id],
		Column_Name FriendlyName,
		replace(replace(replace(@ViewName,'vw__',''),'_',' '),'segmentation.','') FriendlyGroupName,
		@DocumentType DatasetDocumentType,
		@JoinColumn JoinColumn,
		segmentation.getSimpleDataType(a.DATA_TYPE) DataType,
		segmentation.getNetFrameworkDataType(a.DATA_TYPE) NetFrameworkDataType,
		DATA_TYPE + 
		CASE WHEN CHARACTER_MAXIMUM_LENGTH IS NULL 
		THEN '' 
		ELSE '(' + CONVERT(NVARCHAR,CHARACTER_MAXIMUM_LENGTH) + ')' end SqlServerDataType,
		case when Column_Name in ('id','Environment','SessionId','DocumentType','TenantId') then 0 else 1 end IsQueryable,
		case when Column_Name in ('id','Environment','SessionId','DocumentType','TenantId') then 0 else 1 end IsSelectable,
		'' OverrideViewType 
		 FROM INFORMATION_SCHEMA.COLUMNS a
		 WHERE  TABLE_NAME= OBJECT_NAME(OBJECT_ID(@temptableschema + '.' + @temptable))
		 FOR XML PATH('Column'), ROOT('Columns')
		 */

        SELECT COLUMN_NAME [@id],
               COLUMN_NAME FriendlyName,
               REPLACE(REPLACE(REPLACE(@ViewName, 'vw__', ''), '_', ' '), 'segmentation.', '') FriendlyGroupName,
               @DocumentType DatasetDocumentType,
               @JoinColumn JoinColumn,
               segmentation.getSimpleDataType(a.DATA_TYPE) DataType,
               segmentation.getNetFrameworkDataType(a.DATA_TYPE) NetFrameworkDataType,
               DATA_TYPE + CASE
                               WHEN CHARACTER_MAXIMUM_LENGTH IS NULL THEN
                                   ''
                               ELSE
                                   '(' + CONVERT(NVARCHAR, CHARACTER_MAXIMUM_LENGTH) + ')'
                           END SqlServerDataType,
               '' OverrideViewType,
               ISNULL(ExtProp.ExtendedPropertyValue, '{}') AS ExtendedProperties
        FROM INFORMATION_SCHEMA.COLUMNS a
            LEFT JOIN
            (
                SELECT COL.name AS ColumnName,
                       EP.value AS ExtendedPropertyValue
                FROM sys.extended_properties AS EP
                    JOIN sys.views VEW
                        ON VEW.object_id = EP.major_id
                    JOIN sys.schemas SCH
                        ON SCH.schema_id = VEW.schema_id
                    JOIN sys.columns COL
                        ON COL.object_id = VEW.object_id
                           AND COL.column_id = EP.minor_id
                WHERE EP.class = 1
                      AND SCH.name = @temptableschemaraw
                      AND VEW.name = REPLACE(REPLACE(@ViewName, @temptableschemaraw, ''), '.', '')
                      AND EP.name = 'ExtendedProperties'
            ) AS ExtProp
                ON a.COLUMN_NAME = ExtProp.ColumnName
        WHERE TABLE_NAME = OBJECT_NAME(OBJECT_ID(@temptableschema + '.' + @temptable))
        FOR XML PATH('Column'), ROOT('Columns');
        INSERT INTO segmentation.seglog
        (
            logmsg
        )
        VALUES ('msg5 - gs end' -- logmsg - varchar(max)
               );
    END;
    ELSE
    BEGIN
        INSERT INTO segmentation.seglog
        (
            logmsg
        )
        VALUES ('msg6 - temp tbl exts' -- logmsg - varchar(max)
               );
        --TODO:Error Handle if the temptable does not exist

        DECLARE @selectstatement NVARCHAR(MAX)
            =
        (
            SELECT '''' + segmentation.getNetFrameworkDataType(DATA_TYPE) + ''' as [' + COLUMN_NAME
                   + '/@DataType], LTRIM(RTRIM(' + COLUMN_NAME + ')) AS ' + COLUMN_NAME + ','
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = @temptableschemaraw
                  AND TABLE_NAME = @temptableraw
            FOR XML PATH('')
        )
        + ISNULL(
          (
              SELECT '''' + segmentation.getNetFrameworkDataType(DATA_TYPE) + ''' as [_' + COLUMN_NAME
                     + '/@DataType], LOWER(LTRIM(RTRIM(' + COLUMN_NAME + '))) AS [_' + COLUMN_NAME + '],'
              FROM INFORMATION_SCHEMA.COLUMNS
              WHERE TABLE_SCHEMA = @temptableschemaraw
                    AND TABLE_NAME = @temptableraw
                    AND segmentation.getNetFrameworkDataType(DATA_TYPE) = 'System.String'
              --and not Column_Name in ('id','Environment','SessionId','DocumentType','TenantId')
              FOR XML PATH('')
          ),
          ''
                )
        + ISNULL(
          (
              SELECT '''System.Double'' as [_' + COLUMN_NAME + '/@DataType], ' + 'CASE WHEN ' + COLUMN_NAME
                     + ' IS NULL THEN '''' ' + 'WHEN ' + COLUMN_NAME + ' = ''1900-01-01'' THEN '''' '
                     + 'ELSE CAST(DATEPART(yyyy, ' + COLUMN_NAME + ') AS NVARCHAR(4)) + '
                     + 'RIGHT(''00'' + CAST(DATEPART(mm, ' + COLUMN_NAME + ') AS NVARCHAR(2)), 2) + '
                     + 'RIGHT(''00'' + CAST(DATEPART(dd, ' + COLUMN_NAME + ') AS NVARCHAR(2)), 2) + ' + '('
                     + 'CASE WHEN DATEPART(yyyy, ' + COLUMN_NAME + ') < 1753 THEN ''000000'' ELSE '
                     + 'RIGHT(''00'' + CAST(DATEPART(hh, CAST(' + COLUMN_NAME + ' AS DATETIME)) AS NVARCHAR(2)), 2) + '
                     + 'RIGHT(''00'' + CAST(DATEPART(mi, CAST(' + COLUMN_NAME + ' AS DATETIME)) AS NVARCHAR(2)), 2) + '
                     + 'RIGHT(''00'' + CAST(DATEPART(ss, CAST(' + COLUMN_NAME + ' AS DATETIME)) AS NVARCHAR(2)), 2) '
                     + 'END' + ')' + 'END AS [_' + COLUMN_NAME + '],'
              FROM INFORMATION_SCHEMA.COLUMNS
              WHERE TABLE_SCHEMA = @temptableschemaraw
                    AND TABLE_NAME = @temptableraw
                    AND segmentation.getNetFrameworkDataType(DATA_TYPE) IN ( 'System.Date', 'System.DateTime' )
              --and not Column_Name in ('id','Environment','SessionId','DocumentType','TenantId')
              FOR XML PATH('')
          ),
          ''
                );
        --+
        --isnull(
        --(select '''System.Int32'' as [_' + column_name + '/@DataType],DATEDIFF(s, ''1970-01-01'', case when ' + Column_name +'<''1/1/1970'' or ' + column_name + '>getdate() then ''1/1/1970'' else '+ column_name +' end) as [_' + Column_name + '],' 
        --from INFORMATION_SCHEMA.columns where TABLE_Schema=@temptableschemaraw and TABLE_NAME=@temptableraw 
        --and segmentation.getNetFrameworkDataType(DATA_TYPE) in ('System.Date','System.DateTime')
        ----and not Column_Name in ('id','Environment','SessionId','DocumentType','TenantId')
        --for xml path(''))
        --,'')

        SET @selectstatement
            = REPLACE(REPLACE(LEFT(@selectstatement, LEN(@selectstatement) - 1), '&lt;', '<'), '&gt;', '>');

        DECLARE @datasql NVARCHAR(MAX)
            = 'SELECT ' + CONVERT(NVARCHAR(MAX), @selectstatement) + '
	 FROM '                              + @temptableschema + '.' + @temptable + ' co
	 where _rn between '                 + CONVERT(NVARCHAR(10), ((@PageNumber - 1) * @RowsPerPage) + 1) + ' and '
              + +CONVERT(NVARCHAR(10), ((@PageNumber - 1) * @RowsPerPage) + @RowsPerPage)
              + '
	  ORDER BY co.id 
	  FOR XML PATH(''Document''),ROOT(''Documents'')';
        --  OFFSET (' + CONVERT(NVARCHAR(10), ( ( @PageNumber - 1 ) * @RowsPerPage ))
        --                           + ') ROWS
        --FETCH NEXT ' + CONVERT(NVARCHAR(10), @RowsPerPage) + ' ROWS ONLY


        PRINT @datasql;

        --For troubleshooting...
        --declare @junk table(query NVARCHAR(MAX))
        --insert into @junk (query) values (@datasql)
        --select * from @junk

        EXEC (@datasql);
	END;


	INSERT INTO segmentation.seglog
	(
	    logmsg,
	    sessionid
	)
	VALUES
	(   'Finished', -- logmsg - varchar(max)
	    @SessionId -- sessionid - nvarchar(50)
	)
END

GO
