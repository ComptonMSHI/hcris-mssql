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

                SELECT DISTINCT PRVDR_NUM, CLMN_DESC as Id, ALPHA as Val FROM dbo.mcrFormData 
                WHERE FORM='2552-10' AND WKSHT_CD='S200001' AND LINE_DESC = 'Hospital' 
                    AND LINE_NUM = '003' AND ALPHA Is Not Null

                UNION

                SELECT DISTINCT PRVDR_NUM, 'Control Type' as Id, CONVERT(varchar, ALPHA) as Val FROM mcrFormData 
                WHERE FORM='2552-10' AND WKSHT_CD='S200001' AND LINE_NUM = '021' 
                    AND CLMN_NUM='001' AND ALPHA Is Not Null

                UNION

                SELECT DISTINCT PRVDR_NUM, CLMN_DESC as Id, ALPHA as Val FROM mcrFormData 
                WHERE FORM='2552-10' AND WKSHT_CD='S200001' AND LINE_NUM IN ('001','002')

            ) BaseData
            PIVOT (
                max(Val) FOR Id IN (
                    [Component Name]
                    , [CCN Number]
                    , [CBSA Number]
                    , [Control Type]
                    , [Date Certified]
                    , [Street]
                    , [P.O. Box]
                    , [City]
                    , [State]
                    , [County]
                    , [Zip Code]
                )
            ) AS PivotData
            -- ORDER BY PRVDR_NUM
        )
        SELECT DISTINCT 
        [PRVDR_NUM]
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
            FROM PROVIDERS;


        DROP INDEX IF EXISTS mcrProviders_a ON MCR_WORKSHEETS;
        CREATE INDEX mcrProviders_a ON mcrProviders (PRVDR_NUM);

        DROP INDEX IF EXISTS mcrProviders_b ON MCR_WORKSHEETS;
        CREATE INDEX mcrProviders_b ON mcrProviders ([STATE], [COUNTY], [ZIP]);


        UPDATE mcrProviders SET [ZIP] = SUBSTRING([ZIP], 1, 5)


            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END

    END

GO
