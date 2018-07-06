/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   These PSMs help with data validation and troubleshooting
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    SEE PROCEDURES BELOW
*/


DROP PROCEDURE IF EXISTS spCheckWorksheet;
GO

/*
EXEC spCheckWorksheet  
        @RecordNum = 115710
        , @Worksheet = 'G200000'   
        , @Records = 100
*/

CREATE PROC
    spCheckWorksheet
    @RecordNum INTEGER = 0
    , @Worksheet VARCHAR(10) = ''
    , @Records INTEGER = 10
    AS BEGIN

        DECLARE @SQLStmt nvarchar(max)

        print '*** RUNNING CheckWorksheet'

        SET @SQLStmt = 'SELECT TOP '+ CONVERT(VARCHAR, @Records) +' *
            FROM mcrFormData
            WHERE WKSHT_CD='''+ @Worksheet +'''
            AND RPT_REC_NUM=' + CONVERT(VARCHAR, @RecordNum) + '
            ORDER BY LINE_NUM, SUBLINE_NUM, CLMN_NUM, SUBCLMN_NUM;'

            PRINT N'ANALYSIS DATA mcrFormData'
            -- PRINT @SQLStmt
            EXEC sp_executesql @SQLStmt	
        
        SET @SQLStmt = 'SELECT TOP '+ CONVERT(VARCHAR, @Records) +' *
            FROM mcrFormData_Nmrc
            WHERE WKSHT_CD='''+ @Worksheet +'''
            AND RPT_REC_NUM=' + CONVERT(VARCHAR, @RecordNum) + '
            ORDER BY LINE_NUM, SUBLINE_NUM, CLMN_NUM, SUBCLMN_NUM;'

            PRINT N'ANALYSIS DATA mcrFormData_Nmrc'
            -- PRINT @SQLStmt
            EXEC sp_executesql @SQLStmt	

        SET @SQLStmt = 'SELECT TOP '+ CONVERT(VARCHAR, @Records) +' *
            FROM mcrFormData_Alpha
            WHERE WKSHT_CD='''+ @Worksheet +'''
            AND RPT_REC_NUM=' + CONVERT(VARCHAR, @RecordNum) + '
            ORDER BY LINE_NUM, SUBLINE_NUM, CLMN_NUM, SUBCLMN_NUM;'

            PRINT N'ANALYSIS DATA mcrFormData_Alpha'
            -- PRINT @SQLStmt
            EXEC sp_executesql @SQLStmt	

        -- SET @SQLStmt = 'SELECT TOP '+ CONVERT(VARCHAR, @Records) +' *
        --     FROM MCR_NEW_NMRC
        --     WHERE WKSHT_CD='''+ @Worksheet +'''
        --     AND RPT_REC_NUM=' + CONVERT(VARCHAR, @RecordNum) + '
        --     ORDER BY LINE_NUM, CLMN_NUM;'
                            
        --     PRINT N'RAW DATA'
        --     PRINT @SQLStmt
        --     EXEC sp_executesql @SQLStmt	

            PRINT N'*** FINISHED'
    END