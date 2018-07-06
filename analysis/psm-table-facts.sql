/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   This builds a precomputed, aggregated fact table for multidimensional analysis in a star schema.
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spLoadTableFacts @ProductionMode = 1;
*/
-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.


DROP PROCEDURE IF EXISTS spLoadTableFacts;
GO

/*
EXEC spLoadTableFacts      
        @ProductionMode = 1
*/

CREATE PROC
    spLoadTableFacts
    @ProductionMode INTEGER = 0
    AS BEGIN

    print '*** RUNNING psm-table-facts.sql'


IF @ProductionMode = 1
	BEGIN
		print '*** RUNNING IN PRODUCTION MODE! TABLES DROPPED AND CREATED.'

        DROP TABLE IF EXISTS mcrMeasures;

    DECLARE @SQLString NVARCHAR(MAX) = '
        WITH CALCULATIONS AS (
        --------------------------------    


            SELECT * FROM (
                SELECT 
                    f.PRVDR_NUM
                    , f.FY_BGN_DT
                    , f.FY_END_DT
                    , f.RPT_REC_NUM
                    , DATEDIFF(d, f.FY_BGN_DT, f.FY_END_DT) as [Days In Period]
                    , CASE 
                            WHEN f.NMRC Is Not Null OR f.NMRC != '''' THEN f.NMRC
                            WHEN f.NMRC Is Null AND f.ALPHA Is Not Null THEN f.ALPHA
                            ELSE Null
                        END AS [NMRC]            
                    , [Name] as [CalculationValue]
                    FROM mcrFormData f
                        RIGHT JOIN mcrCoordinates c ON
                            f.WKSHT_CD = c.WKSHT_CD
                            AND f.LINE_NUM	= c.LINE_NUM
                            AND f.SUBLINE_NUM = c.SUBLINE_NUM
                            AND f.CLMN_NUM = c.CLMN_NUM
                            AND f.SUBCLMN_NUM = c.SUBCLMN_NUM
            ) as BaseData

            PIVOT (
                MAX(NMRC) 
                FOR CalculationValue IN ('+
                    dbo.funcMakePivotFields()
                +')

            ) AS PivotData


        --------------------------------   
        )
';

-- It would be a good idea to add an aggregation intersection table that works with
-- mcrFormData and mcrCoordinate so that you could link a value to multiple coordinate names and sum them
-- using the aggregate name.  It would allow calculation rules to be governed by data in tables.
-- It would also make the query below MUCH more readable, and easier to maintain.
-- e.g. 
SET @SQLString = @SQLString + '
        SELECT 

        CASE WHEN [Total Revenues1] Is Not Null OR [Total Revenues2] Is Not Null THEN
    
            (    
                [Net Income] /
                (
                    isnull([Total Revenues1],0) 
                    + isnull([Total Revenues2],0)
                )
            ) ELSE Null END as [Total Margin]

        , CASE WHEN [Fund Balance1] Is Not Null OR [Fund Balance2] Is Not Null OR [Fund Balance3] Is Not Null OR [Fund Balance4] Is Not Null THEN    
            (
                [Net Income] / 
                (
                    isnull([Fund Balance1],0) 
                    + isnull([Fund Balance2],0) 
                    + isnull([Fund Balance3],0) 
                    + isnull([Fund Balance4],0)
                )
            ) ELSE Null END as  [Return on Equity]
            
        ,  (
                isnull([Cash1],0)
                + isnull([Cash2],0)
                + isnull([Cash3],0)
                + isnull([Cash4],0) 
                + isnull([Marketable Securities1],0)
                + isnull([Marketable Securities2],0)
                + isnull([Marketable Securities3],0)
                + isnull([Marketable Securities4],0) 
                + isnull([Unrestricted Investments1],0)
                + isnull([Unrestricted Investments2],0)
                + isnull([Unrestricted Investments3],0)
                + isnull([Unrestricted Investments4],0)
            ) / (
                NULLIF(
                    (
                        isnull([Total Expenses],0) 
                        - (
                            isnull([Depreciation1],0)
                            + isnull([Depreciation2],0))
                        ) 
                        / [Days In Period], 0
                )
            ) as [Days Cash on Hand]

        , CASE WHEN [Total Outpatient Revenue] Is Not Null AND [Total Patient Revenue] Is Not Null THEN        
            (
                [Total Outpatient Revenue] / [Total Patient Revenue]
            ) ELSE Null END as [Outpatient Revenues To Total Revenues]

        , CASE WHEN [Inpatient Swing Bed SNF Days] Is Not Null THEN    
            (
                [Inpatient Swing Bed SNF Days] / [Days In Period]
            ) ELSE Null END as [Average Daily Census Sing-SNF Beds]

        , CASE WHEN [Inpatient Acute Care Bed Days1] Is Not Null 
            OR [Inpatient Acute Care Bed Days2] Is Not Null 
            OR [Inpatient Acute Care Bed Days3] Is Not Null THEN    
            (
                (
                    isnull([Inpatient Acute Care Bed Days1],0)
                    + isnull([Inpatient Acute Care Bed Days2],0)
                    + isnull([Inpatient Acute Care Bed Days3],0))
                / ([Days In Period])
            ) ELSE Null END as [Average Daily Census Acute Beds]

        , * 
        INTO mcrMeasures 
        FROM CALCULATIONS;

    ';

    EXEC SP_EXECUTESQL @SQLString;




        DROP INDEX IF EXISTS mcrMeasures_a ON mcrMeasures;
        CREATE INDEX mcrMeasures_a ON mcrMeasures (PRVDR_NUM, FY_BGN_DT, FY_END_DT);



        -- SELECT ([Net Income]/([Total Revenues1] + [Total Revenues2])) as [Total Margin] FROM dbo.mcrMeasures;

            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END

    END

GO
