DROP PROCEDURE IF EXISTS spLoadTableFacts;
GO

CREATE PROC
    spLoadTableFacts
    @ProductionMode INTEGER = 0
    AS BEGIN

DROP TABLE IF EXISTS mcrMeasures;


WITH CALCULATIONS AS (
--------------------------------    


    SELECT 
    
        PRVDR_NUM, FY_BGN_DT, FY_END_DT, RPT_REC_NUM
        ,[Days In Period]
        ,[A000000-001-003] as [Depreciation1]
        ,[A000000-002-003] as [Depreciation2]
        ,[A000000-113-003] as [Interest]
        ,[A000000-200-003] as [Total Expenses]
        ,[G000000-001-001] as [Cash1]
        ,[G000000-001-002] as [Cash2]
        ,[G000000-001-003] as [Cash3]
        ,[G000000-001-004] as [Cash4]
        ,[G000000-002-001] as [Marketable Securities1]
        ,[G000000-002-002] as [Marketable Securities2]
        ,[G000000-002-003] as [Marketable Securities3]
        ,[G000000-002-004] as [Marketable Securities4]
        ,[G000000-011-001] as [Current Assets1]
        ,[G000000-011-002] as [Current Assets2]
        ,[G000000-011-003] as [Current Assets3]
        ,[G000000-011-004] as [Current Assets4]
        ,[G000000-031-001] as [Unrestricted Investments1]
        ,[G000000-031-002] as [Unrestricted Investments2]
        ,[G000000-031-003] as [Unrestricted Investments3]
        ,[G000000-031-004] as [Unrestricted Investments4]
        ,[G000000-045-001] as [Current Liabilities1]
        ,[G000000-045-002] as [Current Liabilities2]
        ,[G000000-045-003] as [Current Liabilities3]
        ,[G000000-045-004] as [Current Liabilities4]
        ,[G000000-059-001] as [Fund Balance1]
        ,[G000000-059-002] as [Fund Balance2]
        ,[G000000-059-003] as [Fund Balance3]
        ,[G000000-059-004] as [Fund Balance4]
        ,[G200000-028-002] as [Total Outpatient Revenue]
        ,[G200000-028-003] as [Total Patient Revenue]
        ,[G300000-003-001] as [Total Revenues1]
        ,[G300000-006-001] as [Contributions]
        ,[G300000-007-001] as [Investments]
        ,[G300000-023-001] as [Appropriations]
        ,[G300000-025-001] as [Total Revenues2]
        ,[G300000-029-001] as [Net Income]
        ,[S300001-005-006] as [Inpatient Swing Bed SNF Days] 
        ,[S300001-006-006] as [Inpatient Acute Care Bed Days1]
        ,[S300001-013-006] as [Inpatient Acute Care Bed Days2]
        ,[S300001-014-006] as [Inpatient Acute Care Bed Days3]

    FROM (

        --------------------------------
        --SELECT DISTINCT ',' + QUOTENAME(Coordinate) FROM (
        --------------------------------

        SELECT
            IMPORT_DT
            , DATEDIFF(d, FY_BGN_DT, FY_END_DT) as [Days In Period]            
            , FY_BGN_DT, FY_END_DT
            , CONCAT(TRIM(WKSHT_CD),'-',TRIM(LINE_NUM),'-',TRIM(CLMN_NUM)) as [Coordinate]
            , PRVDR_NUM
            , CASE WHEN NMRC Is Not Null OR NMRC != ''
                    THEN NMRC ELSE 0
                END AS [NMRC]            
            , RPT_REC_NUM       
        FROM mcrFormData
        WHERE 
           (WKSHT_CD = 'G000000' AND LINE_NUM In ('001','002','011','031','059','045') 
                                 AND CLMN_NUM In ('001','002','003','004'))
        OR (WKSHT_CD = 'G200000' AND LINE_NUM In ('028') 
                                 AND CLMN_NUM In ('002','003'))   
        OR (WKSHT_CD = 'G300000' AND LINE_NUM In ('003','006','007','023','025','029'))
        OR (WKSHT_CD = 'A000000' AND LINE_NUM In ('001','002','113','200') 
                                 AND CLMN_NUM In ('003'))
        OR (WKSHT_CD = 'S300001' AND LINE_NUM In ('005','006','013','014') 
                                 AND CLMN_NUM In ('006'))

        -------------------------------- 
        --) as Quotable
        --------------------------------                               

    ) BaseData

    PIVOT (
        MAX(NMRC) 
        FOR Coordinate IN (
            [A000000-001-003]
            ,[A000000-002-003]
            ,[A000000-113-003]
            ,[A000000-200-003]
            ,[G000000-001-001]
            ,[G000000-001-002]
            ,[G000000-001-003]
            ,[G000000-001-004]
            ,[G000000-002-001]
            ,[G000000-002-002]
            ,[G000000-002-003]
            ,[G000000-002-004]
            ,[G000000-011-001]
            ,[G000000-011-002]
            ,[G000000-011-003]
            ,[G000000-011-004]
            ,[G000000-031-001]
            ,[G000000-031-002]
            ,[G000000-031-003]
            ,[G000000-031-004]
            ,[G000000-045-001]
            ,[G000000-045-002]
            ,[G000000-045-003]
            ,[G000000-045-004]
            ,[G000000-059-001]
            ,[G000000-059-002]
            ,[G000000-059-003]
            ,[G000000-059-004]
            ,[G200000-028-002]
            ,[G200000-028-003]
            ,[G300000-003-001]
            ,[G300000-006-001]
            ,[G300000-007-001]
            ,[G300000-023-001]
            ,[G300000-025-001]
            ,[G300000-029-001]
            ,[S300001-005-006]
            ,[S300001-006-006]
            ,[S300001-013-006]
            ,[S300001-014-006]
        )

    ) AS PivotData


--------------------------------   
)

