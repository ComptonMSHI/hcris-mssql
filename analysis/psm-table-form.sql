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

        DROP TABLE IF EXISTS mcrForm;

        SELECT
            yes.FORM
            , w.WKSHT
            , w.WKSHT_CD
            
            , w.SHEET_NAME
            , w.SECTION_NAME
            , w.SUBSECTION_NAME
            , CASE 
                WHEN cw.LINE_NUM Is Not Null 
                    THEN cw.LINE_NUM ELSE w.LINE_NUM
                END AS [LINE_NUM]
                
            , CASE 
                WHEN cw.SUBLINE_NUM Is Not Null 
                    THEN cw.SUBLINE_NUM ELSE w.SUBLINE_NUM
                END AS [SUBLINE_NUM]        

            , w.LINE_DESC	

            , CASE 
                WHEN cw.CLMN_NUM Is Not Null 
                    THEN cw.CLMN_NUM ELSE w.CLMN_NUM
                END AS [CLMN_NUM]
                
            , CASE 
                WHEN cw.SUBCLMN_NUM Is Not Null 
                    THEN cw.SUBCLMN_NUM ELSE w.SUBCLMN_NUM
                END AS [SUBCLMN_NUM]  
        
            , w.CLMN_DESC

            , cw.LINE_NUM_96 as [LINE_NUM_96]
            , cw.SUBLINE_NUM_96 as [SUBLINE_NUM_96]
                    
            , cw.CLMN_NUM_96 as [CLMN_NUM_96]
            , cw.SUBCLMN_NUM_96 as [SUBCLMN_NUM_96]

            INTO mcrForm
            FROM MCR_AVAILABLE yes
                INNER JOIN MCR_WORKSHEETS w ON
                    w.FORM_NUM = yes.FORM

                        LEFT JOIN MCR_CROSSWALK cw ON
                            w.FORM_NUM = cw.FORM_NUM_96
                            AND w.WKSHT_CD = cw.WKSHT_CD_96
                            AND w.LINE_NUM = cw.LINE_NUM_96 
                            AND w.CLMN_NUM = cw.CLMN_NUM_96 


            DROP INDEX IF EXISTS mcrForm_a ON mcrForm;
            CREATE INDEX mcrForm_a ON mcrForm (FORM ASC, WKSHT_CD ASC, LINE_NUM ASC, SUBLINE_NUM ASC, CLMN_NUM ASC, SUBCLMN_NUM ASC);



            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END

    END

GO
