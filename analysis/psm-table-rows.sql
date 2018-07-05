/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   This builds a consolidated table of the entire longitudinal dataset for analysis and building other analysis tables.
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spLoadTableRows @ProductionMode = 1;
*/
-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.


DROP PROCEDURE IF EXISTS spLoadTableRows;
GO

/*
EXEC spLoadTableRows      
        @ProductionMode = 1
*/

CREATE PROC
    spLoadTableRows
    @ProductionMode INTEGER = 0
    AS BEGIN

    print '*** RUNNING psm-table-rows.sql'

-- Descriptions of NMRC fields

IF @ProductionMode = 1
	BEGIN
		print '*** RUNNING IN PRODUCTION MODE! TABLES DROPPED AND CREATED.'

        DROP TABLE IF EXISTS mcrFormData_Alpha;

        SELECT
            IMPORT_DT
            , FORM
            , RPT_REC_NUM
            , WKSHT_CD
            , SUBSTRING(LINE_NUM,1,3) as LINE_NUM
            , SUBSTRING(LINE_NUM,4,5) as SUBLINE_NUM     
            , SUBSTRING(CLMN_NUM,1,3) as CLMN_NUM 
            , SUBSTRING(CLMN_NUM,4,5) as SUBCLMN_NUM
            , ALPHNMRC_ITM_TXT as ALPHA

            INTO mcrFormData_Alpha
            FROM MCR_NEW_ALPHA
            WHERE CLMN_NUM != '00000'

            DROP INDEX IF EXISTS mcrFormData_Alpha_FORM_WKSHTCD_FORM_IMPORTDT_RPTRECNUM_LINENUM_CLMN_NUM ON mcrFormData_Alpha;
            CREATE INDEX mcrFormData_Alpha_FORM_WKSHTCD_FORM_IMPORTDT_RPTRECNUM_LINENUM_CLMN_NUM ON mcrFormData_Alpha (FORM ASC, WKSHT_CD ASC, LINE_NUM ASC, SUBLINE_NUM ASC, CLMN_NUM ASC, SUBCLMN_NUM ASC);

        
        -- Other AlphaNumeric information

        DROP TABLE IF EXISTS mcrFormData_Alpha_Desc;

        SELECT
            IMPORT_DT
            , FORM
            , RPT_REC_NUM
            , WKSHT_CD
            , SUBSTRING(LINE_NUM,1,3) as LINE_NUM
            , SUBSTRING(LINE_NUM,4,5) as SUBLINE_NUM     
            , SUBSTRING(CLMN_NUM,1,3) as CLMN_NUM 
            , SUBSTRING(CLMN_NUM,4,5) as SUBCLMN_NUM
            , ALPHNMRC_ITM_TXT as ALPHA
            , STR(Null) as COSTCODE

            INTO mcrFormData_Alpha_Desc
            FROM MCR_NEW_ALPHA
            WHERE CLMN_NUM = '00000';

            UPDATE mcrFormData_Alpha_Desc SET COSTCODE = CONVERT(VARCHAR,SUBSTRING(ALPHA,1,5))
                WHERE ALPHA LIKE '[0-9][0-9][0-9][0-9][0-9][A-Z]%';
            
            UPDATE mcrFormData_Alpha_Desc SET ALPHA = SUBSTRING(ALPHA,6,LEN(ALPHA)-5) 
                WHERE ALPHA LIKE '[0-9][0-9][0-9][0-9][0-9][A-Z]%';

            DROP INDEX IF EXISTS mcrFormData_Alpha_Desc_FORM_WKSHTCD_FORM_IMPORTDT_RPTRECNUM_LINENUM_CLMN_NUM ON mcrFormData_Alpha_Desc;
            CREATE INDEX mcrFormData_Alpha_Desc_FORM_WKSHTCD_FORM_IMPORTDT_RPTRECNUM_LINENUM_CLMN_NUM ON mcrFormData_Alpha_Desc (FORM ASC, WKSHT_CD ASC, LINE_NUM ASC, SUBLINE_NUM ASC, CLMN_NUM ASC, SUBCLMN_NUM ASC);


        -- Numeric Information

        DROP TABLE IF EXISTS mcrFormData_Nmrc;

        SELECT
            IMPORT_DT
            , FORM
            , RPT_REC_NUM
            , WKSHT_CD
            , SUBSTRING(LINE_NUM,1,3) as LINE_NUM
            , SUBSTRING(LINE_NUM,4,5) as SUBLINE_NUM     
            , SUBSTRING(CLMN_NUM,1,3) as CLMN_NUM 
            , SUBSTRING(CLMN_NUM,4,5) as SUBCLMN_NUM
            , ITM_VAL_NUM as NMRC

            INTO mcrFormData_Nmrc
            FROM MCR_NEW_NMRC

            DROP INDEX IF EXISTS mcrFormData_Nmrc_FORM_WKSHTCD_FORM_IMPORTDT_RPTRECNUM_LINENUM_CLMN_NUM ON mcrFormData_Nmrc;
            CREATE INDEX mcrFormData_Nmrc_FORM_WKSHTCD_FORM_IMPORTDT_RPTRECNUM_LINENUM_CLMN_NUM ON mcrFormData_Nmrc (FORM ASC, WKSHT_CD ASC, LINE_NUM ASC, SUBLINE_NUM ASC, CLMN_NUM ASC, SUBCLMN_NUM ASC);          


            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END

    END

GO
