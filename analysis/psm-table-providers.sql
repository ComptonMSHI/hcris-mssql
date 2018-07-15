/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   This builds a provider table from the row data
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spLoadTableProviders @ProductionMode = 1;
*/
-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.



DROP PROCEDURE IF EXISTS spLoadTableProviders;
GO

/*
EXEC spLoadTableProviders      
        @ProductionMode = 1
*/

CREATE PROC
    spLoadTableProviders
    @ProductionMode INTEGER = 0
    AS BEGIN

    print '*** RUNNING psm-table-providers.sql'


IF @ProductionMode = 1
	BEGIN
		print '*** RUNNING IN PRODUCTION MODE! TABLES DROPPED AND CREATED.'

        DROP TABLE IF EXISTS mcrProviders;

        WITH PROVIDERS AS (
            SELECT * FROM (

                SELECT DISTINCT

                    fd.PRVDR_NUM 
                    , LAST_VALUE(fd.CLMN_DESC) 
                        OVER (
                            PARTITION BY fd.PRVDR_NUM,[LINE_NUM],[SUBLINE_NUM],[CLMN_NUM],[SUBCLMN_NUM]
                            ORDER BY fd.FY_BGN_DT
                            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                        ) as [Id]
                    , LAST_VALUE(fd.ALPHA) 
                        OVER (
                            PARTITION BY fd.PRVDR_NUM,[LINE_NUM],[SUBLINE_NUM],[CLMN_NUM],[SUBCLMN_NUM]
                            ORDER BY fd.FY_BGN_DT 
                            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                        ) as [Val]
                    
                FROM mcrFormData fd
                        
                WHERE fd.WKSHT_CD='S200001'
                    AND (
                        (fd.LINE_NUM = '001' AND fd.CLMN_NUM In ('001', '002')) OR
                        (fd.LINE_NUM = '002' AND fd.CLMN_NUM In ('001', '002','003','004')) OR
                        (fd.LINE_NUM = '003' AND fd.CLMN_NUM In ('001', '002','003','005'))
                    )
                    

            ) BaseData
            PIVOT (
                max(Val) FOR Id IN (
                    [Component Name]
                    , [CCN Number]
                    , [CBSA Number]
                    , [Date Certified]
                    , [Street]
                    , [P.O. Box]
                    , [City]
                    , [State]
                    , [County]
                    , [Zip Code]
                )
            ) AS PivotData
            
        )
        SELECT DISTINCT 
        p.[PRVDR_NUM]
        , [Component Name] as [NAME]
        , [CCN Number] as [CCN]
        , [CBSA Number] as [CBSA]
        , [Control Type] as [CONTROL_TYPE]
        , [Date Certified] as [CERTIFIED]
        , [Street] as [STREET]
        , [P.O. Box] as [POBOX]
        , [City] as [CITY]
        , [State] as [STATE]
        , [County] as [COUNTY]
        , [Zip Code] as [ZIP]
        INTO mcrProviders
            FROM PROVIDERS p
            JOIN (
                
                SELECT DISTINCT 
                PRVDR_NUM
                , LAST_VALUE(PRVDR_CTRL_TYPE_CD) 
                        OVER (
                            PARTITION BY PRVDR_NUM
                            ORDER BY FY_BGN_DT
                            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                        ) as [Control Type]
                FROM MCR_NEW_RPT
            
            ) as ct ON p.PRVDR_NUM = ct.PRVDR_NUM


        DROP INDEX IF EXISTS mcrProviders_a ON MCR_WORKSHEETS;
        CREATE INDEX mcrProviders_a ON mcrProviders (PRVDR_NUM);

        DROP INDEX IF EXISTS mcrProviders_b ON MCR_WORKSHEETS;
        CREATE INDEX mcrProviders_b ON mcrProviders ([STATE], [COUNTY], [ZIP]);


        UPDATE mcrProviders SET [ZIP] = SUBSTRING([ZIP], 1, 5)

        UPDATE mcrProviders SET [STATE] = 'CT' WHERE STATE = 'CONNECTICUT';
        UPDATE mcrProviders SET [STATE] = 'GA' WHERE STATE = 'GEORGIA';
        UPDATE mcrProviders SET [STATE] = 'MI' WHERE STATE = 'MICHIGAN';
        UPDATE mcrProviders SET [STATE] = 'NY' WHERE STATE = 'NEW YORK';
        UPDATE mcrProviders SET [STATE] = 'TX' WHERE STATE = 'TEXAS';

            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END

    END

GO
