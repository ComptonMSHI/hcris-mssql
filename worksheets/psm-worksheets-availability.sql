/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   These procesdures handle entries for the availability of worksheets within the project.
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spSetWorksheetAvailabilityOn
            @Form = '2552-10'
            , @Worksheet = 'A000000'        
            , @ProductionMode = 0

    -- This resets the entire availability table.
    EXEC spSetWorksheetAvailabilityReset      
            , @ProductionMode = 0
*/
-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.

DROP PROCEDURE IF EXISTS spSetWorksheetAvailabilityOn;
GO

CREATE PROC
    spSetWorksheetAvailabilityOn
        @Form        CHAR(10),
        @Worksheet   CHAR(7),        
        @ProductionMode INTEGER = 0
    AS BEGIN

    print '*** RUNNING psm-worksheets-availability.sql'


        IF @ProductionMode = 1
            BEGIN
                print '*** RUNNING IN PRODUCTION MODE! RECORD ADDED.'
                INSERT INTO [MCR_AVAILABLE] VALUES (@Form, SUBSTRING(@Worksheet,1,1), @Worksheet)
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
                SELECT TOP 100 * FROM [MCR_AVAILABLE];
            END


    END

GO

DROP PROCEDURE IF EXISTS spSetWorksheetAvailabilityReset;
GO

CREATE PROC
    spSetWorksheetAvailabilityReset      
        @ProductionMode INTEGER = 0
    AS BEGIN


        IF @ProductionMode = 1
            BEGIN
                print '*** RUNNING IN PRODUCTION MODE! TABLE TRUNCATED.'
                TRUNCATE TABLE [MCR_AVAILABLE];
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
                SELECT TOP 100 * FROM [MCR_AVAILABLE];
            END


    END

GO
