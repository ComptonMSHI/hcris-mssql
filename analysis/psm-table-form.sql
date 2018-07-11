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

        SELECT DISTINCT
            yes.FORM
            , w.WKSHT
            , CASE 
                WHEN cw.WKSHT_CD Is Not Null 
                    THEN cw.WKSHT_CD ELSE w.WKSHT_CD
                END AS [WKSHT_CD]  

            
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

            , cw.WKSHT_CD_96 as [WKSHT_CD_96] 

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
            WHERE w.CLMN_NUM Is Not Null AND w.CLMN_NUM != '000';

            DROP INDEX IF EXISTS mcrForm_a ON mcrForm;
            CREATE INDEX mcrForm_a ON mcrForm (FORM ASC, WKSHT_CD ASC, LINE_NUM ASC, SUBLINE_NUM ASC, CLMN_NUM ASC, SUBCLMN_NUM ASC);




        DROP TABLE IF EXISTS mcrFormData;

        print '*** LOADING ALPHA DATA';

        CREATE TABLE mcrFormData (
            IMPORT_DT datetime NULL,
            FORM char(10) NULL,
            FORM_EQUIV char(10) NULL,
            PRVDR_NUM char(6) NULL,
            FY_BGN_DT datetime NULL,
            FY_END_DT datetime NULL,
            RPT_REC_NUM float(8) NOT NULL,
            WKSHT varchar(3) NULL,
            WKSHT_CD varchar(7) NULL,
            SHEET_NAME varchar(500) NULL,
            SECTION_NAME varchar(500) NULL,
            SUBSECTION_NAME varchar(500) NULL,
            LINE_NUM varchar(6) NULL,
            SUBLINE_NUM varchar(2) NULL,
            LINE_DESC varchar(500) NULL,
            CLMN_NUM varchar(6) NULL,
            SUBCLMN_NUM varchar(2) NULL,
            CLMN_DESC varchar(500) NULL,
            WKSHT_CD_96 char(7) NULL,
            LINE_NUM_96 varchar(6) NULL,
            SUBLINE_NUM_96 varchar(2) NULL,
            CLMN_NUM_96 varchar(6) NULL,
            SUBCLMN_NUM_96 varchar(2) NULL,
            NMRC float(8) NULL,
            NMRC_DESC varchar(255) NULL,
            COSTCODE varchar(20) NULL,
            ALPHA varchar(255) NULL
        );

-- 2552-96 CROSSWALKED ALPHA
    INSERT INTO mcrFormData
        SELECT
            r.IMPORT_DT
            , r.FORM
            , CASE 
                WHEN f.WKSHT_CD_96 Is Not Null OR r.FORM = '2552-10' 
                    THEN '2552-10' ELSE '2552-96'
                END AS [FORM_EQUIV]
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

            , f.WKSHT_CD_96

            , f.LINE_NUM_96
            , f.SUBLINE_NUM_96
                    
            , f.CLMN_NUM_96
            , f.SUBCLMN_NUM_96

            , NULL as NMRC
            , NULL as NMRC_DESC
            , NULL as COSTCODE
            , a.ALPHA as ALPHA

        FROM mcrForm f

            INNER JOIN mcrFormData_Alpha a ON
                f.FORM = a.FORM
                AND f.WKSHT_CD_96 = a.WKSHT_CD
                AND f.LINE_NUM_96 = a.LINE_NUM
                AND f.CLMN_NUM_96 = a.CLMN_NUM
                AND f.SUBLINE_NUM_96 = a.SUBLINE_NUM
                AND f.SUBCLMN_NUM_96 = a.SUBCLMN_NUM
                
            INNER JOIN MCR_NEW_RPT r ON
                a.RPT_REC_NUM = r.RPT_REC_NUM
                AND a.IMPORT_DT = r.IMPORT_DT 
                
        WHERE f.WKSHT_CD_96 Is Not Null AND a.FORM = '2552-96';        


