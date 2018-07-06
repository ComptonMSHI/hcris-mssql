/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   This performs a full load of NMRC data from the archiver output folder (unzipped csv files)
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spLoadNmrcData 
        @CsvPath = '/data/mcr/Output'
        , @CsvFolder = '2018-05-06'
        , @YearFrom = 1995
        , @YearTo = 2017
        , @ProductionMode = 1
*/
-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.


DROP PROCEDURE IF EXISTS spLoadNmrcData;
GO


CREATE PROC
    spLoadNmrcData
        @CsvPath VARCHAR(255), 
        @CsvFolder VARCHAR(255), 
        @YearFrom INTEGER = 1995, 
        @YearTo INTEGER = 2017, 
        @ProductionMode INTEGER = 0
    AS BEGIN
    
    print '*** RUNNING psm-mcr-nmrc-load.sql'

        DECLARE @NmrcFields VARCHAR(MAX)
        DECLARE @NmrcFields10 VARCHAR(MAX)



SET @NmrcFields       = N'RPT_REC_NUM, WKSHT_CD, LINE_NUM, CLMN_NUM, ITM_VAL_NUM'
SET @NmrcFields10     = N'RPT_REC_NUM, WKSHT_CD, LINE_NUM, CLMN_NUM, ITM_VAL_NUM'

/************************************************************
	MODE
************************************************************/

IF @ProductionMode = 1
	BEGIN
		print '*** RUNNING IN PRODUCTION MODE! TABLES DROPPED AND CREATED.'

        /************************************************************
            CONSTRUCTION
        ************************************************************/
            DROP TABLE IF EXISTS [MCR_NEW_NMRC]

            CREATE TABLE [MCR_NEW_NMRC] (
                IMPORT_DT            DATETIME NULL,
                IMPORT_SRC           VARCHAR(MAX),
                FORM                 CHAR(10),
                RPT_REC_NUM          FLOAT NOT NULL,
                WKSHT_CD             CHAR(7) NOT NULL,
                LINE_NUM             CHAR(5) NOT NULL,
                CLMN_NUM             CHAR(5) NOT NULL,   
                ITM_VAL_NUM          FLOAT NOT NULL
            )

            DROP TABLE IF EXISTS #TempNMRC

            CREATE TABLE #TempNMRC (
                RPT_REC_NUM          FLOAT NOT NULL,
                WKSHT_CD             CHAR(7) NOT NULL,
                LINE_NUM             CHAR(5) NOT NULL,
                CLMN_NUM             CHAR(5) NOT NULL,   
                ITM_VAL_NUM          FLOAT NOT NULL
            )


            /************************************************************
                PREPARATION
            ************************************************************/
            DECLARE @SQLStmt nvarchar(max)
            DECLARE @CsvFile VARCHAR(255)
            DECLARE @NmrcFile VARCHAR(MAX)
            DECLARE @CurrYear NVARCHAR (4)

            SET @CurrYear = @YearFrom;	
            WHILE @CurrYear <= @YearTo
                BEGIN
                    IF @CurrYear <= 2011
                        BEGIN
                            SET @CsvFile = N'hosp_'+ CAST(@CurrYear AS varchar(4)) + N'_NMRC.CSV'
                            SET @NmrcFile = @CsvPath + N'\' + @CsvFolder + N'\' + @CsvFile	
                            SET @SQLStmt = N'BULK INSERT #tempNMRC FROM ''' + @NmrcFile + N''' WITH (FIRSTROW = 1, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';

                            -- Pull into master with metadata.
                            SET @SQLStmt = @SQLStmt + N'INSERT INTO [MCR_NEW_NMRC]
                            (IMPORT_DT, IMPORT_SRC, FORM, ' + @NmrcFields + N')
                                    SELECT 
                                        ''' + @CsvFolder + ''' AS IMPORT_DT,
                                        ''' + @CsvFile + ''' AS IMPORT_SRC,
                                        ''2552-96'' AS FORM,
                                        ' + @NmrcFields + N' FROM #TempNMRC;'
                            SET @SQLStmt = @SQLStmt + N'TRUNCATE TABLE #TempNMRC;'
                            
                            PRINT N'Loading (96): '+ @CsvFile
                            EXEC sp_executesql @SQLStmt	
                        END

                    IF @CurrYear >= 2010
                        BEGIN
                            SET @CsvFile    = N'hosp10_'+ CAST(@CurrYear AS varchar(4)) + N'_NMRC.CSV'  
                            SET @NmrcFile    = @CsvPath + N'\' + @CsvFolder + N'\' + @CsvFile		
                            SET @SQLStmt = N'BULK INSERT #tempNMRC FROM ''' + @NmrcFile + N''' WITH (FIRSTROW = 1, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';

                            -- Pull into master with metadata.
                            SET @SQLStmt = @SQLStmt + N'INSERT INTO [MCR_NEW_NMRC]
                                (IMPORT_DT, IMPORT_SRC, FORM, ' + @NmrcFields10 + N')
                                    SELECT 
                                        ''' + @CsvFolder + ''' AS IMPORT_DT,
                                        ''' + @CsvFile + ''' AS IMPORT_SRC,
                                        ''2552-10'' AS FORM,
                                        ' + @NmrcFields10 + N' FROM #TempNMRC;'
                            SET @SQLStmt = @SQLStmt + N'TRUNCATE TABLE #TempNMRC;'

                            PRINT N'Loading (10): '+ @CsvFile
                            EXEC sp_executesql @SQLStmt	                                        
                        END

                    TRUNCATE TABLE #TempNMRC;
                    SET @CurrYear = @CurrYear + 1
                    SET @SQLStmt = N''
                    SET @CsvFile = N''
                    SET @NmrcFile = N''
                END

                DROP TABLE #TempNMRC;

                /************************************************************
                    CLEAN UP
                ************************************************************/

                -- CORRECT FOR OLD FORMAT COLUMN NUMBERS (XXYY TO XXXYY)
                UPDATE MCR_NEW_NMRC SET CLMN_NUM = CONCAT('0',CLMN_NUM) WHERE LEN(CLMN_NUM) = 4;

                DROP INDEX IF EXISTS NMRC_RPTRECNUM_LINENUM_CLMNNUM ON MCR_NEW_NMRC;
                CREATE INDEX NMRC_RPTRECNUM_LINENUM_CLMNNUM ON MCR_NEW_NMRC (RPT_REC_NUM,LINE_NUM,CLMN_NUM);

                DROP INDEX IF EXISTS NMRC_FORM_WKSHTCD_LINENUM_CLMNNUM ON MCR_NEW_NMRC;
                CREATE INDEX NMRC_FORM_WKSHTCD_LINENUM_CLMNNUM ON MCR_NEW_NMRC (IMPORT_DT ASC, FORM ASC, RPT_REC_NUM ASC, WKSHT_CD ASC, LINE_NUM ASC, CLMN_NUM ASC); 

                DROP INDEX IF EXISTS NMRC_FORM_WKSHTCD_FORM_IMPORTDT_RPTRECNUM ON MCR_NEW_NMRC;
                CREATE INDEX NMRC_FORM_WKSHTCD_FORM_IMPORTDT_RPTRECNUM ON MCR_NEW_NMRC (WKSHT_CD ASC, FORM ASC, IMPORT_DT ASC, RPT_REC_NUM ASC);  



            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END


    END

GO