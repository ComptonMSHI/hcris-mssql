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


DROP TABLE IF EXISTS mcrFormData;


SELECT
	r.IMPORT_DT
	, r.FORM
	
	, r.PRVDR_NUM
	, r.FY_BGN_DT
	, r.FY_END_DT
	
	, r.RPT_REC_NUM
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

	, a.ALPHNMRC_ITM_TXT as ALPHA
	, n.ITM_VAL_NUM as NMRC
	, na.ALPHNMRC_ITM_TXT as NMRC_DESC

    INTO mcrFormData
    FROM MCR_AVAILABLE yes
        LEFT JOIN MCR_NEW_RPT r ON
            r.FORM = yes.FORM

            LEFT JOIN MCR_WORKSHEETS w ON
                w.FORM_NUM = r.FORM	
                AND w.WKSHT_CD = yes.WKSHT_CD

                LEFT JOIN MCR_CROSSWALK cw ON
                    w.FORM_NUM = cw.FORM_NUM_96
                    AND w.WKSHT_CD = cw.WKSHT_CD_96
                    AND w.LINE_NUM = cw.LINE_NUM_96 
                    AND w.CLMN_NUM = cw.CLMN_NUM_96 
                    
                LEFT JOIN MCR_NEW_ALPHA a ON
                        a.CLMN_NUM != '00000' AND
                        a.WKSHT_CD = w.WKSHT_CD
                        AND a.FORM = w.FORM_NUM
                        AND a.IMPORT_DT = r.IMPORT_DT
                        AND a.RPT_REC_NUM = r.RPT_REC_NUM
                        AND w.LINE_NUM = SUBSTRING(a.LINE_NUM,1,3)
                        AND w.CLMN_NUM = SUBSTRING(a.CLMN_NUM,1,3)                    
                                   
                LEFT JOIN MCR_NEW_NMRC n ON	
                    n.WKSHT_CD = w.WKSHT_CD
                    AND n.FORM = w.FORM_NUM	
                    AND n.IMPORT_DT = r.IMPORT_DT
                    AND n.RPT_REC_NUM = r.RPT_REC_NUM
                    AND w.LINE_NUM = SUBSTRING(n.LINE_NUM,1,3)
                    AND w.CLMN_NUM = SUBSTRING(n.CLMN_NUM,1,3) 

                        LEFT JOIN MCR_NEW_ALPHA na ON
                            na.WKSHT_CD = n.WKSHT_CD
                            AND na.FORM = n.FORM
                            AND na.IMPORT_DT = n.IMPORT_DT
                            AND na.RPT_REC_NUM = n.RPT_REC_NUM
                            AND na.LINE_NUM = n.LINE_NUM
                            AND na.CLMN_NUM = '00000'


DROP INDEX IF EXISTS mcrFormData_a ON mcrFormData;
CREATE INDEX mcrFormData_a ON mcrFormData (FORM, WKSHT, WKSHT_CD);

DROP INDEX IF EXISTS mcrFormData_b ON mcrFormData;
CREATE INDEX mcrFormData_b ON mcrFormData (WKSHT);

DROP INDEX IF EXISTS mcrFormData_c ON mcrFormData;
CREATE INDEX mcrFormData_c ON mcrFormData (FORM ASC, WKSHT_CD ASC, LINE_NUM ASC);

DROP INDEX IF EXISTS mcrFormData_d ON mcrFormData;
CREATE INDEX mcrFormData_d ON mcrFormData (CLMN_NUM, LINE_NUM, FORM, WKSHT_CD);

DROP INDEX IF EXISTS mcrFormData_e ON mcrFormData;
CREATE INDEX mcrFormData_e ON mcrFormData (PRVDR_NUM ASC, FY_BGN_DT ASC, FY_END_DT ASC, RPT_REC_NUM ASC);



    END

GO
