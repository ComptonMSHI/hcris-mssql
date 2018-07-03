/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   This builds the consolidated form table complete with the conversion of 2552-96 lines to 2552-10 lines crosswalk.
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spLoadTableForm @ProductionMode = 1;
*/
-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.


DROP PROCEDURE IF EXISTS spLoadTableForm;
GO

/*
EXEC spLoadTableForm     
        @ProductionMode = 1
*/

CREATE PROC
    spLoadTableForm
    @ProductionMode INTEGER = 0
    AS BEGIN

    print '*** RUNNING psm-table-form.sql'

-- Combined form data

IF @ProductionMode = 1
	BEGIN
		print '*** RUNNING IN PRODUCTION MODE! TABLES DROPPED AND CREATED.'

        DROP TABLE IF EXISTS mcrFormData;

        print '*** LOADING ALPHA DATA'
        SELECT
            r.IMPORT_DT
            , r.FORM
            , r.PRVDR_NUM
            , r.FY_BGN_DT
            , r.FY_END_DT
            , r.RPT_REC_NUM

            , f.WKSHT
            , f.WKSHT_CD
            , f.SHEET_NAME
            , f.SECTION_NAME
            , f.SUBSECTION_NAME

            , f.LINE_NUM
            , f.SUBLINE_NUM    
            , f.LINE_DESC	

            , f.CLMN_NUM
            , f.SUBCLMN_NUM 
            , f.CLMN_DESC

            , f.LINE_NUM_96
            , f.SUBLINE_NUM_96
                    
            , f.CLMN_NUM_96
            , f.SUBCLMN_NUM_96

            , a.ALPHA as ALPHA

        INTO mcrFormData
            FROM mcrForm f

                LEFT JOIN MCR_NEW_RPT r ON
                    r.FORM = f.FORM

                LEFT JOIN mcrFormData_Alpha a ON
                    a.WKSHT_CD =f.WKSHT_CD
                    AND a.FORM =f.FORM
                    AND a.IMPORT_DT = r.IMPORT_DT
                    AND a.RPT_REC_NUM = r.RPT_REC_NUM
                    AND f.LINE_NUM = a.LINE_NUM
                    AND f.CLMN_NUM = a.CLMN_NUM
                    AND f.SUBLINE_NUM = a.SUBLINE_NUM
                    AND f.SUBCLMN_NUM = a.SUBCLMN_NUM;        


        print '*** LOADING NMRC DATA'
        SELECT
            r.IMPORT_DT
            , r.FORM
            , r.PRVDR_NUM
            , r.FY_BGN_DT
            , r.FY_END_DT
            , r.RPT_REC_NUM

            , f.WKSHT
            , f.WKSHT_CD
            , f.SHEET_NAME
            , f.SECTION_NAME
            , f.SUBSECTION_NAME

            , f.LINE_NUM
            , f.SUBLINE_NUM    
            , f.LINE_DESC	

            , f.CLMN_NUM
            , f.SUBCLMN_NUM 
            , f.CLMN_DESC

            , f.LINE_NUM_96
            , f.SUBLINE_NUM_96
                    
            , f.CLMN_NUM_96
            , f.SUBCLMN_NUM_96

            , n.NMRC as NMRC
            , na.ALPHA as NMRC_DESC

        INTO mcrFormData
            FROM MCR_NEW_RPT r 
            
                LEFT JOIN mcrFormData_Nmrc n ON	
                    n.RPT_REC_NUM = r.RPT_REC_NUM
                        LEFT JOIN mcrFormData_Alpha_Desc na ON
                            na.WKSHT_CD = n.WKSHT_CD
                            AND na.FORM = n.FORM
                            AND na.IMPORT_DT = n.IMPORT_DT
                            AND na.RPT_REC_NUM = n.RPT_REC_NUM
                            AND na.LINE_NUM = n.LINE_NUM            

                INNER JOIN mcrForm f ON
                    f.FORM = n.FORM
                    AND f.WKSHT_CD = n.WKSHT_CD
                    AND f.LINE_NUM = n.LINE_NUM
                    AND f.CLMN_NUM = n.CLMN_NUM
                    AND f.SUBLINE_NUM = n.SUBLINE_NUM
                    AND f.SUBCLMN_NUM = n.SUBCLMN_NUM;        
                    



        DROP INDEX IF EXISTS mcrFormData_a ON mcrFormData;
        CREATE INDEX mcrFormData_a ON mcrFormData (FORM ASC, WKSHT_CD ASC, LINE_NUM ASC, SUBLINE_NUM ASC, CLMN_NUM ASC, SUBCLMN_NUM ASC); 

        DROP INDEX IF EXISTS mcrFormData_b ON mcrFormData;
        CREATE INDEX mcrFormData_e ON mcrFormData (PRVDR_NUM ASC, FY_BGN_DT ASC, FY_END_DT ASC, RPT_REC_NUM ASC);




            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END

    END

GO