-- 2552-10 and 2552-96 NON-CROSSWALKED ALPHA
    INSERT INTO mcrFormData
        SELECT
            r.IMPORT_DT
            , r.FORM
            , CASE 
                WHEN f.WKSHT_CD_96 Is Not Null OR r.FORM = '2552-10' 
                    THEN '2552-10' ELSE '2552-96'
                END AS [FORM_EQUIV]
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

            , f.WKSHT_CD_96

            , f.LINE_NUM_96
            , f.SUBLINE_NUM_96
                    
            , f.CLMN_NUM_96
            , f.SUBCLMN_NUM_96

            , NULL as NMRC
            , NULL as NMRC_DESC
            , NULL as COSTCODE
            , a.ALPHA as ALPHA

        FROM mcrForm f

            INNER JOIN mcrFormData_Alpha a ON
                f.FORM = a.FORM
                AND f.WKSHT_CD = a.WKSHT_CD
                AND f.LINE_NUM = a.LINE_NUM
                AND f.CLMN_NUM = a.CLMN_NUM
                AND f.SUBLINE_NUM = a.SUBLINE_NUM
                AND f.SUBCLMN_NUM = a.SUBCLMN_NUM
                
            INNER JOIN MCR_NEW_RPT r ON
                a.RPT_REC_NUM = r.RPT_REC_NUM
                AND a.IMPORT_DT = r.IMPORT_DT 

        WHERE f.WKSHT_CD_96 Is Null;           

print '*** LOADING NMRC DATA';

-- 2552-96 CROSSWALKED NMRC
    INSERT INTO mcrFormData
        SELECT
            r.IMPORT_DT
            , r.FORM
            , CASE 
                WHEN f.WKSHT_CD_96 Is Not Null OR r.FORM = '2552-10' 
                    THEN '2552-10' ELSE '2552-96'
                END AS [FORM_EQUIV]
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

            , f.WKSHT_CD_96

            , f.LINE_NUM_96
            , f.SUBLINE_NUM_96
                    
            , f.CLMN_NUM_96
            , f.SUBCLMN_NUM_96

            , n.NMRC as NMRC
            , na.ALPHA as NMRC_DESC
            , na.COSTCODE as COSTCODE
            , NULL as ALPHA

            FROM mcrForm f        

                INNER JOIN mcrFormData_Nmrc n ON
                f.FORM = n.FORM
                    AND f.WKSHT_CD_96 = n.WKSHT_CD
                    AND f.LINE_NUM_96 = n.LINE_NUM
                    AND f.CLMN_NUM_96 = n.CLMN_NUM
                    AND f.SUBLINE_NUM_96 = n.SUBLINE_NUM
                    AND f.SUBCLMN_NUM_96 = n.SUBCLMN_NUM     

                INNER JOIN MCR_NEW_RPT r ON	
                    n.RPT_REC_NUM = r.RPT_REC_NUM
                    AND n.IMPORT_DT = r.IMPORT_DT
                        LEFT JOIN mcrFormData_Alpha_Desc na ON
                            na.WKSHT_CD = n.WKSHT_CD
                            AND na.FORM = n.FORM
                            AND na.IMPORT_DT = n.IMPORT_DT
                            AND na.RPT_REC_NUM = n.RPT_REC_NUM
                            AND na.LINE_NUM = n.LINE_NUM

            WHERE f.WKSHT_CD_96 Is Not Null AND n.FORM = '2552-96';   

-- 2552-10 AND 2552-96 NON-CROSSWALKED NMRC
        INSERT INTO mcrFormData
        SELECT
            r.IMPORT_DT
            , r.FORM
            , CASE 
                WHEN f.WKSHT_CD_96 Is Not Null OR r.FORM = '2552-10' 
                    THEN '2552-10' ELSE '2552-96'
                END AS [FORM_EQUIV]
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

            , f.WKSHT_CD_96

            , f.LINE_NUM_96
            , f.SUBLINE_NUM_96
                    
            , f.CLMN_NUM_96
            , f.SUBCLMN_NUM_96

            , n.NMRC as NMRC
            , na.ALPHA as NMRC_DESC
            , na.COSTCODE as COSTCODE
            , NULL as ALPHA

            
            FROM mcrForm f        

                INNER JOIN mcrFormData_Nmrc n ON
                f.FORM = n.FORM
                    AND f.WKSHT_CD = n.WKSHT_CD
                    AND f.LINE_NUM = n.LINE_NUM
                    AND f.CLMN_NUM = n.CLMN_NUM
                    AND f.SUBLINE_NUM = n.SUBLINE_NUM
                    AND f.SUBCLMN_NUM = n.SUBCLMN_NUM     

                INNER JOIN MCR_NEW_RPT r ON	
                    n.RPT_REC_NUM = r.RPT_REC_NUM
                    AND n.IMPORT_DT = r.IMPORT_DT
                        LEFT JOIN mcrFormData_Alpha_Desc na ON
                            na.WKSHT_CD = n.WKSHT_CD
                            AND na.FORM = n.FORM
                            AND na.IMPORT_DT = n.IMPORT_DT
                            AND na.RPT_REC_NUM = n.RPT_REC_NUM
                            AND na.LINE_NUM = n.LINE_NUM
                
            WHERE f.WKSHT_CD_96 Is Null; 






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
