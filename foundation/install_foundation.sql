DECLARE @INSTALL_PRODUCTION INT = 1

DECLARE @INSTALL_START_YEAR INT = 1995
DECLARE @INSTALL_END_YEAR INT = 2017
DECLARE @INSTALL_FROM_PATH VARCHAR(255) = N'/data/mcr/Output'
DECLARE @INSTALL_FROM_FOLDER VARCHAR(255) = N'2018-05-06'

-- If running in SMSS, this will load all stored procedures.
-- In the SSMS Menu: Query > SQLCMD Mode
-- :setvar path "C:\Users\chris\Documents\GitHub\hcris-mssql"
-- :r $(path)\psm-crosswalk.sql
-- :r $(path)\psm-mcr-alpha-load.sql
-- :r $(path)\psm-mcr-nmrc-load.sql
-- :r $(path)\psm-mcr-rpt-load.sql
-- :r $(path)\psm-table-facts.sql
-- :r $(path)\psm-table-providers.sql
-- :r $(path)\psm-table-rows.sql
-- :r $(path)\psm-worksheets-availability.sql
-- :r $(path)\psm-worksheets-initialize.sql
-- :r $(path)\psm-worksheets-load.sql

print '*** INSTALL: Load RPT Files'
EXEC spLoadRptData 
	@CsvPath = @INSTALL_FROM_PATH
	, @CsvFolder = @INSTALL_FROM_FOLDER
	, @YearFrom = @INSTALL_START_YEAR
	, @YearTo = @INSTALL_END_YEAR
	, @ProductionMode = @INSTALL_PRODUCTION

print '*** INSTALL: Load ALPHA Files'
EXEC spLoadAlphaData 
	@CsvPath = @INSTALL_FROM_PATH
	, @CsvFolder = @INSTALL_FROM_FOLDER
	, @YearFrom = @INSTALL_START_YEAR
	, @YearTo = @INSTALL_END_YEAR
	, @ProductionMode = @INSTALL_PRODUCTION

print '*** INSTALL: Load NMRC Files'
EXEC spLoadNmrcData 
	@CsvPath = @INSTALL_FROM_PATH
	, @CsvFolder = @INSTALL_FROM_FOLDER
	, @YearFrom = @INSTALL_START_YEAR
	, @YearTo = @INSTALL_END_YEAR
	, @ProductionMode = @INSTALL_PRODUCTION 
