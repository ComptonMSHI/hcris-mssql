DROP PROCEDURE IF EXISTS spLoadTableProviders;
GO

/*
EXEC spTableProviders      
        @ProductionMode = 1
*/

CREATE PROC
    spLoadTableProviders
    @ProductionMode INTEGER = 0
    AS BEGIN


DROP TABLE IF EXISTS mcrProviders;

WITH PROVIDERS AS (
    SELECT * FROM (

        SELECT PRVDR_NUM, CLMN_DESC as Id, ALPHA as Val FROM mcrFormData 
        WHERE 
        WKSHT_CD='S200001' 
        AND SECTION_NAME = 'Hospital and Hospital-Based Component Identification'
        AND CLMN_DESC In ('Component Name', 'CCN Number', 'CBSA Number', 'Date Certified')

        UNION

        SELECT PRVDR_NUM, CLMN_DESC as Id, CONVERT(varchar, NMRC) as Val FROM mcrFormData 
        WHERE 
        WKSHT_CD='S200001' 
        AND SECTION_NAME = 'Hospital and Hospital-Based Component Identification'
        AND CLMN_DESC = 'Provider Type'

        UNION

        SELECT PRVDR_NUM, CLMN_DESC as Id, ALPHA as Val FROM mcrFormData 
        WHERE 
        WKSHT_CD='S200001'
        AND SECTION_NAME = 'Hospital and Hospital Health Care Complex Address'
        AND CLMN_DESC In ('Street', 'P.O. Box', 'City', 'State', 'Zip Code', 'County')

    ) BaseData
    PIVOT (
        max(Val) FOR Id IN (
            [Component Name]
            , [CCN Number]
            , [CBSA Number]
            , [Provider Type]
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
, [Provider Type] as [TYPE]
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




    END

GO
