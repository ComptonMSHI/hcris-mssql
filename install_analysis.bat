@echo off

REM # Leave the username blank and press enter for windows authentication.
REM # ./install_analysis.bat localhost TEST_MCR

date /T
time /T

set user=
set /p user=User: 

IF "%user%"=="" (

    sqlcmd -S %1 -d %2 -i analysis/psm-table-checks.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -i analysis/psm-lookups.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -i analysis/psm-table-coordinates.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -i analysis/psm-table-facts.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -i analysis/psm-table-providers.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -i analysis/psm-table-rows.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -i analysis/psm-table-form.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -i analysis/install_analysis.sql -o install_analysis.log

) ELSE (

    sqlcmd -S %1 -d %2 -U %user% -i analysis/psm-table-checks.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -U %user% -i analysis/psm-lookups.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -U %user% -i analysis/psm-table-coordinates.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -U %user% -i analysis/psm-table-facts.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -U %user% -i analysis/psm-table-providers.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -U %user% -i analysis/psm-table-rows.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -U %user% -i analysis/psm-table-form.sql -o install_analysis.log
    sqlcmd -S %1 -d %2 -U %user% -i analysis/install_analysis.sql -o install_analysis.log

)

date /T
time /T