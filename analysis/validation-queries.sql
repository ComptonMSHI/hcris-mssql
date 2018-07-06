


-- VALIDATION for mcrMeasures

SELECT TOP 10
[RPT_REC_NUM], '(' as '(', [Total Revenues1], '+' as '+', [Total Revenues2], '+' as '+', [Net Income], ')' as ')', '/' as '/', '(' as '(', [Total Revenues1], '+' as '+', [Total Revenues2], ')' as ')', '=' as '=', [Total Margin]
FROM dbo.mcrMeasures;


SELECT TOP 10
[RPT_REC_NUM], [Net Income], '/' as '/', '(' as '(', [Fund Balance1], '+' as '+', [Fund Balance2], '+' as '+', [Fund Balance3], '+' as '+', [Fund Balance4], ')' as ')', '=' as '=', [Return on Equity]
FROM dbo.mcrMeasures;


SELECT TOP 10
[RPT_REC_NUM], '(' as '(',
    [Cash1], '+' as '+', [Cash2], '+' as '+', [Cash3], '+' as '+', [Cash4], '+' as '+',
    [Marketable Securities1], '+' as '+', [Marketable Securities2], '+' as '+', [Marketable Securities3], '+' as '+', [Marketable Securities4], '+' as '+',
    [Unrestricted Investments1], '+' as '+', [Unrestricted Investments2], '+' as '+', [Unrestricted Investments3], '+' as '+', [Unrestricted Investments4],
    ')' as ')', '/' as '/','(' as '(',
    '(' as '(', [Total Expenses], '-' as '-', '(' as '(', [Depreciation1], '+' as '+', [Depreciation2], ')' as ')', ')' as ')', '/' as '/', [Days In Period], 
')' as ')', '=' as '=', [Days Cash on Hand]
FROM dbo.mcrMeasures;


SELECT TOP 10
[RPT_REC_NUM], [Total Outpatient Revenue], '/' as '/', [Total Patient Revenue], '=' as '=', [Outpatient Revenues To Total Revenues]
FROM dbo.mcrMeasures;

EXEC spCheckWorksheet  
        @RecordNum = '115710'
        , @Worksheet = 'G200000'   
        , @Records = '100'

SELECT TOP 10
[RPT_REC_NUM], [Inpatient Swing Bed SNF Days], '/' as '/', [Days In Period], '=' as '=', [Average Daily Census Sing-SNF Beds]
FROM dbo.mcrMeasures;


SELECT TOP 10
[RPT_REC_NUM], '(' as '(', [Inpatient Acute Care Bed Days1], '+' as '+', [Inpatient Acute Care Bed Days2], '+' as '+', [Inpatient Acute Care Bed Days3], ')' as ')', '/' as '/', '(' as '(', [Days In Period], ')' as ')', '=' as '=', [Average Daily Census Acute Beds]
FROM dbo.mcrMeasures;