-- UDF
-- dbo.calcTotalMargin([Net Income],([Total Revenues1] + [Total Revenues2]) as [Total Margin]

SELECT 

CASE WHEN ([Total Revenues1] + [Total Revenues2]) != 0 THEN
    (
        [Net Income] /
        ([Total Revenues1] + [Total Revenues2])
    ) ELSE -101010 END as [Total Margin]


, CASE WHEN ([Fund Balance1] + [Fund Balance2] + [Fund Balance3] + [Fund Balance4]) != 0 THEN    
    (
        [Net Income] / 
        ([Fund Balance1] + [Fund Balance2] + [Fund Balance3] + [Fund Balance4])
    ) ELSE -101010 END as [Return on Equity]
  
    
, CASE WHEN ((([Total Expenses] - ([Depreciation1]+[Depreciation2])) / [Days In Period])) != 0 THEN    
    (
        (
            ([Cash1]+[Cash2]+[Cash3]+[Cash4]) +
            ([Marketable Securities1]+[Marketable Securities2]+[Marketable Securities3]+[Marketable Securities4]) +
            ([Unrestricted Investments1]+[Unrestricted Investments2]+[Unrestricted Investments3]+[Unrestricted Investments4])
        ) / (
            ([Total Expenses] - ([Depreciation1]+[Depreciation2])) / [Days In Period]
        )
    ) ELSE -101010 END as [Days Cash on Hand]

, CASE WHEN [Total Patient Revenue] != 0 THEN        
    (
        [Total Outpatient Revenue] / [Total Patient Revenue]
    ) ELSE -101010 END as [Outpatient Revenues To Total Revenues]

, CASE WHEN [Days In Period] != 0 THEN    
    (
        [Inpatient Swing Bed SNF Days] / [Days In Period]
    ) ELSE -101010 END as [Average Daily Census Sing-SNF Beds]

, CASE WHEN [Days In Period] != 0 THEN    
    (
        ([Inpatient Acute Care Bed Days1]+[Inpatient Acute Care Bed Days2]+[Inpatient Acute Care Bed Days3])
        / ([Days In Period])
    ) ELSE -101010 END as [Average Daily Census Acute Beds]

, * 
INTO mcrMeasures 
FROM CALCULATIONS;

DROP INDEX IF EXISTS mcrMeasures_a ON mcrMeasures;
CREATE INDEX mcrMeasures_a ON mcrMeasures (PRVDR_NUM, FY_BGN_DT, FY_END_DT);



-- SELECT ([Net Income]/([Total Revenues1] + [Total Revenues2])) as [Total Margin] FROM dbo.mcrMeasures;



    END

GO
