/*
# Author:   Chris Compton
# Date:     July 2018
#################################
# Reason:   A coordinate is a named location in the data that consist of three elements in 2010 format: worksheet, line, column.
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spLoadTableCoordinates
        @ProductionMode = 1
*/
-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.

DROP PROCEDURE IF EXISTS spLoadTableCoordinates;
GO

CREATE PROC
    spLoadTableCoordinates
        @ProductionMode INTEGER = 0
    AS BEGIN

    print '*** RUNNING psm-table-coordinates.sql'


        /************************************************************
            MODE
        ************************************************************/

        IF @ProductionMode = 1
            BEGIN
                print '*** RUNNING IN PRODUCTION MODE! TABLES DROPPED AND CREATED.';


                DROP TABLE IF EXISTS [mcrCoordinates];

                CREATE TABLE [mcrCoordinates] (
                    [FORM_NUM] [varchar](20) NULL,
                    [WKSHT_CD]    CHAR(7) NOT NULL,
                    [LINE_NUM] [varchar](6) NULL,
                    [SUBLINE_NUM] [varchar](2) NULL,    
                    [CLMN_NUM] [varchar](6) NULL,
                    [SUBCLMN_NUM] [varchar](2) NULL,
                    [NAME] [varchar](255) NULL
                );


                INSERT INTO [mcrCoordinates] (
                    [FORM_NUM], -- For now, use 2010 format as this make sense for analysis tables.
                    [WKSHT_CD],
                    [LINE_NUM],
                    [SUBLINE_NUM],
                    [CLMN_NUM],
                    [SUBCLMN_NUM],
                    [NAME]
                ) VALUES 


                ('2552-10','A000000','001','00','003','00','Depreciation1'),
                ('2552-10','A000000','002','00','003','00','Depreciation2'),
                ('2552-10','A000000','113','00','003','00','Interest'),
                ('2552-10','A000000','200','00','003','00','Total Expenses'),
                ('2552-10','G000000','001','00','001','00','Cash1'),
                ('2552-10','G000000','001','00','002','00','Cash2'),
                ('2552-10','G000000','001','00','003','00','Cash3'),
                ('2552-10','G000000','001','00','004','00','Cash4'),
                ('2552-10','G000000','002','00','001','00','Marketable Securities1'),
                ('2552-10','G000000','002','00','002','00','Marketable Securities2'),
                ('2552-10','G000000','002','00','003','00','Marketable Securities3'),
                ('2552-10','G000000','002','00','004','00','Marketable Securities4'),
                ('2552-10','G000000','011','00','001','00','Current Assets1'),
                ('2552-10','G000000','011','00','002','00','Current Assets2'),
                ('2552-10','G000000','011','00','003','00','Current Assets3'),
                ('2552-10','G000000','011','00','004','00','Current Assets4'),
                ('2552-10','G000000','031','00','001','00','Unrestricted Investments1'),
                ('2552-10','G000000','031','00','002','00','Unrestricted Investments2'),
                ('2552-10','G000000','031','00','003','00','Unrestricted Investments3'),
                ('2552-10','G000000','031','00','004','00','Unrestricted Investments4'),
                ('2552-10','G000000','045','00','001','00','Current Liabilities1'),
                ('2552-10','G000000','045','00','002','00','Current Liabilities2'),
                ('2552-10','G000000','045','00','003','00','Current Liabilities3'),
                ('2552-10','G000000','045','00','004','00','Current Liabilities4'),
                ('2552-10','G000000','059','00','001','00','Fund Balance1'),
                ('2552-10','G000000','059','00','002','00','Fund Balance2'),
                ('2552-10','G000000','059','00','003','00','Fund Balance3'),
                ('2552-10','G000000','059','00','004','00','Fund Balance4'),
                ('2552-10','G200000','028','00','002','00','Total Outpatient Revenue'),
                ('2552-10','G200000','028','00','003','00','Total Patient Revenue'),
                ('2552-10','G300000','003','00','001','00','Total Revenues1'),
                ('2552-10','G300000','006','00','001','00','Contributions'),
                ('2552-10','G300000','007','00','001','00','Investments'),
                ('2552-10','G300000','023','00','001','00','Appropriations'),
                ('2552-10','G300000','025','00','001','00','Total Revenues2'),
                ('2552-10','G300000','029','00','001','00','Net Income'),
                ('2552-10','S200001','003','00','004','00','Provider Type - Hospital'),
                ('2552-10','S200001','021','00','001','00','Control Type'),
                ('2552-10','S300001','005','00','006','00','Inpatient Swing Bed SNF Days'),
                ('2552-10','S300001','006','00','006','00','Inpatient Acute Care Bed Days1'),
                ('2552-10','S300001','013','00','006','00','Inpatient Acute Care Bed Days2'),
                ('2552-10','S300001','014','00','006','00','Inpatient Acute Care Bed Days3');


            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.';
            END

 
    END

GO



DROP FUNCTION IF EXISTS dbo.funcMakePivotFields
GO

CREATE
    FUNCTION dbo.funcMakePivotFields()
    RETURNS VARCHAR(MAX) 
    AS BEGIN
        DECLARE @resultString VARCHAR(MAX) = '';

        WITH Coordinates AS (
            SELECT DISTINCT
            [NAME]
            FROM mcrCoordinates
        )
        SELECT @resultString += QUOTENAME([Name]) + ','
        FROM [Coordinates]
        ORDER BY [Name];

        SET @resultString = LEFT(@resultString, LEN(@resultString)-1)

        RETURN @resultString
    END
GO


