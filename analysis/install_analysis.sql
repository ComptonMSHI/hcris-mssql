/*
# Author:   Chris Compton
# Date:     June 2018
#################################
# Reason:   This set of scripts produce the analysis tables for the longitudinal dataset.
# For:      UAB MSHI Capstone Project
# Title:    A Sustainable Business Intelligence Approach 
#           to the U.S. Centers for Medicare and Medicaid Services Cost Report Data
#################################
# Install:  See README.md for instructions.
*/

DECLARE @INSTALL_PRODUCTION INT = 1

print '*** INSTALL: Build Form Table'
EXEC spLoadTableForm @ProductionMode = @INSTALL_PRODUCTION;

print '*** INSTALL: Build Row Table'
EXEC spLoadTableRows @ProductionMode = @INSTALL_PRODUCTION;

print '*** INSTALL: Build Provider Table'
EXEC spLoadTableProviders @ProductionMode = @INSTALL_PRODUCTION;

print '*** INSTALL: Build Fact Table'
EXEC spLoadTableFacts @ProductionMode = @INSTALL_PRODUCTION;
