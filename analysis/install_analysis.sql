DECLARE @INSTALL_PRODUCTION INT = 1

print '*** INSTALL: Build Row Table'
EXEC spLoadTableRows @ProductionMode = @INSTALL_PRODUCTION;

print '*** INSTALL: Build Row Table'
EXEC spLoadTableForm @ProductionMode = @INSTALL_PRODUCTION;

print '*** INSTALL: Build Provider Table'
EXEC spLoadTableProviders @ProductionMode = @INSTALL_PRODUCTION;

print '*** INSTALL: Build Fact Table'
EXEC spLoadTableFacts @ProductionMode = @INSTALL_PRODUCTION;
