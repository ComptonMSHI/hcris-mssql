/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   This sets up all of the supporting lookup tables that describe keys.
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
# Usage:
    EXEC spBuildLookups
        @ProductionMode = 1
*/
-- 0 = Test Mode 		- All actions simulated.  No permanent changes.
-- 1 = Production Mode 	- All actions permanent.  Will drop and create tables.

DROP PROCEDURE IF EXISTS spBuildLookups;
GO

CREATE PROC
    spBuildLookups
        @ProductionMode INTEGER = 0
    AS BEGIN

    print '*** RUNNING psm-lookup.sql'


        /************************************************************
            MODE
        ************************************************************/

        IF @ProductionMode = 1
            BEGIN
                print '*** RUNNING IN PRODUCTION MODE! TABLES DROPPED AND CREATED.'


                DROP TABLE IF EXISTS [mcrLookupProviderType];

                CREATE TABLE mcrLookupProviderType (
                    [Id] INTEGER PRIMARY KEY,
                    [Name] VARCHAR(100) NOT NULL   
                );

                INSERT INTO mcrLookupProviderType (
                    [Id],
                    [Name]
                ) VALUES 
                -- S200001, Line 3, Column 4
                ('1', 'General Short Term')
                ,('2', 'General Long Term')
                ,('3', 'Cancer')
                ,('4', 'Psychiatric')
                ,('5', 'Rehabilitation')
                ,('6', 'Religious Non-Medical Health Care Institution')
                ,('7', 'Children')
                ,('8', 'Alcohol and Drug')
                ,('9', 'Other')
                

                DROP TABLE IF EXISTS [mcrLookupControlType];

                CREATE TABLE mcrLookupControlType (
                    [Id] INTEGER PRIMARY KEY,
                    [Name] VARCHAR(100) NOT NULL   
                );

                INSERT INTO mcrLookupControlType (
                    [Id],
                    [Name]
                ) VALUES 
                -- S200001, Line 21, Column 1
                ('1', 'Voluntary Nonprofit, Church')
                ,('2', 'Voluntary Nonprofit, Other')
                ,('3', 'Proprietary, Individual')
                ,('4', 'Proprietary, Corporation')
                ,('5', 'Proprietary, Partnership')
                ,('6', 'Proprietary, Other')
                ,('7', 'Governmental, Federal')
                ,('8', 'Governmental, City-County')
                ,('9', 'Governmental, County')
                ,('10', 'Governmental, State')
                ,('11', 'Hospital District')
                ,('12', 'City')
                ,('13', 'Other')



            -- END PRODUCTION MODE
            END
        ELSE
            BEGIN
                print '*** RUNNING IN TEST MODE! NO PERMANENT ACTION TAKEN.'
            END



 
    END

GO
   