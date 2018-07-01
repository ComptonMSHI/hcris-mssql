/*

# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   To perform an initial load of a release of HCRIS REPORT cost report data.
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spLoadRptData 
        @CsvPath = '/data/mcr/Output'
        , @CsvFolder = '2018-05-06'
        , @YearFrom = 1995
        , @YearTo = 2017
        , @ProductionMode = 1

*/

-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.

DROP PROCEDURE IF EXISTS spLoadRptData;
GO

CREATE PROC
    spLoadRptData
        @CsvPath VARCHAR(255), 
        @CsvFolder VARCHAR(255), 
        @YearFrom INTEGER = 1995, 
        @YearTo INTEGER = 2017, 
        @ProductionMode INTEGER = 0
    AS BEGIN

        DECLARE @RptFields VARCHAR(MAX)
        DECLARE @RptFields10 VARCHAR(MAX)

        SET @RptFields       = N'RPT_REC_NUM, PRVDR_CTRL_TYPE_CD, PRVDR_NUM, NPI, RPT_STUS_CD, FY_BGN_DT, FY_END_DT, PROC_DT,
                                    INITL_RPT_SW, LAST_RPT_SW, TRNSMTL_NUM, FI_NUM, ADR_VNDR_CD, FI_CREAT_DT, UTIL_CD, NPR_DT, SPEC_IND,FI_RCPT_DT'
        SET @RptFields10     = N'RPT_REC_NUM, PRVDR_CTRL_TYPE_CD, PRVDR_NUM, NPI, RPT_STUS_CD, FY_BGN_DT, FY_END_DT, PROC_DT,
                                    INITL_RPT_SW, LAST_RPT_SW, TRNSMTL_NUM, FI_NUM, ADR_VNDR_CD, FI_CREAT_DT, UTIL_CD, NPR_DT, SPEC_IND,FI_RCPT_DT'

        /************************************************************
            MODE
        ************************************************************/

        IF @ProductionMode = 1
            BEGIN
                print '*** RUNNING IN PRODUCTION MODE! TABLES DROPPED AND CREATED.'
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END



        /************************************************************
            CONSTRUCTION
        ************************************************************/

        DROP TABLE IF EXISTS #TempRPTMaster

        CREATE TABLE #TempRPTMaster (
            ID int IDENTITY(1,1) PRIMARY KEY,
            IMPORT_DT            DATETIME NULL,
            IMPORT_SRC           VARCHAR(MAX),
            FORM                 CHAR(10),
            RPT_REC_NUM          FLOAT NOT NULL,
            PRVDR_CTRL_TYPE_CD   CHAR(2) NULL,
            PRVDR_NUM            CHAR(6) NOT NULL,
            NPI                  FLOAT NULL,
            RPT_STUS_CD          CHAR(1) NOT NULL,
            FY_BGN_DT            DATETIME NULL,
            FY_END_DT            DATETIME NULL,
            PROC_DT              DATETIME NULL,
            INITL_RPT_SW         CHAR(1) NULL,
            LAST_RPT_SW          CHAR(1) NULL,
            TRNSMTL_NUM          CHAR(2) NULL,
            FI_NUM               CHAR(5) NULL,
            ADR_VNDR_CD          CHAR(1) NULL,
            FI_CREAT_DT          DATETIME NULL,
            UTIL_CD              CHAR(1) NULL,
            NPR_DT               DATETIME NULL,
            SPEC_IND             CHAR(1) NULL,
            FI_RCPT_DT           DATETIME NULL
        )

        DROP TABLE IF EXISTS #TempRPT

        CREATE TABLE #TempRPT (
            RPT_REC_NUM          FLOAT NOT NULL,
            PRVDR_CTRL_TYPE_CD   CHAR(2) NULL,
            PRVDR_NUM            CHAR(6) NOT NULL,
            NPI                  FLOAT NULL,
            RPT_STUS_CD          CHAR(1) NOT NULL,
            FY_BGN_DT            DATETIME NULL,
            FY_END_DT            DATETIME NULL,
            PROC_DT              DATETIME NULL,
            INITL_RPT_SW         CHAR(1) NULL,
            LAST_RPT_SW          CHAR(1) NULL,
            TRNSMTL_NUM          CHAR(2) NULL,
            FI_NUM               CHAR(5) NULL,
            ADR_VNDR_CD          CHAR(1) NULL,
            FI_CREAT_DT          DATETIME NULL,
            UTIL_CD              CHAR(1) NULL,
            NPR_DT               DATETIME NULL,
            SPEC_IND             CHAR(1) NULL,
            FI_RCPT_DT           DATETIME NULL
        )

        /************************************************************
            PREPARATION
        ************************************************************/
        DECLARE @SQLStmt nvarchar(max)
        DECLARE @CsvFile VARCHAR(255)
        DECLARE @RptFile VARCHAR(MAX)
        DECLARE @CurrYear NVARCHAR (4)

        SET @CurrYear = @YearFrom;	
        WHILE @CurrYear <= @YearTo
            BEGIN
                TRUNCATE TABLE #TempRPT;

                IF @CurrYear <= 2011
                    BEGIN
                        SET @CsvFile = N'hosp_'+ CAST(@CurrYear AS varchar(4)) + N'_RPT.CSV'
                        SET @RptFile = @CsvPath + N'\' + @CsvFolder + N'\' + @CsvFile

                        -- Pull into temporary table.
                        SET @SQLStmt = N'BULK INSERT #TempRPT FROM ''' + @RptFile + N''' WITH (FIRSTROW = 1, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';
                        --PRINT @SQLStmt
                        EXEC sp_executesql @SQLStmt			

                        -- Pull into master with metadata.
                        SET @SQLStmt = N'INSERT INTO #TempRPTMaster
                        (IMPORT_DT, IMPORT_SRC, FORM, ' + @RptFields + N')
                                SELECT 
                                    ''' + @CsvFolder + ''' AS IMPORT_DT,
                                    ''' + @CsvFile + ''' AS IMPORT_SRC,
                                    ''2552-96'' AS FORM,
                                    ' + @RptFields + N' FROM #TempRPT;'
                        --PRINT @SQLStmt
                        EXEC sp_executesql @SQLStmt	
                    END

                IF @CurrYear >= 2010
                    BEGIN
                        SET @CsvFile    = N'hosp10_'+ CAST(@CurrYear AS varchar(4)) + N'_RPT.CSV'  
                        SET @RptFile    = @CsvPath + N'\' + @CsvFolder + N'\' + @CsvFile

                        -- Pull into temporary table.
                        SET @SQLStmt        = N'BULK INSERT #TempRPT FROM ''' + @RptFile + N''' WITH (FIRSTROW = 1, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';
                        --PRINT @SQLStmt
                        EXEC sp_executesql @SQLStmt			

                        -- Pull into master with metadata.
                        SET @SQLStmt        = N'INSERT INTO #TempRPTMaster
                            (IMPORT_DT, IMPORT_SRC, FORM, ' + @RptFields10 + N')
                                SELECT 
                                    ''' + @CsvFolder + ''' AS IMPORT_DT,
                                    ''' + @CsvFile + ''' AS IMPORT_SRC,
                                    ''2552-10'' AS FORM,
                                    ' + @RptFields10 + N' FROM #TempRPT;'
                        --PRINT @SQLStmt
                        EXEC sp_executesql @SQLStmt	                          
                    END

                SET @CurrYear = @CurrYear + 1
                SET @SQLStmt = N''
                SET @CsvFile = N''
                SET @RptFile = N''
                TRUNCATE TABLE #TempRPT;
            END

        /************************************************************
            MERGE
        ************************************************************/


        /************************************************************
            VALIDATION
        ************************************************************/

        DECLARE @Validated 		INT

        SET @Validated 		= 1


        /************************************************************
            CREATION
        ************************************************************/

        IF @Validated = 1
            BEGIN
                IF @ProductionMode = 1
                    BEGIN
                        PRINT '***** Creating Table *****'

                        SET @SQLStmt = N'
                        DROP TABLE IF EXISTS [MCR_NEW_RPT]

                        CREATE TABLE [MCR_NEW_RPT] (
                            IMPORT_DT            DATETIME NULL,
                            IMPORT_SRC           VARCHAR(MAX),
                            FORM                 CHAR(10),
                            RPT_REC_NUM          FLOAT NOT NULL,
                            PRVDR_CTRL_TYPE_CD   CHAR(2) NULL,
                            PRVDR_NUM            CHAR(6) NOT NULL,
                            NPI                  FLOAT NULL,
                            RPT_STUS_CD          CHAR(1) NOT NULL,
                            FY_BGN_DT            DATETIME NULL,
                            FY_END_DT            DATETIME NULL,
                            PROC_DT              DATETIME NULL,
                            INITL_RPT_SW         CHAR(1) NULL,
                            LAST_RPT_SW          CHAR(1) NULL,
                            TRNSMTL_NUM          CHAR(2) NULL,
                            FI_NUM               CHAR(5) NULL,
                            ADR_VNDR_CD          CHAR(1) NULL,
                            FI_CREAT_DT          DATETIME NULL,
                            UTIL_CD              CHAR(1) NULL,
                            NPR_DT               DATETIME NULL,
                            SPEC_IND             CHAR(1) NULL,
                            FI_RCPT_DT           DATETIME NULL
                        )'

                        EXEC sp_executesql @SQLStmt	

                        SET @SQLStmt = N'
                        INSERT INTO [MCR_NEW_RPT]
                            (IMPORT_DT, IMPORT_SRC, FORM, ' + @RptFields + N')
                                SELECT IMPORT_DT, IMPORT_SRC, FORM, ' + @RptFields + N' FROM #TempRPTMaster;'
                        --PRINT @SQLStmt
                        EXEC sp_executesql @SQLStmt	

                        DROP INDEX IF EXISTS MCR_NEW_RPT_a ON MCR_NEW_RPT;
                        CREATE INDEX MCR_NEW_RPT_a ON MCR_NEW_RPT (PRVDR_NUM ASC, FY_BGN_DT ASC, FY_END_DT ASC, RPT_REC_NUM ASC);

                        DROP INDEX IF EXISTS MCR_NEW_RPT_b ON MCR_NEW_RPT;
                        CREATE INDEX MCR_NEW_RPT_b ON MCR_NEW_RPT (IMPORT_DT ASC, RPT_REC_NUM ASC);

                        SELECT 'Total Records' AS [Result], COUNT(*) As [Count] FROM [MCR_NEW_RPT];
                    END
                ELSE
                    BEGIN
                        PRINT '***** TEST ONLY: Not Dropping/Creating Table *****'

                        SELECT * FROM #TempRPTMaster;
                    END
            END
        ELSE
            BEGIN
                -- If our validation criteria fails, this provides the output to investigate.
                PRINT 'ERROR! Criteria for building table not met!'
                -- SELECT 
                -- 	'ERRORS ENCOUNTERED!' AS [Error]
                -- 	, @Validated AS [Validated]
            END




    END

GO
